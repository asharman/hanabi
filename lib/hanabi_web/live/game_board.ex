defmodule HanabiWeb.GameBoard do
  use Phoenix.Component

  @colors [
    :red,
    :green,
    :blue,
    :white,
    :yellow
  ]

  def player(assigns) do
    ~H"""
       <article class="player" current_player={assigns.current_player == assigns.player}>
        <div class="player-info">
          <h2><%= assigns.player %></h2>
        </div>
        <div class="hand">
        <%= if assigns.username == assigns.current_player do %>
        <div class="hint-buttons">
          <div class="hint-button-colors">
            <%= for color <- colors() do %>
              <button
                class="hint-button"
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
                class="hint-button"
                phx-click="hint_given"
                phx-value-player={assigns.player}
                phx-value-hint={number}>
                  <%= number %>
                </button>
            <% end %>
          </div>
        </div>
        <% end %>
        <%= for tile <- assigns.hand do %>
            <div class="hand-tile">
              <div
                color={tile.color}
                class={
                  string_join(
                    ["tile-square",
                    color_class(tile.color)
                    ],
                    " "
                  )}>
                  <p><%= tile.number %></p>
              </div>
              <.tile_hints tile={tile} />
            </div>
        <% end %>
        </div>
       </article>
    """
  end

  def tile_hints(assigns) do
    tile = assigns.tile

    ~H"""
    <div class="tile-hints">
      <ul class="tile-hints-color">
        <%= for color <- colors() do %>

          <li>
            <span
              color={color}
              tile_color={tile.color}
              hinted={tile_hinted?(color, tile)}
              class={color_class(color)}
              ></span>
          </li>
        <% end %>
      </ul>
      <ul class="tile-hints-number">
        <%= for number <- numbers() do %>
          <li>
            <span
              tile_number={tile.number}
              hinted={tile_hinted?(number, tile)}
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
    <p>Deck count: <%= assigns.game.deck %></p>

    <%= if is_client_current_player?(assigns) do %>
      <p>It's your turn! Make a move!</p>
    <% end %>

    <%= for {player, hand} <- assigns.game.players do %>
        <.player
          current_player={assigns.game.current_player}
          username={assigns.client_username}
          player={player}
          hand={hand}
        />
    <% end %>
    """
  end

  defp colors(), do: @colors
  defp numbers(), do: 1..5
  defp color_class(color), do: "color-" <> Atom.to_string(color)

  defp is_client_current_player?(%{
         client_username: username,
         game: %{current_player: current_player}
       }),
       do: username == current_player

  defp tile_hinted?(color, %{hints: %{color: color_hints}}) when color in @colors do
    MapSet.member?(color_hints, color)
  end

  defp tile_hinted?(number, %{hints: %{number: number_hints}}) when is_integer(number) do
    MapSet.member?(number_hints, number)
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
