defmodule Hanabi do
  alias Hanabi.LobbyServer

  @moduledoc """
  Hanabi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def start_lobby(name) do
    LobbyServer.start_link(name)
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

  @spec new_game(String.t()) :: :ok
  def new_game(name) do
    LobbyServer.new_game(name)
  end

  @spec get_tally(String.t(), String.t()) :: Hanabi.Game.tally() | {:error, String.t()} | nil
  def get_tally(lobby_name, player_name) do
    case LobbyServer.get_tally(lobby_name, player_name) do
      :game_not_started ->
        nil
      tally ->
        tally
    end
  end
end
