defmodule Lolth.Spider.Impl do
  require Logger

  # https://elixirforum.com/t/behaviours-defoverridable-and-implementations/3338

  @callback urls_to_crawl(root_url :: String.t) :: list(String.t)

  @callback crawl(spider_config :: map(), url :: String.t, params :: map()) :: Lolth.Spider.CrawledResult.t()

  @callback store_result(spider_config :: map(), result :: Lolth.Spider.CrawledResult.t()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Lolth.Spider.Impl

      @data_provider_impl Application.get_env(:griffin, :lolth) |> Keyword.fetch!(:data_provider)

      @repo Application.get_env(:griffin, :lolth) |> Keyword.fetch!(:repo)

      def urls_to_crawl(root_url), do: [root_url]

      def crawl(_spider_config, _url, _params), do: %Lolth.Spider.CrawledResult{}

      def store_result(_spider_config, _result), do: :ok

      defoverridable urls_to_crawl: 1
      defoverridable crawl: 3
      defoverridable store_result: 2
    end
  end
end
