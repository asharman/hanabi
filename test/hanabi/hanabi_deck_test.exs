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

  test "draw_tile/1 returns a tile and it is no longer in the deck" do
    deck = Deck.init()

    {tile, new_deck} = Deck.draw_tile(deck)

    tiles_before =
      Deck.to_list(deck)
      |> Enum.filter(&Tile.equal?(&1, tile))

    tiles_after =
      Deck.to_list(new_deck)
      |> Enum.filter(&Tile.equal?(&1, tile))

    assert length(tiles_before) - length(tiles_after) == 1
  end

  test "draw_tile/1 returns nil and an unchanged deck when empty" do
    deck = Deck.from_list([Tile.init(:red, 1)])

    assert Deck.count(deck) == 1

    {_, empty_deck} = Deck.draw_tile(deck)

    assert {nil, ^empty_deck} = Deck.draw_tile(empty_deck)
  end
end
