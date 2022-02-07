defmodule HanabiWeb.LobbyLive do
  use HanabiWeb, :live_view
  alias HanabiWeb.LiveMonitor
  import Ecto.Changeset
  @form_types %{username: :string}

  def mount(%{"name" => name}, _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Hanabi.PubSub, "lobby:#{name}")
      # Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{name}", :players_updated)

      # LiveMonitor.monitor(self(), __MODULE__, %{player: socket.assigns.current_player, name: name})
    end

    Hanabi.start_lobby(name)

    # unless is_nil(socket.assigns.player) do
    #   Hanabi.add_player_to_lobby(name, socket.assigns.player)
    # end

    players = Hanabi.lobby_players(name)
    changeset = change({%{}, @form_types})

    socket =
      socket
      |> assign(:players, players)
      |> assign(:changeset, changeset)
      |> assign(:current_player, nil)
      |> assign(:name, name)

    {:ok, socket}
  end

  def handle_event("player_join", %{"player" => player_params}, socket) do
    case cast_params(player_params, @form_types) do
      {:ok, %{username: new_player}} ->
        unless is_nil(socket.assigns.current_player) do
          Hanabi.remove_player_from_lobby(socket.assigns.name, socket.assigns.current_player)
        end

        Hanabi.add_player_to_lobby(socket.assigns.name, new_player)
        LiveMonitor.monitor(self(), __MODULE__, %{player: new_player, name: socket.assigns.name})

        Phoenix.PubSub.broadcast(
          Hanabi.PubSub,
          "lobby:#{socket.assigns.name}",
          :players_updated
        )

        {:noreply,
         socket
         |> put_flash(:info, "#{new_player} joined the #{socket.assigns.name} lobby")
         |> assign(:current_player, new_player)}
    end
  end

  def handle_event("start_game", _, socket) do
    with {:ok, id} <- Hanabi.new_game(socket.assigns.name) do
      Phoenix.PubSub.broadcast(
        Hanabi.PubSub,
        "lobby:#{socket.assigns.name}",
        {:game_started, id}
      )

      {:noreply, socket}
    else
      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_info({:game_started, pid}, socket) do
    {:noreply,
     redirect(socket,
       to: Routes.game_path(HanabiWeb.Endpoint, :join, pid, player: socket.assigns.current_player)
     )}
  end

  def handle_info(:players_updated, socket) do
    players = Hanabi.lobby_players(socket.assigns.name)
    {:noreply, assign(socket, :players, players)}
  end

  def unmount(_reason, %{player: player, name: name}) do
    Hanabi.remove_player_from_lobby(name, player)
    Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{name}", :players_updated)
  end

  defp cast_params(form_data, type_map) do
    {%{}, type_map}
    |> cast(form_data, Map.keys(type_map))
    |> validate_required([:username])
    |> apply_action(:update)
  end
end
