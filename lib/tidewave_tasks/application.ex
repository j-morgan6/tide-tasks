defmodule TidewaveTasks.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TidewaveTasksWeb.Telemetry,
      TidewaveTasks.Repo,
      {DNSCluster, query: Application.get_env(:tidewave_tasks, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TidewaveTasks.PubSub},
      # Start a worker by calling: TidewaveTasks.Worker.start_link(arg)
      # {TidewaveTasks.Worker, arg},
      # Start to serve requests, typically the last entry
      TidewaveTasksWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TidewaveTasks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TidewaveTasksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
