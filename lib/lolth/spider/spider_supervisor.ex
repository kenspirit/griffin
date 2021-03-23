defmodule Lolth.Spider.Supervisor do
  use DynamicSupervisor

  require Logger

  # api
  def start_link(spider_config) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: :"Lolth.Spider.Supervisor.#{spider_config.name}")
  end

  # server impl
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_fetcher(spider_config, index, manager_pid) do
    spider_name = spider_config.name
    Logger.info("Starting fetcher Lolth.Spider.#{spider_name}.#{index}")

    spec = %{
      id: "Lolth.Spider.Fetcher.#{spider_name}.#{index}",
      start: {Lolth.Spider.Fetcher, :start_link, [{spider_config, index, manager_pid, %{}}]}
    }
    DynamicSupervisor.start_child(:"Lolth.Spider.Supervisor.#{spider_name}", spec)
  end
end
