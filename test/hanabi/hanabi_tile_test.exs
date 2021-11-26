defmodule HanabiTileTest do
  use ExUnit.Case
  doctest Hanabi.Tile, import: true

  alias Hanabi.Tile

  test "init/2 generates a Tile" do
    tile = Tile.init(:red, 1)

    assert :red = Tile.color(tile)
    assert 1 = Tile.number(tile)
  end
end
