defmodule Tork do
  def start() do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true])

    accept(socket)
  end

  defp accept(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)

    :gen_tcp.send(conn, "Welcome!\n")
    recv(conn)
    :gen_tcp.close(conn)
    accept(socket)
  end

  defp recv(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, command} ->
        parse(conn, command)
        recv(conn)
      {:error, err} -> {:error, err}
    end
  end

  defp parse(conn, command) do
    command = String.trim(command)
    case String.split(command, " ", parts: 3) do
      ["GET", key] ->
        case Tork.Map.get(key) do
          nil -> :gen_tcp.send(conn, "ERROR undefined\n")
          value -> :gen_tcp.send(conn, "ANSWER #{value}\n")
        end

      ["SET", key, value] ->
        Tork.Map.set(key, value); :gen_tcp.send(conn, "OK\n")
      ["CLEAR"] -> Tork.Map.clear(); :gen_tcp.send(conn, "OK\n")
      ["ALL"] ->
        :gen_tcp.send(conn, "#{Enum.join(Tork.Map.all(), "\n")}"); :gen_tcp.send(conn, "\nOK\n")
      _ -> :gen_tcp.send(conn, "UNKNOWN COMMAND\n")
    end
  end
end
