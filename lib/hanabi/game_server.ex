defmodule Hanabi.GameServer do
  use GenServer, restart: :transient
  alias Hanabi.Game

  @type state :: %{
          game: Hanabi.Game.t(),
          messages: list(String.t()),
          players: MapSet.t(String.t())
        }

  def start_link([id, players]) do
    GenServer.start_link(__MODULE__, players, name: via_tuple(id))
  end

  def make_move(id, player, move) do
    GenServer.call(via_tuple(id), {:make_move, player, move})
  end

  def player_in_game?(id, player) do
    GenServer.call(via_tuple(id), {:player_in_game, player})
  end

  def get_messages(id) do
    GenServer.call(via_tuple(id), {:get_messages})
  end

  @spec add_player(String.t(), String.t()) :: :ok
  def add_player(id, new_player) do
    GenServer.cast(via_tuple(id), {:add_player, new_player})
  end

  @spec remove_player(String.t(), String.t()) :: :ok
  def remove_player(id, player) do
    GenServer.cast(via_tuple(id), {:remove_player, player})
  end

  def get_tally(id, player_name) do
    GenServer.call(via_tuple(id), {:tally, player_name})
  end

  @impl GenServer
  def init(players) do
    game = Game.new_game(players)

    {:ok, %{game: game, players: MapSet.new(), messages: []}}
  end

  @impl GenServer
  def handle_call({:tally, player_name}, _from, %{game: game} = state) do
    {:reply, Game.tally(game, player_name), state}
  end

  @impl GenServer
  def handle_call({:make_move, player, {:hint_given, params}}, _from, %{game: game} = state) do
    create_response(Game.give_hint(game, player, params.to, params.value), state)
  end

  @impl GenServer
  def handle_call({:make_move, player, {:play_tile, index}}, _from, %{game: game} = state) do
    create_response(Game.play_tile(game, player, index), state)
  end

  @impl GenServer
  def handle_call({:make_move, player, {:discard_tile, index}}, _from, %{game: game} = state) do
    create_response(Game.discard_tile(game, player, index), state)
  end

  @impl GenServer
  def handle_call({:player_in_game, player}, _from, %{game: game} = state) do
	  {:reply, Game.player_in_game?(game, player), state}
  end

  @impl GenServer
  def handle_call({:get_messages}, _from, %{messages: msg} = state) do
    {:reply, msg, state}
  end

  @impl GenServer
  def handle_cast({:add_player, new_player}, state) do
    {:noreply, %{state | players: MapSet.put(state.players, new_player)}}
  end

  @impl GenServer
  def handle_cast({:remove_player, player}, state) do
    {:noreply, %{state | players: MapSet.delete(state.players, player)}}
  end

  @impl GenServer
  def handle_info(:shutdown, state) do
    if MapSet.size(state.players) == 0 do
      {:stop, :normal, state}
    else
      Process.send_after(self(), :shutdown, 1000 * 60)
      {:noreply, state}
    end
  end

  defp create_response({:ok, new_game}, state) do
    check_game_over(new_game)
    new_messages = [Game.message(new_game) | state.messages]

    {:reply, :ok, %{state | game: new_game, messages: new_messages}}
  end

  defp create_response(error_response, state) do
    {:reply, error_response, state}
  end

  defp check_game_over(game) do
    if Game.game_over?(game) do
      Process.send_after(self(), :shutdown, 1000 * 60)
      game
    else
      game
    end
  end

  defp via_tuple(id) do
    {:via, Registry, {Hanabi.GameRegistry, id}}
  end
end
