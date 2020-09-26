defmodule Tork.Map do
  use Agent
  @moduledoc """
  A agent keeping map state for the server.
  """

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    Agent.start_link(fn -> %{} end, name: name)
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def set(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  def clear(pid) do
    Agent.update(pid, fn _ -> %{} end)
  end

  def all(pid) do
    Agent.get(pid, &Map.values(&1))
  end
end
