defmodule Lolth.Spider.Impl.ChinaWealthBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "https://www.chinawealth.com.cn/LcSolrSearch.go"

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.192 Safari/537.36"}]
  plug Tesla.Middleware.Timeout, timeout: 10_000
  plug Tesla.Middleware.DecompressResponse, format: "gzip"

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    ["1"]
  end

  @impl Lolth.Spider.Impl
  def crawl(_spider_config, offset, params) do
    cookie = params["Cookie"]
    result = get_by_page(String.to_integer(offset), cookie)

    crawled_result = %Lolth.Spider.CrawledResult{url: offset, next_urls: [], params: Map.merge(params, %{"Cookie" => cookie})}

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

  defp get_by_page(_offset, nil) do
    {:error, "Missing Cookie"}
  end

  defp get_by_page(offset, cookie) do
    body = "cpjglb=&cpyzms=&cptzxz=&cpfxdj=&cpqx=&cpsylx=&cpzt=02%2C04%2C06&mjfsdm=01%2CNA&cpdjbm=&cpmc=&cpfxjg=&mjqsrq=&mjjsrq=&areacode=&tzzlxdm=03%2C05%2CNA&pagenum=#{offset}&orderby=&code="
    result = post(@domain, body,
      headers: [
        {"Accept", "application/json, text/javascript, */*; q=0.01"},
        {"Accept-Encoding", "gzip"},
        {"Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"},
        {"Cookie", cookie},
        {"Origin", "https://www.chinawealth.com.cn"}
      ]
    )

    case result do
      {:ok, %{status: 200} = response} ->
        %{"Count" => _count, "List" => rows} = Jason.decode!(response.body)
        save_gem_in_batch(rows, offset)
      {:ok, %{status: 403}} ->
        {:error, "Authenticated failed on page #{offset}"}
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status} on page #{offset}"}
      {:error, _} -> result
    end
  end

  defp save_gem_in_batch([], _offset) do
    {:ok, 0}
  end

  defp save_gem_in_batch(rows, offset) do
    Enum.map(rows, fn row ->
      %{}
      |> Map.put(:code, row["cpdjbm"])
      |> Map.put(:name, row["cpms"])
      |> Map.put(:type, "fund")
      |> Map.put(:location, "CHINAWEALTH")
    end)
    |> Griffin.Treasure.create_gem_by_admin()

    {:ok, offset + 1}
  end
end
