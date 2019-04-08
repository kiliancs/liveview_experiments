defmodule Vs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Phoenix.PubSub.PG2, name: Vs.PubSub},
      # Starts a worker by calling: Vs.State.start_link(nil)
      {Vs.State, {:idle, %{"2 spaces" => 0, "4 spaces" => 0, "Tabs" => 0}}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
