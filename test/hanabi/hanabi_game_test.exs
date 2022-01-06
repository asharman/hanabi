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
        Tile.init(:blue, 2)
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

    test "returns a new game with 1 more strike and the tile added to the discard pile", %{
      game: game
    } do
      new_game = Game.play_tile(game, "player_1", 0)

      # Playing the (:blue, 2) tile that is in the setup initial_deck
      expected_discard = %{Game.discard_pile(game) | blue: [2]}

      assert Game.board(new_game) == Game.board(game)
      assert Game.strikes(new_game) == Game.strikes(game) + 1
      assert Game.discard_pile(new_game) == expected_discard
    end
  end

  describe "give_hint/2" do
    setup do
      game = Game.new_game(["player_1", "player_2"])

      %{game: game}
    end

    test "giving a player a hint decreases the hint count and gives the hint to the player's hand",
         %{game: game} do
      new_game = Game.give_hint(game, "player_1", "player_2", :red)

      assert Game.hint_count(new_game) == Game.hint_count(game) - 1

      player_2_hints =
        Game.players(new_game)
        |> Enum.find(&(Player.username(&1) == "player_2"))
        |> Player.hand()
        |> Enum.map(&Tile.hints/1)

      assert Enum.all?(player_2_hints, fn %{color: color_hints} ->
               MapSet.member?(color_hints, :red)
             end)

      assert Game.message(new_game) == "player_1 hinted player_2 red"
    end

    test "hinting without any hints returns the same game state", %{game: game} do
      hinted_game =
        Game.give_hint(game, "player_1", "player_2", :red)
        |> Game.give_hint("player_2", "player_1", :red)
        |> Game.give_hint("player_1", "player_2", :blue)
        |> Game.give_hint("player_2", "player_1", :blue)
        |> Game.give_hint("player_1", "player_2", :green)
        |> Game.give_hint("player_2", "player_1", :green)
        |> Game.give_hint("player_1", "player_2", :white)
        |> Game.give_hint("player_2", "player_1", :white)

      new_game = Game.give_hint(hinted_game, "player_1", "player_2", :yellow)

      assert game_equal?(new_game, hinted_game)
      assert Game.message(new_game) == "There are no hints left, choose another action"
    end
  end

  # Check if the game has the same state except for the message
  @spec game_equal?(Game.t(), Game.t()) :: boolean()
  defp game_equal?(game_1, game_2) do
    [
      Game.board(game_1) == Game.board(game_2),
      Game.deck(game_1) == Game.deck(game_2),
      Game.hint_count(game_1) == Game.hint_count(game_2),
      Game.players(game_1) == Game.players(game_2),
      Game.discard_pile(game_1) == Game.discard_pile(game_2),
      Game.strikes(game_1) == Game.strikes(game_2)
    ]
    |> Enum.all?()
  end
end
