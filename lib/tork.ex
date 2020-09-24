defmodule Tork do
  def start() do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true])

    {:ok, conn} = :gen_tcp.accept(socket)

    :gen_tcp.send(conn, "Welcome!\n")
    recv(conn)
    :gen_tcp.close(conn)
  end

  defp recv(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, reply} ->
        :gen_tcp.send(conn, "You said:\n#{reply}\n")
        recv(conn)
      {:error, err} -> {:error, err}
    end
  end
end
