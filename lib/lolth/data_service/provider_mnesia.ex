defmodule Lolth.DataService.Provider.Mnesia do
  use Lolth.DataService.Provider

  @impl Lolth.DataService.Provider
  def save_page_result(spider_config, crawled_result) do
    url = crawled_result.url

    attrs = crawled_result.result
      |> Map.put("success", crawled_result.success)
      |> Map.put("invalid", crawled_result.invalid)
      |> Map.put("failed_reason", crawled_result.failed_reason)

    save_page(spider_config, url, attrs)

    Enum.each(crawled_result.next_urls, fn next_url ->
      save_page(spider_config, next_url, %{})
    end)

    :ok
  end

  @impl Lolth.DataService.Provider
  def save_page(spider_config, url, attrs) do
    spider_type = spider_config.type
    spider_name = spider_config.name

    existing_page = get_page(spider_name, url)

    if existing_page == nil do
      id = next_id("ser_page")

      %Page{}
      |> Map.merge(%{
        id: id,
        spider_type: spider_type,
        spider_name: spider_name,
        url: url
      })
      |> Page.changeset(attrs)
      |> @repo.insert!
    else
      existing_page
      |> Page.changeset(attrs)
      |> @repo.update!
    end
  end

  def next_id(type) do
    {:atomic, id} = :mnesia.transaction(fn ->
      existing_rec = :mnesia.read(:counter, type, :write)

      case existing_rec do
        [] ->
          :mnesia.write(:counter, {Lolth.Spider.Counter, type, 1}, :write)
          1
        [{Lolth.Spider.Counter, type, existing_id}] ->
          :mnesia.write(:counter, {Lolth.Spider.Counter, type, existing_id + 1}, :write)
          existing_id + 1
      end
    end)

    id
  end
end
