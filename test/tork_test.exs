defmodule TorkTest do
  use ExUnit.Case
  doctest Tork

  test "greets the world" do
    assert Tork.hello() == :world
  end
end
