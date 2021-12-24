defmodule Hanabi do
  alias Hanabi.Game

  @moduledoc """
  Hanabi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def new_game(players) do
    Game.new_game(players)
  end
end
