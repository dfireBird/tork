defmodule Tork do
  def start() do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true])

    {:ok, conn} = :gen_tcp.accept(socket)

    :gen_tcp.send(conn, "Welcome!\n")
    {:ok, reply} = :gen_tcp.recv(conn, 0)
    :gen_tcp.send(conn, "You said:\n#{reply}\n")
    :gen_tcp.close(conn)
  end
end
