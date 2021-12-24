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
    new_hints = Map.update(hints, :number, MapSet.new(), &MapSet.put(&1, hint))

    Map.put(tile, :hints, new_hints)
  end

  def give_hint(%__MODULE__{hints: hints} = tile, hint) when is_atom(hint) do
    new_hints = Map.update(hints, :color, MapSet.new(), &MapSet.put(&1, hint))

    Map.put(tile, :hints, new_hints)
  end
end
