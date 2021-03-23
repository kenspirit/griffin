defmodule Lolth.Spider do
  use Supervisor, restart: :transient

  require Logger

  # api
  def start_link(spider_config) do
    Logger.info("Starting the spider for #{spider_config.name}")

    Supervisor.start_link(__MODULE__, spider_config, name: :"Lolth.Spider.#{spider_config.name}")
  end

  # server

  @impl true
  def init(spider_config) do
    spider_name = spider_config.name

    children = [
      %{
        id: "Lolth.Spider.Supervisor.#{spider_name}",
        start: {Lolth.Spider.Supervisor, :start_link, [spider_config]},
        type: :supervisor
      },
      %{
        id: "Lolth.Spider.Manager.#{spider_name}",
        start: {Lolth.Spider.Manager, :start_link, [spider_config]}
      }
    ]

    opts = [strategy: :one_for_all]
    Supervisor.init(children, opts)
  end
end
