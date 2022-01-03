defmodule HanabiTileTest do
  use ExUnit.Case
  doctest Hanabi.Tile, import: true

  alias Hanabi.Tile

  test "init/2 generates a Tile" do
    tile = Tile.init(:red, 1)

    assert :red = Tile.color(tile)
    assert 1 = Tile.number(tile)
  end

  describe "equal?/2 compares two tiles" do
    test "Two tiles that are the same return true" do
      tile_1 = Tile.init(:red, 1)
      tile_2 = Tile.init(:red, 1)

      assert Tile.equal?(tile_1, tile_2)
    end

    test "Two tiles that are different return false" do
      tile_1 = Tile.init(:red, 1)
      tile_2 = Tile.init(:blue, 1)

      assert not Tile.equal?(tile_1, tile_2)
    end
  end

  test "Can give hints to a Tile" do
    tile = Tile.init(:red, 1)

    hinted_tile = Tile.give_hint(tile, :blue)
    expected_tile_hints = %{color: MapSet.new([:blue]), number: MapSet.new()}

    assert ^expected_tile_hints = Tile.hints(hinted_tile)

    hinted_tile = Tile.give_hint(hinted_tile, 3)
    expected_tile_hints = %{color: MapSet.new([:blue]), number: MapSet.new([3])}

    assert ^expected_tile_hints = Tile.hints(hinted_tile)
  end
end
