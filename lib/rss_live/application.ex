defmodule RssLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RssLiveWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:rss_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RssLive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RssLive.Finch},
      # Start a worker by calling: RssLive.Worker.start_link(arg)
      # {RssLive.Worker, arg},
      # Start to serve requests, typically the last entry
      RssLiveWeb.Endpoint,
      {Registry, keys: :unique, name: Registry.RssRegistry},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RssLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RssLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
