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
    map = %{hello: "there",
            general: "kenobi",
            foobal: "soccer",
            elixir: "good",
           }
    case String.split(command) do
      ["GET", key] ->
        case map[String.to_atom(key)] do
          nil -> :gen_tcp.send(conn, "ERROR undefined\n")
          value -> :gen_tcp.send(conn, "ANSWER #{value}\n")
        end
    end
  end
end
