defmodule Tork.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Tork.TaskSupervisor},
      {Tork.Map, name: Tork.Map},
      Supervisor.child_spec({Task, fn -> Tork.start() end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tork.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
