defmodule Tork do
  def start() do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true])

    {:ok, conn} = :gen_tcp.accept(socket)

    IO.gets("")
  end
end
