defmodule Tork.Verb do
  @moduledoc """
  Modules that parses the data sent by client, return messages related
  to commands and runs the command.
  """


  @doc ~S"""
  Parses the given `data` into command.
  """
  def parse(data) do
    data = String.trim(data)
    case String.split(data, " ", parts: 3) do
      ["GET", key] -> {:ok, {:get, key}}
      ["SET", key, value] -> {:ok, {:set, key, value}}
      ["CLEAR"] -> {:ok, :clear}
      ["ALL"] -> {:ok, :all}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given `command`.
  """
  def run(command, pid)

  def run({:get, key}, pid) do
    case Tork.Map.get(pid, key) do
      nil -> {:ok, "ERROR undefined\n"}
      value -> {:ok, "ANSWER #{value}\n"}
    end
  end

  def run({:set, key, value}, pid) do
    Tork.Map.set(pid, key, value)
    {:ok, "OK\n"}
  end

  def run(:clear, pid) do
    Tork.Map.clear(pid)
    {:ok, "OK\n"}
  end

  def run(:all, pid) do
    values = Tork.Map.all(pid)
    {:ok, "#{Enum.join(values, "\n")}\nOK\n"}
  end
end
