defmodule HanabiGameTest do
  use ExUnit.Case

  alias Hanabi.Game
  alias Hanabi.Tile

  test "new_game/1 starts a new game and deals tiles to players" do
    game = Game.new_game(["player_1", "player_2"])

    expected_hand =
      Enum.map(1..5, fn _ ->
        Tile.init(:red, 1)
        |> Tile.conceal_tile()
      end)

    expected_board = empty_board()
    expected_discard_pile = empty_discard_pile()

    assert %{
             board: empty_board,
             discard_pile: empty_discard_pile,
             deck: 50,
             hint_count: 8,
             strikes: 0,
             message: "Welcome to Hanabi!",
             current_player: "player_1",
             players: %{
               "player_1" => player_hand,
               "player_2" => player_2_hand
             }
           } = Game.tally(game, "player_1")

    assert length(player_2_hand) == 5
    assert empty_board == expected_board
    assert empty_discard_pile == expected_discard_pile
    assert player_hand == expected_hand
  end

  describe "play_tile/3" do
    setup do
      initial_deck = [
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:blue, 2),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1)
      ]

      game = Game.new_game(["player_1", "player_2", "player_3"], initial_deck)

      %{game: game}
    end

    test "returns a new board with the tile placed when an acceptable play is made", %{game: game} do
      {:ok, new_game} = Game.play_tile(game, "player_1", 1)

      %{discard_pile: expected_discard_pile, strikes: expected_strikes, board: board} =
        Game.tally(game, "player_1")

      # Playing the (:red, 1) tile that is in the setup initial_deck
      expected_board = %{board | red: MapSet.new([1])}

      %{
        discard_pile: new_discard_pile,
        strikes: new_strikes,
        board: new_board,
        current_player: current_player,
        message: message
      } = Game.tally(new_game, "player_1")

      assert current_player == "player_3"
      assert new_board == expected_board
      assert new_strikes == expected_strikes
      assert new_discard_pile == expected_discard_pile
      assert message == "player_1 successfully played a red 1"
    end

    test "returns a new game with 1 more strike and the tile added to the discard pile when playing a tile that isn't ready yet",
         %{
           game: game
         } do
      {:ok, new_game} = Game.play_tile(game, "player_1", 0)

      %{discard_pile: discard_pile, strikes: strikes, board: expected_board} =
        Game.tally(game, "player_1")

      # Playing the (:blue, 2) tile that is in the setup initial_deck
      expected_discard = %{discard_pile | blue: [2]}

      %{
        discard_pile: new_discard_pile,
        strikes: new_strikes,
        board: new_board,
        current_player: current_player,
        message: message
      } = Game.tally(new_game, "player_1")

      assert current_player == "player_3"
      assert new_board == expected_board
      assert new_strikes == strikes + 1
      assert new_discard_pile == expected_discard
      assert message == "player_1 incorrectly played a blue 2"
    end

    test "returns a new game with 1 more strike and the tile added to the discard pile when playing a tile that has already been played",
         %{
           game: game
         } do
      {:ok, new_game} =
        Game.play_tile(game, "player_1", 1)
        |> elem(1)
        |> Game.play_tile("player_3", 0)

      %{discard_pile: discard_pile, strikes: strikes} = Game.tally(game, "player_1")

      # Playing the (:red, 1) tile that is in the setup initial_deck
      expected_discard = %{discard_pile | red: [1]}

      %{
        discard_pile: new_discard_pile,
        strikes: new_strikes,
        current_player: current_player,
        message: message
      } = Game.tally(new_game, "player_1")

      assert current_player == "player_2"
      assert new_strikes == strikes + 1
      assert new_discard_pile == expected_discard
      assert message == "player_3 incorrectly played a red 1"
    end

    test "return an error when a player makes a move that isn't the current player", %{game: game} do
      assert {:error, "It is currently player_1's turn"} = Game.play_tile(game, "player_2", 0)
    end
  end

  describe "give_hint/2" do
    setup do
      initial_deck = [
        Tile.init(:red, 1),
        Tile.init(:green, 1),
        Tile.init(:green, 1),
        Tile.init(:blue, 1),
        Tile.init(:yellow, 4),
        Tile.init(:white, 2),
        Tile.init(:rainbow, 3),
        Tile.init(:yellow, 1),
        Tile.init(:red, 1),
        Tile.init(:blue, 2),
        Tile.init(:green, 3)
      ]

      game = Game.new_game(["player_1", "player_2"], initial_deck)

      %{game: game}
    end

    test "giving a player a hint decreases the hint count and gives the hint to the player's hand",
         %{game: game} do
      %{hint_count: initial_hint_count} = Game.tally(game, "player_1")

      {:ok, new_game} =
        Game.give_hint(game, "player_1", "player_2", :red)
        |> elem(1)
        |> Game.give_hint("player_2", "player_1", :red)
        |> elem(1)
        |> Game.give_hint("player_1", "player_2", :blue)

      %{
        players: %{"player_2" => player_2_hand},
        hint_count: new_hint_count,
        message: message,
        current_player: current_player
      } = Game.tally(new_game, "player_1")

      %{players: %{"player_2" => player_2_tiles}} = Game.tally(new_game, "player_2")

      player_2_hints = Enum.map(player_2_tiles, &Tile.hints/1)

      assert new_hint_count == initial_hint_count - 3
      assert current_player == "player_2"

      assert Enum.all?(player_2_hand, fn tile ->
               %{color: color_hints} = Tile.hints(tile)
               MapSet.member?(color_hints, :red) and MapSet.member?(color_hints, :blue)
             end)

      assert player_2_hints == [
               %{unhinted_tile_hints() | color: MapSet.new([:blue])},
               %{unhinted_tile_hints() | color: MapSet.new([:red])},
               %{
                 unhinted_tile_hints()
                 | color: MapSet.delete(unhinted_tile_hints().color, :red) |> MapSet.delete(:blue)
               },
               %{unhinted_tile_hints() | color: MapSet.new([:rainbow])},
               %{
                 unhinted_tile_hints()
                 | color: MapSet.delete(unhinted_tile_hints().color, :red) |> MapSet.delete(:blue)
               }
             ]

      assert message == "player_1 hinted player_2 blue"
    end

    test "hinting without any hints returns an error", %{game: game} do
      {:ok, hinted_game} =
        Game.give_hint(game, "player_1", "player_2", :red)
        |> elem(1)
        |> Game.give_hint("player_2", "player_1", :red)
        |> elem(1)
        |> Game.give_hint("player_1", "player_2", :blue)
        |> elem(1)
        |> Game.give_hint("player_2", "player_1", :blue)
        |> elem(1)
        |> Game.give_hint("player_1", "player_2", :green)
        |> elem(1)
        |> Game.give_hint("player_2", "player_1", :green)
        |> elem(1)
        |> Game.give_hint("player_1", "player_2", :white)
        |> elem(1)
        |> Game.give_hint("player_2", "player_1", :white)

      assert {:error, "There are no hints left, choose another action"} =
               Game.give_hint(hinted_game, "player_1", "player_2", :yellow)
    end

    test "return an error when a player makes a move that isn't the current player", %{game: game} do
      assert {:error, "It is currently player_1's turn"} =
               Game.give_hint(game, "player_2", "player_1", 3)
    end
  end

  describe "discard_tile/3" do
    setup do
      initial_deck = [
        Tile.init(:red, 1),
        Tile.init(:white, 2),
        Tile.init(:green, 2),
        Tile.init(:yellow, 2),
        Tile.init(:blue, 2),
        Tile.init(:blue, 2),
        Tile.init(:rainbow, 2),
        Tile.init(:green, 4),
        Tile.init(:yellow, 3),
        Tile.init(:green, 5),
        Tile.init(:white, 2)
      ]

      game = Game.new_game(["player_1", "player_2"], initial_deck)

      %{game: game}
    end

    test "discarding a tile adds it to the discard pile and increments the hint_count", %{
      game: game
    } do
      {:ok, hinted_game} =
        Game.give_hint(game, "player_1", "player_2", :red)
        |> elem(1)
        |> Game.give_hint("player_2", "player_1", :red)

      {:ok, new_game} = Game.discard_tile(hinted_game, "player_1", 0)

      %{hint_count: old_hint_count, discard_pile: old_discard_pile} =
        Game.tally(hinted_game, "player_1")

      %{
        hint_count: new_hint_count,
        discard_pile: new_discard_pile,
        current_player: current_player,
        message: message
      } = Game.tally(new_game, "player_1")

      assert new_hint_count == old_hint_count + 1
      assert new_discard_pile == %{old_discard_pile | blue: [2]}
      assert current_player == "player_2"
      assert message == "player_1 discarded a blue 2"
    end

    test "discarding with 8 hints returns an error", %{game: game} do
      {:error, "Cannot discard a tile while there are 8 hints"} =
        Game.discard_tile(game, "player_1", 0)
    end

    test "return an error when a player makes a move that isn't the current player", %{game: game} do
      assert {:error, "It is currently player_1's turn"} = Game.discard_tile(game, "player_2", 0)
    end
  end

  describe "finishing the game" do
    test "filling the board ends the game" do
      initial_deck = [
        Tile.init(:blue, 5),
        Tile.init(:blue, 4),
        Tile.init(:blue, 3),
        Tile.init(:blue, 2),
        Tile.init(:blue, 1),
        Tile.init(:red, 5),
        Tile.init(:red, 4),
        Tile.init(:red, 3),
        Tile.init(:red, 2),
        Tile.init(:red, 1),
        Tile.init(:white, 1),
        Tile.init(:yellow, 1),
        Tile.init(:white, 2),
        Tile.init(:yellow, 2),
        Tile.init(:white, 3),
        Tile.init(:yellow, 3),
        Tile.init(:white, 4),
        Tile.init(:yellow, 4),
        Tile.init(:white, 5),
        Tile.init(:yellow, 5),
        Tile.init(:green, 1),
        Tile.init(:rainbow, 1),
        Tile.init(:green, 2),
        Tile.init(:rainbow, 2),
        Tile.init(:green, 3),
        Tile.init(:rainbow, 3),
        Tile.init(:green, 4),
        Tile.init(:rainbow, 4),
        Tile.init(:green, 5),
        Tile.init(:rainbow, 5),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1),
        Tile.init(:white, 1)
      ]

      game = Game.new_game(["player_1", "player_2"], initial_deck)

      {:ok, new_game} =
        Enum.reduce(1..30, {:ok, game}, fn turn, {_, game_acc} ->
          player = if rem(turn, 2) == 1, do: "player_1", else: "player_2"

          Game.play_tile(game_acc, player, 0)
        end)

      tally = Game.tally(new_game, "player_1")

      assert tally.state == :done
      assert Game.score(new_game) == 30
      assert {:error, "The game is over!"} == Game.play_tile(new_game, "player_1", 0)
    end

    test "running out of turns when the deck is empty" do
      initial_deck = [
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1)
      ]

      game = Game.new_game(["player_1", "player_2"], initial_deck)

      assert %{deck: 1} = Game.tally(game, "player_1")

      {:ok, new_game} =
        Game.give_hint(game, "player_1", "player_2", :red)
        |> elem(1)
        |> Game.play_tile("player_2", 0)
        |> elem(1)
        |> Game.give_hint("player_1", "player_2", 1)
        |> elem(1)
        |> Game.play_tile("player_2", 0)

      tally = Game.tally(new_game, "player_1")

      assert tally.state == :done
      assert Game.score(new_game) == 1
      assert {:error, "The game is over!"} == Game.give_hint(new_game, "player_1", "player_2", 1)
    end

    test "lose the game after 3 strikes" do
      initial_deck = [
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1),
        Tile.init(:red, 1)
      ]

      game = Game.new_game(["player_1", "player_2"], initial_deck)

      {:ok, new_game} =
        Game.play_tile(game, "player_1", 0)
        |> elem(1)
        |> Game.play_tile("player_2", 0)
        |> elem(1)
        |> Game.play_tile("player_1", 0)
        |> elem(1)
        |> Game.play_tile("player_2", 0)

      tally = Game.tally(new_game, "player_1")

      assert tally.state == :lose
      assert Game.score(new_game) == 0

      assert {:error, "The game is over!"} == Game.play_tile(new_game, "player_1", 0)
    end
  end

  defp empty_board() do
    %{
      red: MapSet.new(),
      green: MapSet.new(),
      blue: MapSet.new(),
      yellow: MapSet.new(),
      white: MapSet.new(),
      rainbow: MapSet.new()
    }
  end

  defp empty_discard_pile() do
    %{
      red: [],
      green: [],
      blue: [],
      yellow: [],
      white: [],
      rainbow: []
    }
  end

  defp unhinted_tile_hints() do
    %{
      color: MapSet.new([:red, :blue, :green, :yellow, :white, :rainbow]),
      number: MapSet.new([1, 2, 3, 4, 5])
    }
  end
end
