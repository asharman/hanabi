defmodule HanabiWeb.GameBoard do
  use Phoenix.Component

  @hintable_colors [
    :red,
    :green,
    :blue,
    :white,
    :yellow
  ]

  @colors @hintable_colors ++ [:rainbow]

  def player(assigns) do
    {player, hand} = assigns.player
    # hand = get_player_hand(assigns.player, assigns.game)

    ~H"""
       <article class="player" current_player={assigns.game.current_player == player}>
        <div class="player-info">
          <h2><%= player %></h2>
        </div>
        <div class="hand">
        <%= if assigns.username == assigns.game.current_player and assigns.username != player do %>
          <.hint_buttons player={player} />
        <% end %>
        <%= if assigns.username == assigns.game.current_player and assigns.username == player do %>
          <div>
            <button
              class="action-button"
              phx-click="play_tile"
             >
              Play Tile
            </button>
            <button
              class="action-button"
              phx-click="discard_tile"
             >
              Discard Tile
            </button>
          </div>
        <% end %>
        <%= if player == assigns.username do %>
        <%= for {tile, index} <- Enum.with_index(hand) do %>
            <div class="hand-tile">
              <%= if assigns.username == assigns.game.current_player and assigns.username == player do %>
                <button
                  class="tile-square"
                  phx-click="select_tile"
                  phx-value-index={index}
                  active={assigns.active_tile == index}
                >
                  <span class="visually-hidden">Select Tile</span>
                </button>
                <.tile_hints possible_values={get_possible_values(tile)} />
              <% else %>
                <div
                  class="tile-square"
                >
                </div>
                <.tile_hints possible_values={get_possible_values(tile)} />
              <% end %>
            </div>
        <% end %>
        <% else %>
        <%= for tile <- hand do %>
            <div class="hand-tile">
              <div
                color={Hanabi.Tile.color(tile)}
                class={
                  string_join(
                    ["tile-square",
                    color_class(Hanabi.Tile.color(tile))
                    ],
                    " "
                  )}>
                  <p><%= Hanabi.Tile.number(tile) %></p>
              </div>
              <.tile_hints possible_values={get_possible_values(tile)} />
            </div>
        <% end %>
        <% end %>
        </div>
       </article>
    """
  end

  def hint_buttons(assigns) do
    ~H"""
      <div class="hint-buttons">
        <div class="hint-button-colors">
          <%= for color <- hintable_colors() do %>
            <button
              class="action-button"
              phx-click="hint_given"
              phx-value-player={assigns.player}
              phx-value-hint={color}>
                <%= color %>
              </button>
          <% end %>
        </div>
        <div class="hint-button-numbers">
          <%= for number <- numbers() do %>
            <button
              class="action-button"
              phx-click="hint_given"
              phx-value-player={assigns.player}
              phx-value-hint={number}>
                <%= number %>
              </button>
          <% end %>
        </div>
      </div>
    """
  end

  def tile_hints(assigns) do
    possible_values = assigns.possible_values

    ~H"""
    <div class="tile-hints">
      <ul class="tile-hints-color">
        <%= for color <- colors() do %>
          <li>
            <span
              color={color}
              possible_value={possible_value?(color, possible_values)}
              class={color_class(color)}
              ></span>
          </li>
        <% end %>
      </ul>
      <ul class="tile-hints-number">
        <%= for number <- numbers() do %>
          <li>
            <span
              tile_number={number}
              possible_value={possible_value?(number, possible_values)}
            >
                <%= number %>
            </span>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def board(assigns) do
    ~H"""
    <div class="game-info">
      <div class="game-messages">
        <%= for message <- Enum.reverse(assigns.messages) do %>
          <p><%= message %></p>
        <% end %>
      </div>
      <div class="deck-and-hints">
        <p class="deck"><span>Deck</span><span><%= assigns.game.deck %></span></p>
        <div >
          <p>Hints: <%= assigns.game.hint_count %></p>
          <p>Strikes: <%= assigns.game.strikes %></p>
        </div>
      </div>
      <div>
        <h2>Board</h2>
      <div class="board">
        <%= for {color, number} <- view_board(assigns.game.board) do %>
	        <div class={
          string_join([
          "board-tile",
          color_class(color)
        ], " ")
        }>
          <span><%= number %></span>
        </div>
      <% end %>
      </div>
    </div>
      <div class="discard">
        <h2>Discard</h2>
      <div class="discard-tiles">
        <%= for {color, numbers} <- view_discard(assigns.game.discard_pile) do %>
        <div class="discard-color-group">
        <%= for number <- numbers do %>
	        <div class={
          string_join([
          "discard-tile",
          color_class(color)
        ], " ")
        }>
          <span><%= number %></span>
        </div>
      <% end %>
      </div>
      <% end %>
      </div>
    </div>
    </div>
    <div>
    <%= for player <- assigns.game.players do %>
        <.player
          game={assigns.game}
          username={assigns.client_username}
          player={player}
          active_tile={assigns.active_tile}
        />
    <% end %>
    </div>
    """
  end

  defp hintable_colors(), do: @hintable_colors
  defp colors(), do: @colors
  defp numbers(), do: 1..5
  defp color_class(color), do: "color-" <> Atom.to_string(color)

  defp possible_value?(color, %{color: color_hints}) when color in @colors do
    MapSet.member?(color_hints, color)
  end

  defp possible_value?(number, %{number: number_hints}) when is_integer(number) do
    MapSet.member?(number_hints, number)
  end

  @spec get_possible_values(Hanabi.Tile.t()) :: Hanabi.Tile.tile_hints()
  defp get_possible_values(tile) do
    Hanabi.Tile.possible_values(tile)
  end

  @spec get_player_hand(String.t(), Hanabi.Game.tally()) :: list(Hanabi.Tile.t())
  defp get_player_hand(player, game) do
      Map.get(game.players, player)
  end

  defp view_board(board) do
	  Enum.map(board, fn {color, numbers} ->
      {color, MapSet.to_list(numbers) |> Enum.max(fn -> nil end)}
    end)
  end

  defp view_discard(discard) do
	  Enum.map(discard, fn {color, numbers} ->
      {color, Enum.sort(numbers)}
    end)
  end

  def string_join(strings, seperator) do
    Enum.reduce(strings, {strings, ""}, fn
      string, {strings_acc, acc} when length(strings_acc) == 1 ->
        new_acc =
          acc
          |> Kernel.<>(string)

        {[], new_acc}

      string, {[string | rest], acc} ->
        new_acc =
          acc
          |> Kernel.<>(string)
          |> Kernel.<>(seperator)

        {rest, new_acc}
    end)
    |> elem(1)
  end
end
