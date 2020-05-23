defmodule Ambrosia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ambrosia.Repo,
      # Start the Telemetry supervisor
      AmbrosiaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ambrosia.PubSub},
      # Start the Endpoint (http/https)
      AmbrosiaWeb.Endpoint
      # Start a worker by calling: Ambrosia.Worker.start_link(arg)
      # {Ambrosia.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ambrosia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AmbrosiaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
