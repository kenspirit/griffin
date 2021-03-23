defmodule Lolth.Spider.Fetcher do
  use GenServer, restart: :transient

  require Logger

  # api
  def start_link(state = {spider_config, index, _manager_pid, _params}) do
    GenServer.start_link(__MODULE__, state, name: :"Lolth.Spider.Fetcher.#{spider_config.name}.#{index}")
  end

  # server

  @impl true
  def init(state = {spider_config, index, manager_pid, _params}) do
    Logger.info("Fetcher #{spider_config.name} #{index} started with manager pid #{manager_pid}")

    next_move(spider_config)

    {:ok, state}
  end

  @impl true
  def handle_info(:crawl, state = {spider_config, _index, manager_pid, params}) do
    url = GenServer.call(manager_pid, :next_url)

    state = if url != nil do
      Logger.debug("Got url #{url} from #{spider_config.name}")
      result = crawl(spider_config, url, params)
      GenServer.cast(manager_pid, {:result, url, result})
      put_elem(state, 3, Map.merge(params, result.params))
    else
      Logger.debug("NO next url from #{spider_config.name}")
      state
    end

    next_move(spider_config)

    { :noreply, state }
  end

  defp crawl(spider_config, url, params) do
    {time_in_microseconds, result} = :timer.tc(fn ->
      "Elixir.Lolth.Spider.Impl.#{spider_config.type}"
      |> String.to_existing_atom
      |> apply(:crawl, [spider_config, url, Map.merge(spider_config.params, params)])
    end)

    Logger.debug("#{spider_config.name}: After #{time_in_microseconds}ms, crawled result back for #{url}")

    result
  end

  defp next_move(spider_config) do
    Logger.debug("--- Waiting for next move after #{spider_config.crawl_interval} ---")
    Process.send_after(self(), :crawl, spider_config.crawl_interval)
  end
end
