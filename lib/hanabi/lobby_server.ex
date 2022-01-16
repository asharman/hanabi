defmodule Hanabi.LobbyServer do
  use GenServer
  alias Hanabi.Lobby

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @spec players(String.t()) :: list(String.t())
  def players(name) do
    GenServer.call(via_tuple(name), :players)
  end

  @spec add_player(String.t(), String.t()) :: :ok
  def add_player(name, new_player) do
    GenServer.cast(via_tuple(name), {:add_player, new_player})
  end

  @spec remove_player(String.t(), String.t()) :: :ok
  def remove_player(name, player) do
    GenServer.cast(via_tuple(name), {:remove_player, player})
  end

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
