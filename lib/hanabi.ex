defmodule Hanabi do
  alias Hanabi.LobbyServer
  alias Hanabi.GameServer

  @moduledoc """
  Hanabi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def start_lobby(name) do
    DynamicSupervisor.start_child(Hanabi.LobbySupervisor, {LobbyServer, name})
  end

  @spec lobby_players(String.t()) :: list(String.t())
  def lobby_players(name) do
    LobbyServer.players(name)
  end

  @spec add_player_to_lobby(String.t(), String.t()) :: :ok
  def add_player_to_lobby(name, new_player) do
    LobbyServer.add_player(name, new_player)
  end

  @spec remove_player_from_lobby(String.t(), String.t()) :: :ok
  def remove_player_from_lobby(name, player) do
    LobbyServer.remove_player(name, player)
  end

  # @spec new_game(String.t()) :: :ok
  def new_game(name) do
    LobbyServer.new_game(name)
  end

  @spec get_tally(Ecto.UUID.t(), String.t()) :: Hanabi.Game.tally() | {:error, String.t()} | nil
  def get_tally(id, player_name) do
    GameServer.get_tally(id, player_name)
  end

  @type move() ::
          {:hint_given, %{to: String.t(), value: Hanabi.Tile.tile_color() | Hanabi.Tile.tile_number()}}
          | {:discard_tile, non_neg_integer()}
          | {:play_tile, non_neg_integer()}
  @spec make_move(pid(), String.t(), move()) :: :ok | {:error, String.t()}
  def make_move(pid, player_name, move) do
    GameServer.make_move(pid, player_name, move)
  end
end
