defmodule Tork do
  @moduledoc """
  The main module for the application which starts the server,
  accept clients and send and receive message.
  """

  @doc """
  Starts accepting client on the given `port`.
  """
  def start(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    accept(socket)
  end

  defp accept(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)

    :gen_tcp.send(conn, "Welcome!\n")
    {:ok, pid} = Task.Supervisor.start_child(Tork.TaskSupervisor, fn -> recv(conn) end)
    :ok = :gen_tcp.controlling_process(conn, pid)
    accept(socket)
  end

  defp recv(conn) do
    msg =
      with {:ok, data} <- read_line(conn),
           {:ok, command} <- Tork.Verb.parse(data),
           do: Tork.Verb.run(command, Tork.Map)
    write_line(conn, msg)
    recv(conn)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  # Known error send it to client
  defp write_line(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\n")
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
end
