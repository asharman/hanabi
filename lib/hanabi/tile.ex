defmodule Hanabi.Tile do
  @moduledoc """
  A Tile represents a single game tile. It has a :color and a number associated with it.
  Colors can be :red, :blue, :green, :white, :yellow, or :rainbow.
  And numbers are 1 - 5
  """

  @enforce_keys [:color, :number]

  defstruct @enforce_keys ++ [hints: %{color: MapSet.new(), number: MapSet.new()}]

  @opaque t :: %__MODULE__{
            color: tile_color(),
            number: tile_number(),
            hints: tile_hints()
          }

  @type tile_color() :: :red | :green | :blue | :yellow | :white | :rainbow
  @type tile_number() :: 1 | 2 | 3 | 4 | 5
  @type tile_hints() :: %{
           color: MapSet.t(tile_color()),
           number: MapSet.t(tile_number())
         }

  @spec init(tile_color(), tile_number()) :: Hanabi.Tile.t()
  def init(color, number), do: %__MODULE__{color: color, number: number}

  @spec color(Hanabi.Tile.t()) :: tile_color()
  def color(%__MODULE__{color: color}), do: color

  @spec number(Hanabi.Tile.t()) :: tile_number()
  def number(%__MODULE__{number: number}), do: number

  @spec equal?(Hanabi.Tile.t(), Hanabi.Tile.t()) :: boolean()
  def equal?(left, right) do
    color(left) == color(right) and number(left) == number(right)
  end

  @spec hints(Hanabi.Tile.t()) :: tile_hints()
  def hints(%__MODULE__{hints: hints}), do: hints

  @spec give_hint(Hanabi.Tile.t(), tile_color() | tile_number()) :: Hanabi.Tile.t()
  def give_hint(%__MODULE__{hints: hints} = tile, hint) when is_integer(hint) do
    new_hints = Map.update(hints, :number, MapSet.new([hint]), &MapSet.put(&1, hint))

    Map.put(tile, :hints, new_hints)
  end

  def give_hint(%__MODULE__{hints: hints} = tile, hint) when is_atom(hint) do
    new_hints = Map.update(hints, :color, MapSet.new([hint]), &MapSet.put(&1, hint))

    Map.put(tile, :hints, new_hints)
  end

  @spec tally(Hanabi.Tile.t()) :: tile_hints()
  def tally(tile) do
    %{
      color: possible_colors(tile),
      number: possible_numbers(tile)
    }
  end

  defp possible_colors(%__MODULE__{color: :rainbow, hints: %{color: color_hints}}) do
    case MapSet.size(color_hints) do
      0 ->
        MapSet.new([:red, :blue, :green, :white, :yellow, :rainbow])

      1 ->
        MapSet.put(color_hints, :rainbow)

      _ ->
        MapSet.new([:rainbow])
    end
  end

  defp possible_colors(%__MODULE__{color: color, hints: %{color: color_hints}}) do
    case {MapSet.size(color_hints), MapSet.member?(color_hints, color)} do
      {0, _} ->
        MapSet.new([:red, :blue, :green, :white, :yellow, :rainbow])

      {1, true} ->
        MapSet.new([color, :rainbow])

      {_, true} ->
        MapSet.new([color])

      {_, false} ->
        MapSet.difference(
          MapSet.new([:red, :blue, :green, :white, :yellow, :rainbow]),
          color_hints
        )
    end
  end

  defp possible_numbers(%__MODULE__{number: number, hints: %{number: number_hints}}) do
    case {MapSet.size(number_hints), MapSet.member?(number_hints, number)} do
      {0, _} ->
        MapSet.new([1, 2, 3, 4, 5])

      {_, true} ->
        MapSet.new([number])

      {_, false} ->
        MapSet.difference(
          MapSet.new([1, 2, 3, 4, 5]),
          number_hints
        )
    end
  end
end
