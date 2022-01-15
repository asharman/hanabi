defmodule Hanabi.Lobby do
  defstruct [:name, :players]

  @opaque t() :: %__MODULE__{
            name: String.t(),
            players: MapSet.t(String.t())
          }

  @spec new_room(String.t()) :: Hanabi.Lobby.t()
  def new_room(room_name) do
    %__MODULE__{
      name: room_name,
      players: MapSet.new()
    }
  end

  @spec add_player(Hanabi.Lobby.t(), String.t()) :: Hanabi.Lobby.t()
  def add_player(%__MODULE__{} = lobby, new_player) do
    Map.update(lobby, :players, MapSet.new([new_player]), &MapSet.put(&1, new_player))
  end

  @spec players(Hanabi.Lobby.t()) :: MapSet.t(String.t())
  def players(%__MODULE__{players: players}), do: players
end
