defmodule Tork.MapTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({Tork.Map, name: context.test})
    %{map: context.test}
  end

  test "stores the value by key", %{map: map} do
    assert Tork.Map.get(map, "milk") == nil

    Tork.Map.set(map, "milk", 10)
    assert Tork.Map.get(map, "milk") == 10
  end

  test "clears the values", %{map: map} do
    assert Tork.Map.get(map, "milk") == nil
    assert Tork.Map.get(map, "eggs") == nil
    assert Tork.Map.get(map, "flour") == nil

    Tork.Map.set(map, "milk", 10)
    Tork.Map.set(map, "eggs", 5)
    Tork.Map.set(map, "flour", 20)

    assert Tork.Map.get(map, "milk") == 10
    assert Tork.Map.get(map, "eggs") == 5
    assert Tork.Map.get(map, "flour") == 20

    Tork.Map.clear(map)
    assert Tork.Map.get(map, "milk") == nil
    assert Tork.Map.get(map, "eggs") == nil
    assert Tork.Map.get(map, "flour") == nil
  end

  test "gets all values", %{map: map} do
    assert Tork.Map.all(map) == []

    Tork.Map.set(map, "milk", 10)
    Tork.Map.set(map, "eggs", 5)
    Tork.Map.set(map, "flour", 20)

    assert Tork.Map.all(map) == [5, 20, 10]
  end
end
