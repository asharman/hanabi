defmodule Hanabi do
  alias Hanabi.Game
  alias Hanabi.LobbyServer

  @moduledoc """
  Hanabi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def new_game(players) do
    Game.new_game(players)
  end

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
end
