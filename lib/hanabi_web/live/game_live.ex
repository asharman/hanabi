defmodule HanabiWeb.GameLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use HanabiWeb, :live_view
  alias HanabiWeb.LiveMonitor

  def mount(_params, %{"name" => name, "player" => current_player}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Hanabi.PubSub, "lobby:#{name}")
      Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{name}", :players_updated)
      LiveMonitor.monitor(self(), __MODULE__, %{player: current_player, name: name})
    end

    Hanabi.start_lobby(name)
    Hanabi.add_player_to_lobby(name, current_player)
    players = Hanabi.lobby_players(name)

    socket =
      socket
      |> assign(:username, current_player)
      |> assign(:players, players)
      |> assign(:name, name)

    {:ok, socket}
  end

  def handle_info(:players_updated, socket) do
    players = Hanabi.lobby_players(socket.assigns.name)
    {:noreply, assign(socket, :players, players)}
  end

  def unmount(_reason, %{player: player, name: name}) do
    Hanabi.remove_player_from_lobby(name, player)
    Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{name}", :players_updated)
  end
end
