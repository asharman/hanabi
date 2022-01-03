defmodule Hanabi.Player do
  @moduledoc """
  A Player has a username and hand of tiles. The player can receive a hint to apply to
  all of their tiles.
  """
  alias Hanabi.Tile

  @enforce_keys [:username, :hand]
  defstruct @enforce_keys
  @opaque t :: %__MODULE__{username: String.t(), hand: %{non_neg_integer() => Tile.t()}}

  @spec init(String.t(), list(Tile.t())) :: t()
  def init(username, initial_hand) do
    range = 0..length(initial_hand)

    hand =
      range
      |> Enum.zip(initial_hand)
      |> Enum.into(%{})

    %__MODULE__{username: username, hand: hand}
  end

  @spec username(Hanabi.Player.t()) :: String.t()
  def username(%__MODULE__{username: username}), do: username

  @spec hand(Hanabi.Player.t()) :: list(Tile.t())
  def hand(%__MODULE__{hand: hand}) do
    hand
    |> Enum.sort(fn {pos1, _tile1}, {pos2, _tile2} -> pos1 <= pos2 end)
    |> Enum.map(fn {_position, tile} -> tile end)
  end

  @spec give_hint(Hanabi.Player.t(), Tile.tile_color() | Tile.tile_number()) :: Hanabi.Player.t()
  def give_hint(player, hint) do
    Map.update(player, :hand, %{}, fn
      current_hand ->
        Enum.map(current_hand, fn {pos, tile} -> {pos, Tile.give_hint(tile, hint)} end)
    end)
  end
end
