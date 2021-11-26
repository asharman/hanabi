defmodule Hanabi.Tile do
  @moduledoc """
  A Tile represents a single game tile. It has a :color and a number associated with it.
  Colors can be :red, :blue, :green, :white, :yellow, or :rainbow.
  And numbers are 1 - 5
  """

  defstruct [:color, :number]
  @opaque t :: %__MODULE__{color: tile_color(), number: tile_number()}

  @type tile_color() :: :red | :green | :blue | :yellow | :white | :rainbow
  @type tile_number() :: 1 | 2 | 3 | 4 | 5

  @spec init(tile_color(), tile_number()) :: t()
  def init(color, number), do: %__MODULE__{color: color, number: number}

  @spec color(t()) :: tile_color()
  def color(%__MODULE__{color: color}), do: color

  @spec number(t()) :: tile_number()
  def number(%__MODULE__{number: number}), do: number

  @spec equal?(t(), t()) :: boolean()
  def equal?(left, right) do
    color(left) == color(right) and number(left) == number(right)
  end
end
