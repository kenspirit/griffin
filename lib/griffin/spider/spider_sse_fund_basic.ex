defmodule Lolth.Spider.Impl.SseFundBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "http://query.sse.com.cn/commonQuery.do"
  @gem_type_map %{
    "COMMON_SSE_ZQPZ_ETFLB_L_NEW" => "etf",
    "COMMON_SSE_ZQPZ_JYXHBJJLB_L_NEW" => "fund",
    "COMMON_SSE_CP_JJ_JJLB_LOFLB_L" => "fund",
    "COMMON_SSE_CP_JJ_JJLB_ZDFBLJL_L" => "fund",
    "COMMON_BOND_XXPL_ZQXX_L" => "bond"
  }

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36"}]
  plug Tesla.Middleware.Timeout, timeout: 5_000
  plug Tesla.Middleware.JSON

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    [""]
  end

  @impl Lolth.Spider.Impl
  def crawl(spider_config, _url, _params) do
    result = get_gems(spider_config.name)

    crawled_result = %Lolth.Spider.CrawledResult{url: spider_config.name, next_urls: []}

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

  defp get_gems(sqlId) do
    result = get(@domain, query: [sqlId: sqlId], headers: [{"Referer", "http://www.sse.com.cn/"}])

    case result do
      {:ok, %{status: 200} = response} ->
        save_gem_in_batch(sqlId, response.body["result"])
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end
  end

  defp save_gem_in_batch(_sqlId, []) do
    :ok
  end

  defp save_gem_in_batch(sqlId, result) do
    type = @gem_type_map[sqlId]

    Enum.map(result, fn r ->
      name = case type do
        "bond" ->
            r["BOND_FULL"]
          _ ->
            if(is_nil(r["FUND_NAME"]), do: r["SEC_NAME_FULL"], else: r["FUND_NAME"])
      end

      code = case type do
        "bond" ->
            r["BOND_CODE"]
          _ ->
            if(is_nil(r["FUND_ID"]), do: r["FUND_CODE"], else: r["FUND_ID"])
      end

      %{}
      |> Map.put(:code, code)
      |> Map.put(:name, name)
      |> Map.put(:type, type)
      |> Map.put(:location, "SSE")
    end)
    |> Griffin.Treasure.create_gem_by_admin()

    :ok
  end
end
