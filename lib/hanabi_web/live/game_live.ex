defmodule HanabiWeb.GameLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use HanabiWeb, :live_view
  alias HanabiWeb.LiveMonitor

  def mount(_params, %{"id" => id, "player" => current_player}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Hanabi.PubSub, "game:#{id}")
      # Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{name}", :players_updated)
    #   LiveMonitor.monitor(self(), __MODULE__, %{player: current_player, name: name})
    end

    tally = Hanabi.get_tally(id, current_player)

    # Hanabi.start_lobby(name)
    # Hanabi.add_player_to_lobby(name, current_player)
    # players = Hanabi.lobby_players(name)

    socket =
      socket
      |> assign(:username, current_player)
      |> assign(:game_state, tally)
      |> assign(:id, id)
      |> assign(:active_tile, nil)

    {:ok, socket}
  end

  # def handle_event("start_game", _, socket) do
  #   with {:ok, pid} <- Hanabi.new_game(socket.assigns.id) do
  #     Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{socket.assigns.id}", :game_updated)
  #     {:noreply, socket}
  #   else
  #     {:error, message} ->
  #       {:noreply, put_flash(socket, :error, message)}
  #   end
  # end

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
    tally = Hanabi.get_tally(socket.assigns.id, socket.assigns.username)
    {:noreply, assign(socket, :game_state, tally)}
  end

  def handle_info(:players_updated, socket) do
    players = Hanabi.lobby_players(socket.assigns.id)
    {:noreply, assign(socket, :players, players)}
  end

  def unmount(_reason, %{player: player, name: name}) do
    Hanabi.remove_player_from_lobby(name, player)
    Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{name}", :players_updated)
  end
end
