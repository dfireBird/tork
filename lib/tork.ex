defmodule Tork do
  def start() do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true])

    {:ok, conn} = :gen_tcp.accept(socket)

    :gen_tcp.send(conn, "Hello tcp")
    :gen_tcp.close(conn)
  end
end
