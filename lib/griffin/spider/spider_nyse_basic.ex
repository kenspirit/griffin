defmodule Lolth.Spider.Impl.NyseBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "https://www.nyse.com/api/quotes/filter"
  @limit 100

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Paw/3.2 (Macintosh; OS X/10.15.2) GCDHTTPRequest"}]
  plug Tesla.Middleware.Timeout, timeout: 5_000
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Opts, [adapter: [proxy: {'127.0.0.1', 1235}]]

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    ["1"]
  end

  @impl Lolth.Spider.Impl
  def crawl(spider_config, offset, _params) do
    result = get_by_page(spider_config.name, String.to_integer(offset))

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

  defp get_by_page(instrumentType, offset) do
    result = post(@domain, %{instrumentType: instrumentType, pageNumber: offset, sortColumn: "NORMALIZED_TICKER", sortOrder: "ASC", maxResultsPerPage: @limit})

    case result do
      {:ok, %{status: 200} = response} ->
        # IO.inspect(Jason.decode!(response.body))
        save_gem_in_batch(instrumentType, response.body, offset)
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end
  end

  defp save_gem_in_batch(_instrumentType, [], _offset) do
    {:ok, 0}
  end

  defp save_gem_in_batch(instrumentType, rows, offset) do
    type = if(instrumentType == "EXCHANGE_TRADED_FUND", do: "etf", else: "stock")

    Enum.map(rows, fn row ->
      %{}
      |> Map.put(:code, row["normalizedTicker"])
      |> Map.put(:name, row["instrumentName"])
      |> Map.put(:enname, row["instrumentName"])
      |> Map.put(:type, type)
      |> Map.put(:location, "NYSE")
    end)
    |> Griffin.Treasure.create_gem_by_admin()

    {:ok, offset + 1}
  end
end
