defmodule Tork do
  require Logger
  @moduledoc """
  The main module for the application which starts the server,
  accept clients and send and receive message.
  """

  @doc """
  Starts accepting client on the given `port`.
  """
  def start(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on the port #{port}")

    accept(socket)
  end

  defp accept(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)

    {:ok, pid} = Task.Supervisor.start_child(Tork.TaskSupervisor, fn -> recv(conn) end)
    :ok = :gen_tcp.controlling_process(conn, pid)
    accept(socket)
  end

  defp recv(conn) do
    msg =
      with {:ok, data} <- read_line(conn),
           {:ok, command} <- Tork.Method.parse(data),
           do: Tork.Method.run(command)
    write_line(conn, msg)
   end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  # Known error send it to client
  defp write_line(socket, {:error, :unknown_command}) do
    Logger.error("Unknown Method")
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
