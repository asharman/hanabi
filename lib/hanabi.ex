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

  def stop_lobby(name) do
    LobbyServer.stop(name)
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

  @spec add_player_to_game(Ecto.UUID.t(), String.t()) :: :ok
  def add_player_to_game(name, new_player) do
    GameServer.add_player(name, new_player)
  end

  @spec remove_player_from_game(Ecto.UUID.t(), String.t()) :: :ok
  def remove_player_from_game(name, player) do
    GameServer.remove_player(name, player)
  end

  def new_game(name) do
    LobbyServer.new_game(name)
  end

  @spec check_game(Ecto.UUID.t(), String.t()) :: boolean()
  def check_game(id, player) do
    case Registry.lookup(Hanabi.GameRegistry, id) do
      [] ->
        IO.puts("COULD NOT FIND GAME WITH ID")
        false

      _ ->
        GameServer.player_in_game?(id, player)
    end
  end

  @spec get_tally(Ecto.UUID.t(), String.t()) :: Hanabi.Game.tally() | {:error, String.t()}
  def get_tally(id, player_name) do
    GameServer.get_tally(id, player_name)
  end

  @spec get_messages(Ecto.UUID.t()) :: list(String.t())
  def get_messages(id) do
    GameServer.get_messages(id)
  end

  @type move() ::
          {:hint_given,
           %{to: String.t(), value: Hanabi.Tile.tile_color() | Hanabi.Tile.tile_number()}}
          | {:discard_tile, non_neg_integer()}
          | {:play_tile, non_neg_integer()}
  @spec make_move(Ecto.UUID.t(), String.t(), move()) :: :ok | {:error, String.t()}
  def make_move(pid, player_name, move) do
    GameServer.make_move(pid, player_name, move)
  end
end
