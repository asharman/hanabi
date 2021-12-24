defmodule Hanabi.Player do
  alias Hanabi.Tile

  @enforce_keys [:username, :hand]
  defstruct @enforce_keys
  @opaque t :: %__MODULE__{username: String.t(), hand: list(Tile.t())}

  @spec init(String.t(), list(Tile.t())) :: t()
  def init(username, initial_hand), do: %__MODULE__{username: username, hand: initial_hand}

  @spec username(Hanabi.Player.t()) :: String.t()
  def username(%__MODULE__{username: username}), do: username

  @spec hand(Hanabi.Player.t()) :: list(Tile.t())
  def hand(%__MODULE__{hand: hand}), do: hand

  @spec give_hint(Hanabi.Player.t(), Tile.tile_color() | Tile.tile_number()) :: Hanabi.Player.t()
  def give_hint(player, hint) do
    Map.update(player, :hand, [], fn
      current_hand -> Enum.map(current_hand, &Tile.give_hint(&1, hint))
    end)
  end
end
