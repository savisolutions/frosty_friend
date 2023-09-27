defmodule FrostyFriend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FrostyFriendWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FrostyFriend.PubSub},
      # Start Finch
      {Finch, name: FrostyFriend.Finch},
      # Start the Endpoint (http/https)
      FrostyFriendWeb.Endpoint
      # Start a worker by calling: FrostyFriend.Worker.start_link(arg)
      # {FrostyFriend.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FrostyFriend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FrostyFriendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
