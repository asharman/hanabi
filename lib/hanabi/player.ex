defmodule Hanabi.Player do
  @moduledoc """
  A Player has a username and hand of tiles. The player can receive a hint to apply to
  all of their tiles.
  """
  alias Hanabi.Tile

  @enforce_keys [:username, :hand]
  defstruct @enforce_keys
  @opaque t :: %__MODULE__{username: String.t(), hand: hand()}
  @typep hand :: %{non_neg_integer() => Tile.t()}

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
    update_player_hand(player, fn
      current_hand ->
        Map.map(current_hand, fn {_pos, tile} -> Tile.give_hint(tile, hint) end)
    end)
  end

  @spec take_tile(Hanabi.Player.t(), non_neg_integer()) ::
          {:ok, Hanabi.Tile.t(), Hanabi.Player.t()} | {:error, String.t()}
  def take_tile(%__MODULE__{hand: hand} = player, position) when position >= 0 do
    case Map.fetch(hand, position) do
      {:ok, tile} ->
        updated_player =
          update_player_hand(player, fn
            current_hand ->
              Map.delete(current_hand, position)
              |> Enum.map(fn {pos, tile} ->
                if pos > position, do: {pos - 1, tile}, else: {pos, tile}
              end)
              |> Enum.into(%{})
          end)

        {:ok, tile, updated_player}

      :error ->
        {:error, "Tile was not found in the player's hand"}
    end
  end

  def take_tile(_, _) do
    {:error, "Position cannot be negative"}
  end

  @spec deal_tile(Hanabi.Tile.t(), Hanabi.Player.t()) :: Hanabi.Player.t()
  def deal_tile(tile, %__MODULE__{hand: hand} = player) do
    insert_position = map_size(hand)

    update_player_hand(player, fn current_hand -> Map.put(current_hand, insert_position, tile) end)
  end

  @spec update_player_hand(Hanabi.Player.t(), (hand() -> hand())) :: Hanabi.Player.t()
  defp update_player_hand(player, fun) do
    Map.update(player, :hand, %{}, fun)
  end
end
