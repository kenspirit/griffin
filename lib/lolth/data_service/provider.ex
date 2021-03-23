defmodule Lolth.DataService.Provider do
  @callback get_all_spider_types() :: [String.t()]

  @callback get_all_spider_config(params :: map()) :: [Lolth.Spider.Config.t()]

  @callback get_spider_config!(spider_name :: String.t()) :: Lolth.Spider.Config.t()

  @callback add_spider_config(spider_config :: map()) :: Lolth.Spider.Config.t()

  @callback update_spider_config(spider_config :: Lolth.Spider.Config.t(), attrs :: map()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}

  @callback get_page(spider_name :: String.t(), url :: String.t()) :: Lolth.Spider.Page.t()

  @callback save_page_result(spider_config :: Lolth.Spider.Config.t(), crawled_result :: Lolth.Spider.CrawledResult.t()) :: :ok

  @callback save_page(spider_config :: Lolth.Spider.Config.t(), url :: String.t(), attrs :: map()) :: :ok

  defmacro __using__(_opts) do
    quote do
      @behaviour Lolth.DataService.Provider

      @repo Application.get_env(:griffin, :lolth) |> Keyword.fetch!(:repo)

      alias Lolth.Spider.Config, as: SpiderConfig
      alias Lolth.Spider.Page

      import Ecto.Query, warn: false

      def get_all_spider_types() do
        query = from(p in SpiderConfig, distinct: true, select: p.type)

        @repo.all(query)
      end

      def get_all_spider_config(params \\ %{}) do
        query = SpiderConfig
        |> where(^filter_where(params))

        @repo.all(query)
      end

      defp filter_where(params) do
        Enum.reduce(Map.to_list(params), dynamic(true), fn
          {"disabled", value}, dynamic ->
            dynamic([q], ^dynamic and q.disabled == ^value)
          {"name", value}, dynamic ->
            search_phrase = value
            |> String.replace("%", "")
            |> String.replace("_", "")

            dynamic([q], ^dynamic and ilike(q.name, ^"%#{search_phrase}%"))
          {"type", value}, dynamic ->
            dynamic([q], ^dynamic and q.type == ^value)
          {"id", value}, dynamic ->
            dynamic([q], ^dynamic and q.id == ^value)
        end)
      end

      def get_spider_config!(id) do
        query = from p in SpiderConfig, where: p.id == ^id

        @repo.one(query)
      end

      def get_spider_config_by_name!(name) do
        query = from p in SpiderConfig, where: p.name == ^name

        @repo.one(query)
      end

      def add_spider_config(spider_config) do
        %SpiderConfig{}
          |> SpiderConfig.changeset(spider_config)
          |> @repo.insert!()
      end

      def update_spider_config(spider_config, attrs) do
        spider_config
        |> SpiderConfig.changeset(attrs)
        |> @repo.update()
      end

      def get_page(spider_name, url) do
        query = from p in Page, where: p.url == ^url and p.spider_name == ^spider_name

        @repo.one(query)
      end

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

      def save_page(spider_config, url, attrs) do
        spider_type = spider_config.type
        spider_name = spider_config.name

        existing_page = get_page(spider_name, url)

        if existing_page == nil do
          %Page{}
          |> Map.merge(%{
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

      defoverridable get_all_spider_types: 0
      defoverridable get_all_spider_config: 1
      defoverridable get_spider_config!: 1
      defoverridable get_spider_config_by_name!: 1
      defoverridable add_spider_config: 1
      defoverridable update_spider_config: 2
      defoverridable get_page: 2
      defoverridable save_page_result: 2
      defoverridable save_page: 3
    end
  end
end
