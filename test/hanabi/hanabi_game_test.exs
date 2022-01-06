defmodule HanabiGameTest do
  use ExUnit.Case

  alias Hanabi.Game
  alias Hanabi.Deck
  alias Hanabi.Tile
  alias Hanabi.Player

  test "new_game/1 starts a new game and deals tiles to players" do
    game = Game.new_game(["player_1", "player_2"])
    deck = Game.deck(game)
    players = Game.players(game)

    assert Deck.count(deck) == 50
    assert length(players) == 2

    expected_players_usernames = Enum.map(players, &Player.username/1)
    assert "player_1" in expected_players_usernames
    assert "player_2" in expected_players_usernames

    for player <- players do
      assert length(Player.hand(player)) == 5
    end
  end

  describe "play_tile/3" do
    setup do
      initial_deck = [
        Tile.init(:red, 1),
        Tile.init(:blue, 2),
      ]

      game = Game.new_game(["player_1", "player_2"], initial_deck)

      %{game: game}
    end

    test "returns a new board with the tile placed when an acceptable play is made", %{game: game} do
      new_game = Game.play_tile(game, "player_1", 1)

      # Playing the (:red, 1) tile that is in the setup initial_deck
      expected_board = %{Game.board(game) | red: MapSet.new([1])}

      assert Game.board(new_game) == expected_board
      assert Game.strikes(new_game) == Game.strikes(game)
      assert Game.discard_pile(new_game) == Game.discard_pile(game)
    end

    test "returns a new game with 1 more strike and the tile added to the discard pile", %{game: game} do
      new_game = Game.play_tile(game, "player_1", 0)

      # Playing the (:blue, 2) tile that is in the setup initial_deck
      expected_discard = %{Game.discard_pile(game) | blue: [2]}

      assert Game.board(new_game) == Game.board(game)
      assert Game.strikes(new_game) == Game.strikes(game) + 1
      assert Game.discard_pile(new_game) == expected_discard
    end
  end
end
