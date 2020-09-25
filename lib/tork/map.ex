defmodule Tork.Map do
  use Agent
  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(Tork.Map, &Map.get(&1, key))
  end

  def set(key, value) do
    Agent.update(Tork.Map, &Map.put(&1, key, value))
  end

  def clear() do
    Agent.update(Tork.Map, fn _ -> %{} end)
  end

  def all() do
    Agent.get(Tork.Map, &Map.values(&1))
  end
end
