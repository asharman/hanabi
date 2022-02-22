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

  describe "possible_values/1" do
    test "hinting a non-rainbow tile" do
      tile = Tile.init(:red, 3)

      expected_possible_values = %{
        color: MapSet.new([:red, :blue, :green, :yellow, :white, :rainbow]),
        number: MapSet.new([1, 2, 3, 4, 5])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, :red)

      expected_possible_values = %{
        color: MapSet.new([:red, :rainbow]),
        number: MapSet.new([1, 2, 3, 4, 5])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, 2)

      expected_possible_values = %{
        color: MapSet.new([:red, :rainbow]),
        number: MapSet.new([1, 3, 4, 5])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, 3)

      expected_possible_values = %{
        color: MapSet.new([:red, :rainbow]),
        number: MapSet.new([3])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, :blue)

      expected_possible_values = %{
        color: MapSet.new([:red]),
        number: MapSet.new([3])
      }

      assert Tile.possible_values(tile) == expected_possible_values
    end

    test "hinting a rainbow tile" do
      tile = Tile.init(:rainbow, 3)

      expected_possible_values = %{
        color: MapSet.new([:red, :blue, :green, :yellow, :white, :rainbow]),
        number: MapSet.new([1, 2, 3, 4, 5])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, :red)

      expected_possible_values = %{
        color: MapSet.new([:red, :rainbow]),
        number: MapSet.new([1, 2, 3, 4, 5])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, 2)

      expected_possible_values = %{
        color: MapSet.new([:red, :rainbow]),
        number: MapSet.new([1, 3, 4, 5])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, 3)

      expected_possible_values = %{
        color: MapSet.new([:red, :rainbow]),
        number: MapSet.new([3])
      }

      assert Tile.possible_values(tile) == expected_possible_values

      tile = Tile.give_hint(tile, :blue)

      expected_possible_values = %{
        color: MapSet.new([:rainbow]),
        number: MapSet.new([3])
      }

      assert Tile.possible_values(tile) == expected_possible_values
    end
  end
end
