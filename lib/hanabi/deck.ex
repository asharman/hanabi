defmodule Hanabi.Deck do
  @moduledoc """
  Represents the deck of unplayed tiles in a random order.

  Contains a function for drawing tiles out of the deck and querying the deck's size.
  """
  alias Hanabi.Tile

  @opaque t :: list(Tile.t())

  @spec init :: t()
  def init() do
    for color <- [:red, :blue, :green, :white, :yellow, :rainbow],
        number <- [1, 1, 1, 2, 2, 3, 3, 4, 4, 5] do
      Tile.init(color, number)
    end
    |> Enum.shuffle()
  end

  @doc false
  # Used to test non-random decks
  def init(tiles) do
    tiles
  end

  @spec count(deck: t()) :: non_neg_integer
  def count(deck), do: length(deck)

  @spec draw_tiles(Hanabi.Deck.t(), non_neg_integer()) :: {Hanabi.Deck.t(), list(Tile.t())}
  def draw_tiles(deck, count) do
    Enum.reduce_while(1..count, {deck, []}, fn _, {d, tile_acc} ->
      case draw_tile(d) do
        {nil, new_deck} ->
          {:halt, {new_deck, tile_acc}}

        {tile, new_deck} ->
          {:cont, {new_deck, [tile | tile_acc]}}
      end
    end)
  end

  @spec draw_tile(deck: t()) :: {Tile.t() | nil, t()}
  defp draw_tile([tile | _] = deck) do
    new_deck = List.delete(deck, tile)
    {tile, new_deck}
  end

  defp draw_tile([]), do: {nil, []}

  @spec to_map(deck: t()) :: %{Tile.tile_color() => Tile.tile_number()}
  def to_map(deck) do
    Enum.reduce(
      deck,
      %{},
      fn tile, acc ->
        Map.update(acc, Tile.color(tile), [tile], fn list -> [tile | list] end)
      end
    )
  end

  @spec from_map(%{Tile.tile_color() => Tile.tile_number()}) :: t()
  def from_map(tile_map) do
    Enum.flat_map(tile_map, fn {_color, tiles} -> tiles end)
    |> Enum.shuffle()
  end

  @spec to_list(deck: t()) :: list(Tile.t())
  def to_list(deck), do: deck

  @spec from_list(list(Tile.t())) :: t()
  def from_list(tiles), do: Enum.shuffle(tiles)
end
