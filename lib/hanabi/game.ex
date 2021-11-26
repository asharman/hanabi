defmodule Hanabi.Game do
  alias Hanabi.Deck

  defstruct([:deck, :players])

  @spec new_game :: %Hanabi.Game{deck: Deck.t()}
  def new_game() do
    %__MODULE__{deck: Deck.init()}
  end
end
