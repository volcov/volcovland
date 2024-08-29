defmodule Volcovland.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VolcovlandWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:volcovland, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Volcovland.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Volcovland.Finch},
      # Start a worker by calling: Volcovland.Worker.start_link(arg)
      # {Volcovland.Worker, arg},
      # Start to serve requests, typically the last entry
      VolcovlandWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Volcovland.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VolcovlandWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
