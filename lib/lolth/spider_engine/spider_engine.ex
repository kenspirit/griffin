defmodule Lolth.SpiderEngine do
  use Supervisor

  require Logger

  @me __MODULE__

  # api
  def start_link(_) do
    Supervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  # server

  @impl true
  def init(:no_args) do
    children = [
      Lolth.SpiderEngine.Supervisor,
      Lolth.SpiderEngine.Manager
    ]

    opts = [strategy: :rest_for_one]
    Supervisor.init(children, opts)
  end
end
