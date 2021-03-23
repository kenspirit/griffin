defmodule Lolth.Spider.Manager do
  use GenServer

  require Logger

  defstruct all_urls: [], spider_config: %{}, failed_count: 0

  # api
  def start_link(spider_config) do
    GenServer.start_link(__MODULE__, spider_config, name: :"Lolth.Spider.Manager.#{spider_config.name}")
  end

  # server impl
  def init(spider_config) do
    Process.send_after(self(), :kickoff, 0)

    {:ok, %Lolth.Spider.Manager{spider_config: spider_config}}
  end

  def handle_info(:kickoff, state = %Lolth.Spider.Manager{spider_config: spider_config, failed_count: failed_count}) do
    spider_name = spider_config.name
    worker_count = spider_config.worker_count

    Logger.info("There are #{worker_count} fetcher for #{spider_name}")

    all_urls = "Elixir.Lolth.Spider.Impl.#{spider_config.type}"
      |> String.to_existing_atom
      |> apply(:urls_to_crawl, [spider_config.root_url])

    case all_urls do
      {:error, _} ->
        delay = 300_000

        if failed_count >= 3 do
          Logger.error("Terminate spider #{spider_name} after failed #{failed_count} times.")
          Lolth.SpiderEngine.Manager.terminate_spider(spider_name)
        else
          Logger.error("Restart spider #{spider_name} #{delay/1000} seconds later.  Failed count: #{failed_count}.")
          Process.send_after(self(), :kickoff, delay) # 5 mins
        end

        {:noreply, %Lolth.Spider.Manager{state | failed_count: failed_count + 1}}
      _ ->
        1..worker_count
        |> Enum.each(fn index ->
            Lolth.Spider.Supervisor.start_fetcher(spider_config, index, self())
          end)

        {:noreply, %Lolth.Spider.Manager{state | all_urls: all_urls}}
    end
  end

  def handle_call(:next_url, _from, state = %Lolth.Spider.Manager{all_urls: all_urls, spider_config: spider_config}) do
    case all_urls do
      [] ->
        Process.send_after(self(), :kickoff, spider_config.revisit_interval)
        {:reply, nil, state}
      [next_url | remained] ->
        {:reply, next_url, %Lolth.Spider.Manager{state | all_urls: remained}}
    end
  end

  def handle_cast({:result, url, crawled_result}, state = %Lolth.Spider.Manager{all_urls: all_urls, spider_config: spider_config}) do
    spider_name = spider_config.name

    Logger.debug("=== #{spider_name} got result for url #{url}: #{inspect(crawled_result)} ===")

    if crawled_result.result != nil do
      "Elixir.Lolth.Spider.Impl.#{spider_config.type}"
      |> String.to_existing_atom
      |> apply(:store_result, [spider_config, crawled_result])
    end

    Logger.debug("===#{spider_name} got next urls for url #{url}: #{inspect(crawled_result.next_urls)} ===")

    {:noreply, %Lolth.Spider.Manager{state | all_urls: all_urls ++ crawled_result.next_urls}}
  end
end
