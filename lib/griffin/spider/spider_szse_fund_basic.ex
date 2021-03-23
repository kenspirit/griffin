defmodule Lolth.Spider.Impl.SzseFundBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "http://www.szse.cn/api/report/ShowReport?SHOWTYPE=xlsx&CATALOGID=1105&TABKEY=tab1&random=0.8842411412655764"

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36"}]
  plug Tesla.Middleware.Timeout, timeout: 5_000

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
        tmp_xlsx_path = Path.join(System.tmp_dir(), "sz_fund_basic.xlsx")
        tmp_csv_path = Path.join(System.tmp_dir(), "sz_fund_basic.csv")
        File.write!(tmp_xlsx_path, response.body)

        {_status, content} = XlsxParser.write_sheet_content_to_csv(tmp_xlsx_path, 1, tmp_csv_path)

        NimbleCSV.define(MyCsvParser, separator: ",", escape: "\"")

        MyCsvParser.parse_string(content)
        |> Enum.map(&convert_to_gem/1)
        |> Griffin.Treasure.create_gem_by_admin()

        :ok
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end
  end

  defp convert_to_gem(item) do
    type = if(Enum.at(item, 2) == "ETF", do: "etf", else: "fund")

    %{}
    |> Map.put(:code, Enum.at(item, 0))
    |> Map.put(:name, Enum.at(item, 1))
    |> Map.put(:type, type)
    |> Map.put(:location, "SZSE")
  end
end
