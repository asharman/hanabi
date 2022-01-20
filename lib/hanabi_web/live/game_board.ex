defmodule HanabiWeb.GameBoard do
  use Phoenix.Component

  def players(assigns) do
    players = assigns.players
    ~H"""
    <ul>
    <%= for {player, hand} <- players do %>
       <li>
        <p><%= player %></p>
        <%= for tile <- hand do %>
            <div>
            <p><%= tile.color %> <%= tile.number %></p>
            </div>
        <% end %>
       </li>
    <% end %>
    </ul>
    """
  end

  def board(assigns) do
    ~H"""
    <p>Deck count: <%= assigns.game.deck %></p>

    <.players players={assigns.game.players}/>
    """
  end
end
