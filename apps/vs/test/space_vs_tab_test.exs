defmodule VsTest do
  use ExUnit.Case
  doctest Vs

  test "greets the world" do
    assert Vs.hello() == :world
  end
end
