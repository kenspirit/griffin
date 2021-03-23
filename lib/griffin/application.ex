defmodule Griffin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Griffin.Repo,
      # Start the Telemetry supervisor
      GriffinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Griffin.PubSub},
      # Start the Endpoint (http/https)
      GriffinWeb.Endpoint,
      # {Lolth.SpiderEngine, []},
      # Start a worker by calling: Griffin.Worker.start_link(arg)
      # {Griffin.Worker, arg}
    ]

    :ets.new(:login_user, [:set, :public, :named_table, read_concurrency: true])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Griffin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GriffinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
