defmodule HanabiDeckTest do
  use ExUnit.Case
  doctest Hanabi.Deck, import: true

  alias Hanabi.Deck
  alias Hanabi.Tile

  test "init/0 generates a standard Hanabi deck" do
    deck = Deck.init()

    assert length(deck) == 60

    tiles_in_deck = Deck.to_map(deck)

    for tiles <- Map.values(tiles_in_deck) do
      assert length(tiles) == 10
      assert Enum.count(tiles, fn tile -> Tile.number(tile) == 1 end) == 3
      assert Enum.count(tiles, fn tile -> Tile.number(tile) == 2 end) == 2
      assert Enum.count(tiles, fn tile -> Tile.number(tile) == 3 end) == 2
      assert Enum.count(tiles, fn tile -> Tile.number(tile) == 4 end) == 2
      assert Enum.count(tiles, fn tile -> Tile.number(tile) == 5 end) == 1
    end
  end

  describe "draws_tiles/2" do
    test "drawing from an empty deck returns and empty list and an equal deck" do
      deck = Deck.from_list([Tile.init(:red, 1)])

      assert Deck.count(deck) == 1

      {empty_deck, _} = Deck.draw_tiles(deck, 1)

      assert {^empty_deck, []} = Deck.draw_tiles(empty_deck, 1)
    end
    test "drawing multiple tiles from the deck" do
      tile_1 = Tile.init(:red, 1)
      tile_2 = Tile.init(:blue, 2)

      deck = Deck.from_list([tile_1, tile_2])

      assert Deck.count(deck) == 2

      {new_deck, drawn_tiles} = Deck.draw_tiles(deck, 2)

      assert length(drawn_tiles) == 2
      assert length(new_deck) == 0

      assert tile_1 in drawn_tiles
      assert tile_2 in drawn_tiles
    end
  end
end
