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

      assert not(Tile.equal?(tile_1, tile_2))
    end
  end
end
