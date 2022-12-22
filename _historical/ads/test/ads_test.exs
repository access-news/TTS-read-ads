defmodule AdsTest do
  use ExUnit.Case
  doctest Ads

  test "greets the world" do
    assert Ads.hello() == :world
  end
end
