defmodule Lolth.Spider.Impl.EasymoneyFundBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "http://fund.eastmoney.com/js/fundcode_search.js"

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Paw/3.2 (Macintosh; OS X/10.15.2) GCDHTTPRequest"}]
  plug Tesla.Middleware.Timeout, timeout: 10_000
  plug Tesla.Middleware.DecompressResponse, format: "gzip"
  # plug Tesla.Middleware.Opts, [adapter: [proxy: {'127.0.0.1', 1235}]]

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    []
  end

  @impl Lolth.Spider.Impl
  def crawl(_spider_config, _url, _params) do
    result = get_from_fundcode_js()

    crawled_result = %Lolth.Spider.CrawledResult{url: nil, next_urls: []}

    # Because the crawled_result size would be too large if passing the whole body back,
    # we directly save result here and return result with status only
    case result do
      :ok ->
        crawled_result
        |> Map.put(:success, true)
      {:error, failed_reason} ->
        crawled_result
        |> Map.put(:success, false)
        |> Map.put(:failed_reason, failed_reason)
    end
  end

  defp get_from_fundcode_js() do
    result = get(@domain,
      headers: [{"Accept", "*/*"}, {"Accept-Encoding", "gzip, deflate"}, {"Content-Type", "application/javascript; charset=utf-8"}]
    )

    case result do
      {:ok, %{status: 200} = response} ->
        all_funds = response.body
        |> String.replace("var r = ", "")
        |> String.replace("\uFEFF", "")
        |> String.replace_suffix(";", "")
        |> Jason.decode!()

        save_gem_in_batch(all_funds)
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end
  end

  defp save_gem_in_batch(all_funds) do
    gems = Enum.map(all_funds, fn fund ->
      %{}
      |> Map.put(:code, Enum.at(fund, 0))
      |> Map.put(:name, Enum.at(fund, 2))
      |> Map.put(:enname, Enum.at(fund, 1))
      |> Map.put(:type, "fund")
      |> Map.put(:location, "EASYMONEY")
    end)

    Griffin.Treasure.create_gem_by_admin(gems)

    :ok
  end
end
