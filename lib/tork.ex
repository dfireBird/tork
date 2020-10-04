defmodule Tork do
  require Logger
  @moduledoc """
  The main module for the application which starts the server,
  accept clients and send and receive message.
  """

  @doc """
  Starts accepting client on the `port` from the config.json.
  """
  def start do
    {:ok, config_data} = File.read("config.json")
    {:ok, config} = Jason.decode(config_data)

    port = String.to_integer(Map.get(config, "port") || System.get_env("PORT") || "4040")
    web_directory = Map.get(config, "web_directory") || System.get_env("DIRECTORY") || "www"
    Tork.Map.set(Tork.Map, "port", port)
    Tork.Map.set(Tork.Map, "web_directory", web_directory)

    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on the port #{port}")

    accept(socket)
  end

  defp accept(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)

    {:ok, pid} = Task.Supervisor.start_child(Tork.TaskSupervisor, fn -> recv(conn) end)
    :gen_tcp.controlling_process(conn, pid)
    accept(socket)
  end

  defp recv(conn) do
    msg =
      with {:ok, data} <- read_line(conn),
           {:ok, command} <- Tork.Method.parse(data),
      do: Tork.Method.run(command)

    {:ok, _headers} = Tork.Headers.accept_headers(conn)

    write_line(conn, msg)
   end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  # Get request reply
  defp write_line(socket, {:ok, version, body}) do
    :gen_tcp.send(socket, "#{version} 200 OK\r\n")
    :gen_tcp.send(socket, "Content-Length: #{byte_size(body)}\r\n")
    :gen_tcp.send(socket, "Server: Tork/0.0.1 (Unix)\r\n")
    :gen_tcp.send(socket, "\r\n")
    :gen_tcp.send(socket, body)
    :gen_tcp.close(socket)
  end

  defp write_line(socket, {:http_error, version, 404}) do
    :gen_tcp.send(socket, "#{version} 404 NOT FOUND\r\n")
    :gen_tcp.send(socket, "\r\n")
    :gen_tcp.send(socket, "Sorry I don't have that file\r\n")
    :gen_tcp.close(socket)
  end

  # Known error send it to client
  defp write_line(socket, {:error, {:unknown_command, version}}) do
    :gen_tcp.send(socket, "#{version} 400 Bad Request\r\n")
    :gen_tcp.send(socket, "\r\n")
    :gen_tcp.send(socket, "Sorry I don't understand the request\r\n")
    :gen_tcp.close(socket)
  end

  # The client closed the connection, exit cleanly
  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  # Unknow error, notify the client and exit
  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\n")
    exit(error)
  end

  defp write_line(socket, _) do
    :gen_tcp.close(socket)
  end
end
