defmodule Tork.Headers do
  require Logger
  @moduledoc """
  Module that parses headers.
  """
  def accept_headers(conn) do
    headers = %{}
    accept_headers(conn, headers)
  end

  def accept_headers(conn, headers) do
    case read_line(conn) do
      {:ok, "\r\n"} -> {:ok, headers}
      {:ok, data} ->
        headers = parse(data, headers)
        accept_headers(conn, headers)
    end
  end

  defp parse(data, headers) do
    data = String.trim(data)
    case String.split(data, ": ") do
      [key, value] -> Map.put(headers, key, value)
      _ -> Logger.error("Malformed error recieved")
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end
end
