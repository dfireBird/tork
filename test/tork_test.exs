defmodule TorkTest do
  use ExUnit.Case
  doctest Tork

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert :gen_tcp.recv(socket, 0) == {:ok, "Welcome!\n"}

    assert send_and_recv(socket, "UNKNOWN test\n") == "UNKNOWN COMMAND\n"
    assert send_and_recv(socket, "GET eggs\n") == "ERROR undefined\n"

    assert send_and_recv(socket, "SET eggs 10\n") == "OK\n"

    assert send_and_recv(socket, "GET eggs\n") == "ANSWER 10\n"

    assert send_and_recv(socket, "SET milk 5\n") == "OK\n"

    # `ALL` gives multi line reply
    assert send_and_recv(socket, "ALL\n") == "10\n"
    assert send_and_recv(socket, "") == "5\n"
    assert send_and_recv(socket, "") == "OK\n"

    assert send_and_recv(socket, "CLEAR\n") == "OK\n"

    assert send_and_recv(socket, "ALL\n") == "\n"
    assert send_and_recv(socket, "") == "OK\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
