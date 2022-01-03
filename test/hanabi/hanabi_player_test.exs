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
      Tile.init(:white, 1)
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
      Tile.init(:white, 1)
    ]

    player = Player.init(username, initial_hand)

    hinted_player = Player.give_hint(player, :red)

    expected_hand = Enum.map(initial_hand, &Tile.give_hint(&1, :red))

    assert ^expected_hand = Player.hand(hinted_player)
  end

  describe "take_tile/2" do
    setup do
      username = "player_1"

      initial_hand = [
        Tile.init(:red, 1),
        Tile.init(:blue, 1),
        Tile.init(:green, 1),
        Tile.init(:yellow, 1),
        Tile.init(:white, 1)
      ]

      player = Player.init(username, initial_hand)

      %{player: player}
    end

    test "returns a :ok tuple with the tile and updated player", %{player: player} do
      expected_hand = [
        Tile.init(:red, 1),
        Tile.init(:green, 1),
        Tile.init(:yellow, 1),
        Tile.init(:white, 1)
      ]

      assert {:ok, tile, updated_player} = Player.take_tile(player, 1)
      assert ^tile = Tile.init(:blue, 1)
      assert ^expected_hand = Player.hand(updated_player)

      expected_hand = [
        Tile.init(:red, 1),
        Tile.init(:yellow, 1),
        Tile.init(:white, 1)
      ]

      assert {:ok, tile, updated_player} = Player.take_tile(updated_player, 1)
      assert ^tile = Tile.init(:green, 1)
      assert ^expected_hand = Player.hand(updated_player)
    end

    test "returns an error if the tile isn't in the player's hand", %{player: player} do
      assert {:error, "Tile was not found in the player's hand"} = Player.take_tile(player, 99)
    end

    test "returns an error if the position is negative", %{player: player} do
      assert {:error, "Position cannot be negative"} = Player.take_tile(player, -1)
    end
  end
end
