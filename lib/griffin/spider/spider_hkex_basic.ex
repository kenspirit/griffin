defmodule Lolth.Spider.Impl.HkexBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "https://www.hkex.com.hk/eng/services/trading/securities/securitieslists/ListOfSecurities.xlsx"

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36"}]
  plug Tesla.Middleware.Timeout, timeout: 20_000
  plug Tesla.Middleware.Opts, [adapter: [proxy: {'127.0.0.1', 1235}]]

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    [""]
  end

  @impl Lolth.Spider.Impl
  def crawl(_spider_config, _url, _params) do
    result = get_by_page()

    crawled_result = %Lolth.Spider.CrawledResult{url: @domain, next_urls: []}

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

  defp get_by_page() do
    result = get(@domain)

    case result do
      {:ok, %{status: 200} = response} ->
        tmp_xlsx_path = Path.join(System.tmp_dir(), "hkex_basic.xlsx")

        File.write!(tmp_xlsx_path, response.body)

        [{:ok, table_id}] = Xlsxir.multi_extract(tmp_xlsx_path)
        Xlsxir.get_list(table_id)
        |> Enum.drop(3)
        |> Enum.map(&save_gem/1)
        |> Enum.reject(fn item -> is_nil(item) end)
        |> Griffin.Treasure.create_gem_by_admin()

        :ok
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end
  end

  defp save_gem(item) do
    type = case Enum.at(item, 2) do
      "Equity" ->
        "stock"
      "Exchange Traded Products" ->
        "etf"
      _ ->
        nil
    end

    save_gem_type(item, type)
  end

  defp save_gem_type(_item, type) when type not in ["stock", "etf"] do
    nil
  end

  defp save_gem_type(item, type) do
    %{}
    |> Map.put(:code, Enum.at(item, 0))
    |> Map.put(:name, Enum.at(item, 1))
    |> Map.put(:enname, Enum.at(item, 1))
    |> Map.put(:type, type)
    |> Map.put(:location, "HKEX")
  end
end
