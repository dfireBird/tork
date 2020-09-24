defmodule Tork do
  def start() do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true])

    {:ok, conn} = :gen_tcp.accept(socket)

    send(conn)
  end

  defp send(conn) do
    :gen_tcp.send(conn, "Hello\n")
    :timer.sleep(2000)
    send(conn)
  end
end
