defmodule HanabiPlayerTest do
  use ExUnit.Case
  doctest Hanabi.Player, import: true

  alias Hanabi.Player
  alias Hanabi.Tile

  test "init/2 initializes a player" do
    username = "player_1"
    initial_hand = [
      Tile.init(:red, 1),
      Tile.init(:blue, 1),
      Tile.init(:green, 1),
      Tile.init(:yellow, 1),
      Tile.init(:white, 1),
    ]

    player = Player.init(username, initial_hand)

    assert ^username = Player.username(player)
    assert ^initial_hand = Player.hand(player)
  end

  test "give_hint/2 hints all tiles in a player's hand" do
    username = "player_1"
    initial_hand = [
      Tile.init(:red, 1),
      Tile.init(:blue, 1),
      Tile.init(:green, 1),
      Tile.init(:yellow, 1),
      Tile.init(:white, 1),
    ]

    player = Player.init(username, initial_hand)

    hinted_player = Player.give_hint(player, :red)

    expected_hand = Enum.map(initial_hand, &Tile.give_hint(&1, :red))

    assert ^expected_hand = Player.hand(hinted_player)
  end
end
