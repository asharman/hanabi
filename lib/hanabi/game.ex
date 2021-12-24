defmodule Hanabi.Game do
  @moduledoc """
  Represents the state of the game.
  The game is an opaque type and the only way to create one is to call new_game/1
  """
  alias Hanabi.Deck
  alias Hanabi.Player
  alias Hanabi.Tile

  defstruct([:deck, :players, :board])

  @opaque t() :: %__MODULE__{
            deck: Deck.t(),
            players: list(Player.t()),
            board: %{Tile.tile_color() => MapSet.t(Tile.tile_number())}
          }

  @spec new_game(list(String.t())) :: Hanabi.Game.t()
  def new_game(players) do
    deck = Deck.init()

    {updated_deck, initial_players} =
      Enum.reduce(players, {deck, []}, fn username, {deck_acc, player_acc} ->
        {new_deck, new_player} = create_player(username, deck_acc)

        {new_deck, [new_player | player_acc]}
      end)

    %__MODULE__{
      deck: updated_deck,
      players: initial_players,
      board: initial_board()
    }
  end

  @spec deck(Hanabi.Game.t()) :: Deck.t()
  def deck(%__MODULE__{deck: deck}), do: deck

  @spec players(Hanabi.Game.t()) :: list(Player.t())
  def players(%__MODULE__{players: players}), do: players

  @spec create_player(String.t(), Deck.t()) :: {Deck.t(), Player.t()}
  defp create_player(username, deck) do
    {new_deck, tile_list} = draw_tiles(deck, 5)
    {new_deck, Player.init(username, tile_list)}
  end

  # TODO: Move this to Hanabi.Deck and write a test
  @spec draw_tiles(Deck.t(), non_neg_integer()) :: {Deck.t(), list(Tile.t())}
  defp draw_tiles(deck, count) do
    Enum.reduce(1..count, {deck, []}, fn _, {d, tile_acc} ->
      {tile, new_deck} = Deck.draw_tile(d)
      {new_deck, [tile | tile_acc]}
    end)
  end

  defp initial_board() do
    %{
      red: MapSet.new(),
      green: MapSet.new(),
      blue: MapSet.new(),
      yellow: MapSet.new(),
      white: MapSet.new(),
      rainbow: MapSet.new()
    }
  end
end
