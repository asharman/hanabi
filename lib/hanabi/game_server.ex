defmodule Hanabi.GameServer do
  use GenServer
  alias Hanabi.Game

  def start_link([id, players]) do
    GenServer.start_link(__MODULE__, players, name: via_tuple(id))
  end

  # @spec players(String.t()) :: list(String.t())
  # def players(name) do
  #   GenServer.call(via_tuple(name), :players)
  # end

  def make_move(id, player, move) do
    GenServer.call(via_tuple(id), {:make_move, player, move})
  end

  # @spec add_player(String.t(), String.t()) :: :ok
  # def add_player(name, new_player) do
  #   GenServer.cast(via_tuple(name), {:add_player, new_player})
  # end

  # @spec remove_player(String.t(), String.t()) :: :ok
  # def remove_player(name, player) do
  #   GenServer.cast(via_tuple(name), {:remove_player, player})
  # end

  # @spec new_game(String.t()) :: :ok
  # def new_game(name) do
  #   GenServer.cast(via_tuple(name), :new_game)
  # end

  def get_tally(id, player_name) do
    GenServer.call(via_tuple(id), {:tally, player_name})
  end

  @impl GenServer
  def init(players) do
    game = Game.new_game(players)

    {:ok, game}
  end

  # @impl GenServer
  # def handle_call(:players, _from, lobby) do
  #   {:reply, MapSet.to_list(Lobby.players(lobby)), lobby}
  # end

  @impl GenServer
  def handle_call({:tally, player_name}, _from, game) do
    {:reply, Game.tally(game, player_name), game}
  end

  @impl GenServer
  def handle_call({:make_move, player, {:hint_given, params}}, _from, game) do
    case Game.give_hint(game, player, params.to, params.value) do
      {:ok, new_game} ->
        {:reply, :ok, new_game}

      error_response ->
        {:reply, error_response, game}
    end
  end

  def handle_call({:make_move, player, {:play_tile, index}}, _from, game) do
    case Game.play_tile(game, player, index) do
      {:ok, new_game} ->
        {:reply, :ok, new_game}

      error_response ->
        {:reply, error_response, game}
    end
  end

  def handle_call({:make_move, player, {:discard_tile, index}}, _from, game) do
    case Game.discard_tile(game, player, index) do
      {:ok, new_game} ->
        {:reply, :ok, new_game}

      error_response ->
        {:reply, error_response, game}
    end
  end

  # @impl GenServer
  # def handle_cast({:add_player, new_player}, lobby) do
  #   {:noreply, Lobby.add_player(lobby, new_player)}
  # end

  # @impl GenServer
  # def handle_cast({:remove_player, player}, lobby) do
  #   {:noreply, Lobby.remove_player(lobby, player)}
  # end

  # @impl GenServer
  # def handle_cast(:new_game, lobby) do
  #   {:noreply, Lobby.start_game(lobby)}
  # end

  defp via_tuple(id) do
    {:via, Registry, {Hanabi.GameRegistry, id}}
  end
end
