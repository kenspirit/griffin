defmodule Lolth.SpiderEngine.Supervisor do
  use DynamicSupervisor

  require Logger

  @me __MODULE__

  # api
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  # server impl
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_engine(spider_config) do
    Logger.info("Starting engine Lolth.Spider.Engine.#{spider_config.name}")

    spec = %{
      id: "Lolth.Spider.#{spider_config.name}",
      start: {Lolth.Spider, :start_link, [spider_config]},
      type: :supervisor
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
