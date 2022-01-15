defmodule HanabiWeb.GameLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use HanabiWeb, :live_view
  import Ecto.Changeset
  @form_types %{username: :string}

  def mount(%{"name" => name}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Hanabi.PubSub, "lobby:#{name}")
    end

    Hanabi.start_lobby(name)
    players = Hanabi.lobby_players(name)

    changeset = change({%{}, @form_types})

    socket =
      socket
      |> assign(:players, players)
      |> assign(:name, name)
      |> assign(:changeset, changeset)

    {:ok, socket}
  end

  def handle_event("add_player", %{"player" => params}, socket) do
    with {:ok, %{username: new_player}} <- cast_params(params, @form_types),
         :ok <- Hanabi.add_player_to_lobby(socket.assigns.name, new_player) do
      Phoenix.PubSub.broadcast(Hanabi.PubSub, "lobby:#{socket.assigns.name}", :new_player)

      {:noreply, socket}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_info(:new_player, socket) do
    players = Hanabi.lobby_players(socket.assigns.name)
    {:noreply, assign(socket, :players, players)}
  end

  defp cast_params(form_data, type_map) do
    {%{}, type_map}
    |> cast(form_data, Map.keys(type_map))
    |> validate_required([:username])
    |> apply_action(:update)
  end
end
