defmodule HanabiGameTest do
  use ExUnit.Case
  doctest Hanabi.Game, import: true

  alias Hanabi.{Game, Deck}

  test "new_game/0" do
    %Hanabi.Game{deck: deck} = Game.new_game()
    assert Deck.count(deck) == 60
  end
end
