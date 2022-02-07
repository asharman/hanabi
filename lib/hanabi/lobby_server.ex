defmodule Hanabi.LobbyServer do
  use GenServer
  alias Hanabi.Lobby
  alias Hanabi.GameServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @spec players(String.t()) :: list(String.t())
  def players(name) do
    GenServer.call(via_tuple(name), :players)
  end

  # def make_move(name, player, move) do
  #   GenServer.call(via_tuple(name), {:make_move, player, move})
  # end

  @spec add_player(String.t(), String.t()) :: :ok
  def add_player(name, new_player) do
    GenServer.cast(via_tuple(name), {:add_player, new_player})
  end

  @spec remove_player(String.t(), String.t()) :: :ok
  def remove_player(name, player) do
    GenServer.cast(via_tuple(name), {:remove_player, player})
  end

  @spec new_game(String.t()) :: :ok
  def new_game(name) do
    GenServer.call(via_tuple(name), :new_game)
  end

  # def get_tally(name, player_name) do
  #   GenServer.call(via_tuple(name), {:tally, player_name})
  # end

  @impl GenServer
  def init(name) do
    lobby = Lobby.new_room(name)

    {:ok, lobby}
  end

  @impl GenServer
  def handle_call(:players, _from, lobby) do
    {:reply, MapSet.to_list(Lobby.players(lobby)), lobby}
  end

  @impl GenServer
  def handle_call(:new_game, _from, lobby) do
    id = Ecto.UUID.generate()

    players =
      Lobby.players(lobby)
      |> MapSet.to_list()

    case DynamicSupervisor.start_child(Hanabi.GameSupervisor, {GameServer, [id, players]}) do
      {:ok, _} ->
        {:reply, {:ok, id}, lobby}

      error ->
        {:reply, error, lobby}
    end
  end

  @impl GenServer
  def handle_call({:tally, player_name}, _from, lobby) do
    {:reply, Lobby.tally(lobby, player_name), lobby}
  end

  @impl GenServer
  def handle_call({:make_move, player, move}, _from, lobby) do
    case Lobby.make_move(lobby, player, move) do
      {:ok, new_lobby} ->
        {:reply, :ok, new_lobby}

      error_response ->
        {:reply, error_response, lobby}
    end
  end

  @impl GenServer
  def handle_cast({:add_player, new_player}, lobby) do
    {:noreply, Lobby.add_player(lobby, new_player)}
  end

  @impl GenServer
  def handle_cast({:remove_player, player}, lobby) do
    {:noreply, Lobby.remove_player(lobby, player)}
  end

  defp via_tuple(name) do
    {:via, Registry, {Hanabi.LobbyRegistry, name}}
  end
end
