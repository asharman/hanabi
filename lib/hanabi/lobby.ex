defmodule Hanabi.Lobby do
  defstruct [:name, :players, :game]
  alias Hanabi.Game

  @opaque t() :: %__MODULE__{
            name: String.t(),
            players: MapSet.t(String.t()),
            game: Hanabi.Game.t() | nil
          }

  @spec new_room(String.t()) :: Hanabi.Lobby.t()
  def new_room(room_name) do
    %__MODULE__{
      name: room_name,
      players: MapSet.new(),
      game: nil
    }
  end

  @spec add_player(Hanabi.Lobby.t(), String.t()) :: Hanabi.Lobby.t()
  def add_player(%__MODULE__{} = lobby, new_player) do
    Map.update(lobby, :players, MapSet.new([new_player]), &MapSet.put(&1, new_player))
  end

  @spec remove_player(Hanabi.Lobby.t(), String.t()) :: Hanabi.Lobby.t()
  def remove_player(%__MODULE__{} = lobby, player) do
    Map.update(lobby, :players, MapSet.new(), &MapSet.delete(&1, player))
  end

  @spec players(Hanabi.Lobby.t()) :: MapSet.t(String.t())
  def players(%__MODULE__{players: players}), do: players

  @spec start_game(Hanabi.Lobby.t()) :: Hanabi.Lobby.t()
  def start_game(%__MODULE__{players: players} = lobby) do
    game =
      MapSet.to_list(players)
      |> Game.new_game()

    %__MODULE__{lobby | game: game}
  end

  @spec tally(Hanabi.Lobby.t(), String.t()) :: Hanabi.Game.tally() | {:error, String.t()}
  def tally(%__MODULE__{game: nil}, _player_name) do
    :game_not_started
  end

  def tally(%__MODULE__{game: game}, player_name) do
    Game.tally(game, player_name)
  end

  @spec make_move(t(), String.t(), Hanabi.move()) :: {:ok, t()} | {:error, String.t()}
  def make_move(%__MODULE__{game: game} = lobby, player, {:hint_given, params}) do
    with {:ok, new_game} <- Game.give_hint(game, player, params.to, params.value) do
      {:ok, %__MODULE__{lobby | game: new_game}}
    end
  end

  def make_move(%__MODULE__{game: game} = lobby, player, {:play_tile, index}) do
    with {:ok, new_game} <- Game.play_tile(game, player, index) do
      {:ok, %__MODULE__{lobby | game: new_game}}
    end
  end

  def make_move(%__MODULE__{game: game} = lobby, player, {:discard_tile, index}) do
    with {:ok, new_game} <- Game.discard_tile(game, player, index) do
      {:ok, %__MODULE__{lobby | game: new_game}}
    end
  end
end
