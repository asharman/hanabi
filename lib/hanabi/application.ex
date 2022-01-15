defmodule Hanabi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HanabiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hanabi.PubSub},
      # Start the Endpoint (http/https)
      HanabiWeb.Endpoint,
      # Start a worker by calling: Hanabi.Worker.start_link(arg)
      # {Hanabi.Worker, arg}
      {DynamicSupervisor, strategy: :one_for_one, name: Hanabi.LobbySupervisor},
      {Registry, keys: :unique, name: Hanabi.LobbyRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hanabi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HanabiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
