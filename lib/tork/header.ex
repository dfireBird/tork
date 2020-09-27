defmodule Tork.Headers do
  require Logger
  @moduledoc """
  Module that parses headers.
  """
  def accept_headers(conn) do
    case read_line(conn) do
      {:ok, "\r\n"} -> :ok
      {:ok, data} -> parse(data); accept_headers(conn)
    end
  end

  defp parse(data) do
    data = String.trim(data)
    case String.split(data, ": ") do
      [key, value] -> [key, value]
      _ -> Logger.error("Malformed error recieved")
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end
end
