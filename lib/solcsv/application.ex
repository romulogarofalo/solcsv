defmodule Solcsv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Solcsv.Repo,
      # Start the Telemetry supervisor
      SolcsvWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Solcsv.PubSub},
      # Start the Endpoint (http/https)
      SolcsvWeb.Endpoint,
      # Start a worker by calling: Solcsv.Worker.start_link(arg)
      # {Solcsv.Worker, arg}
      {Oban, Application.fetch_env!(:solcsv, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Solcsv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SolcsvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
