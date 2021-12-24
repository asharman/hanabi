defmodule HanabiGameTest do
  use ExUnit.Case

  alias Hanabi.Game
  alias Hanabi.Deck
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
  end
end
