defmodule HanabiWeb.GameLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use HanabiWeb, :live_view
  alias HanabiWeb.LiveMonitor

  def mount(_params, %{"id" => id, "player" => current_player}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Hanabi.PubSub, "game:#{id}")
      LiveMonitor.monitor(self(), __MODULE__, %{player: current_player, id: id})
      Hanabi.add_player_to_game(id, current_player)
    end

    tally = Hanabi.get_tally(id, current_player)
    messages = Hanabi.get_messages(id)

    socket =
      socket
      |> assign(:username, current_player)
      |> assign(:game_state, tally)
      |> assign(:id, id)
      |> assign(:active_tile, nil)
      |> assign(:messages, messages)

    {:ok, socket}
  end

  def handle_event("hint_given", %{"player" => player, "hint" => hint}, socket) do
    with {:ok, hint} <- Hanabi.Tile.parse_value(hint),
         :ok <-
           Hanabi.make_move(
             socket.assigns.id,
             socket.assigns.username,
             {:hint_given, %{to: player, value: hint}}
           ) do
      Phoenix.PubSub.broadcast(Hanabi.PubSub, "game:#{socket.assigns.id}", :game_updated)
      {:noreply, assign(socket, :active_tile, nil)}
    else
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("play_tile", _, socket) do
    with :ok <-
           Hanabi.make_move(
             socket.assigns.id,
             socket.assigns.username,
             {:play_tile, socket.assigns.active_tile}
           ) do
      Phoenix.PubSub.broadcast(Hanabi.PubSub, "game:#{socket.assigns.id}", :game_updated)
      {:noreply, assign(socket, :active_tile, nil)}
    else
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("discard_tile", _, socket) do
    with :ok <-
           Hanabi.make_move(
             socket.assigns.id,
             socket.assigns.username,
             {:discard_tile, socket.assigns.active_tile}
           ) do
      Phoenix.PubSub.broadcast(Hanabi.PubSub, "game:#{socket.assigns.id}", :game_updated)
      {:noreply, assign(socket, :active_tile, nil)}
    else
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("select_tile", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, assign(socket, :active_tile, index)}
  end

  def handle_info(:game_updated, socket) do
    case Hanabi.get_tally(socket.assigns.id, socket.assigns.username) do
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}

      tally ->
        messages = Hanabi.get_messages(socket.assigns.id)

        if game_over?(tally) do
          {:noreply,
           socket
           |> assign(:game_state, tally)
           |> assign(:messages, messages)
           |> assign(:messages, [
             "Game Over! Your score is #{socket.assigns.game_state.score}"
             | socket.assigns.messages
           ])}
        else
          {:noreply,
           socket
           |> assign(:game_state, tally)
           |> assign(:messages, messages)}
        end
    end
  end

  def handle_info(:players_updated, socket) do
    players = Hanabi.lobby_players(socket.assigns.id)
    {:noreply, assign(socket, :players, players)}
  end

  def unmount(_reason, %{player: player, id: id}) do
    Hanabi.remove_player_from_game(id, player)
  end

  defp game_over?(%{state: :playing}), do: false
  defp game_over?(%{state: _other}), do: true
end
