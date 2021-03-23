defmodule Lolth.Spider.Impl.TushareStockBasic do
  use Lolth.Spider.Impl
  use Tesla

  @domain "http://api.waditu.com/"
  @token "033fe54fbe3124f087245b2e2020c0ade199fc973bb4fa0be3661d5e"
  @field_map %{
    "symbol" => :code,
    "name" => :name,
    "enname" => :enname,
    "industry" => :industry,
    "market" => :market,
    "exchange" => :location
  }

  plug Tesla.Middleware.BaseUrl, @domain
  plug Tesla.Middleware.Headers, [{"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Timeout, timeout: 5_000

  @impl Lolth.Spider.Impl
  def urls_to_crawl(_root_url) do
    ["stock_basic"]
  end

  @impl Lolth.Spider.Impl
  def crawl(_spider_config, url, _params) do
    crawled_result = %Lolth.Spider.CrawledResult{url: url, next_urls: []}

    result = post(@domain, %{api_name: url, token: @token, fields: "symbol,name,enname,industry,market,exchange"})

    result = case result do
      {:ok, %{status: 200} = response} ->
        case response.body do
          %{"code" => 0, "data" => data} ->
            save_gem_in_batch(data)
          %{"code" => code, "msg" => msg } ->
            {:error, "#{code}-#{msg}"}
        end
      {:ok, %{status: 404}} ->
        {:error, :invalid}
      {:ok, %{status: status}} ->
        {:error, "Status #{status}"}
      {:error, _} -> result
    end

    # Because the crawled_result size would be too large if passing the whole body back,
    # we directly save result here and return result with status only
    case result do
      {:ok, _} ->
        crawled_result
        |> Map.put(:success, true)
      {:error, failed_reason} ->
        crawled_result
        |> Map.put(:success, false)
        |> Map.put(:failed_reason, failed_reason)
    end
  end

  defp save_gem_in_batch(%{ "fields" => fields, "items" => items }) do
    gems = Enum.map(items, fn values ->
      convert_to_gem(%{}, fields, values)
      |> Map.put(:type, "stock")
    end)

    Griffin.Treasure.create_gem_by_admin(gems)

    {:ok, "success"}
  end

  defp convert_to_gem(gem, [], _values) do
    gem
  end

  defp convert_to_gem(gem, [field | fields], [value | values]) do
    gem
    |> Map.put(get_field_name(field), value)
    |> convert_to_gem(fields, values)
  end

  defp get_field_name(field) do
    Map.get(@field_map, field)
  end
end
