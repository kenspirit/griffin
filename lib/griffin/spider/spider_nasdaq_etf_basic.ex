defmodule Lolth.Spider.Impl.NasdaqEtfBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "https://api.nasdaq.com/api/screener/etf"

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Paw/3.2 (Macintosh; OS X/10.15.2) GCDHTTPRequest"}]
  plug Tesla.Middleware.Timeout, timeout: 5_000
  plug Tesla.Middleware.DecompressResponse, format: "gzip"
  # plug Tesla.Middleware.Opts, [adapter: [proxy: {'127.0.0.1', 1235}]]

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    ["0"]
  end

  @impl Lolth.Spider.Impl
  def crawl(_spider_config, offset, _params) do
    result = String.to_integer(offset)
    |> get_by_page

    crawled_result = %Lolth.Spider.CrawledResult{url: offset, next_urls: []}

    # Because the crawled_result size would be too large if passing the whole body back,
    # we directly save result here and return result with status only
    case result do
      {:ok, 0} ->
        crawled_result
        |> Map.put(:success, true)
      {:ok, offset} ->
        crawled_result
        |> Map.put(:next_urls, [Integer.to_string(offset)])
        |> Map.put(:success, true)
      {:error, failed_reason} ->
        crawled_result
        |> Map.put(:success, false)
        |> Map.put(:failed_reason, failed_reason)
    end
  end

  defp get_by_page(offset) do
    result = get(@domain,
      query: [offset: offset],
      headers: [{"Accept-Encoding", "gzip"}, {"Accept", "application/json"}]
    )

    case result do
      {:ok, %{status: 200} = response} ->
        %{"data" => data, "status" => status, "message" => message} = Jason.decode!(response.body)
        case status["rCode"] do
          200 ->
            save_gem_in_batch(data["records"]["data"]["rows"], offset)
          _ ->
            {:error, "#{status["rCode"]}-#{message}"}
        end
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end
  end

  defp save_gem_in_batch(nil, _offset) do
    {:ok, 0}
  end

  defp save_gem_in_batch(rows, offset) do
    Enum.map(rows, fn row ->
      name = if(row["companyName"] == nil, do: row["symbol"], else: row["companyName"])

      %{}
      |> Map.put(:code, row["symbol"])
      |> Map.put(:name, name)
      |> Map.put(:enname, name)
      |> Map.put(:type, "etf")
      |> Map.put(:location, "NASDAQ")
    end)
    |> Griffin.Treasure.create_gem_by_admin()

    {:ok, offset + length(rows)}
  end
end
