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

    ^username = Player.username(player)
    ^initial_hand = Player.hand(player)
  end
end
