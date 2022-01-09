defmodule Hanabi.Game do
  @moduledoc """
  Represents the state of the game.
  The game is an opaque type and the only way to create one is to call new_game/1
  """
  alias Hanabi.Deck
  alias Hanabi.Player
  alias Hanabi.Tile

  defstruct([
    :deck,
    :players,
    :board,
    :discard_pile,
    :strikes,
    :hint_count,
    :message,
    :current_player
  ])

  @opaque t() :: %__MODULE__{
            deck: Deck.t(),
            players: list(Player.t()),
            board: board(),
            discard_pile: discard_pile(),
            strikes: 0 | 1 | 2,
            hint_count: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8,
            current_player: String.t(),
            message: String.t()
          }

  @typep board :: %{Tile.tile_color() => MapSet.t(Tile.tile_number())}
  @typep discard_pile :: %{Tile.tile_color() => list(Tile.tile_number())}
  @type tally :: %{
          deck: non_neg_integer(),
          hand: list(Tile.tile_hints()),
          players: %{String.t() => list(Tile.t())},
          board: board(),
          discard_pile: discard_pile(),
          strikes: 0 | 1 | 2,
          hint_count: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8,
          current_player: String.t(),
          message: String.t()
        }

  @spec new_game(list(String.t())) :: Hanabi.Game.t()
  def new_game([first_player | _] = players) do
    deck = Deck.init()

    {updated_deck, initial_players} =
      Enum.reduce(players, {deck, []}, fn username, {deck_acc, player_acc} ->
        {new_deck, new_player} = create_player(username, deck_acc)

        {new_deck, [new_player | player_acc]}
      end)

    %__MODULE__{
      deck: updated_deck,
      players: initial_players,
      board: initial_board(),
      discard_pile: initial_discard_pile(),
      strikes: 0,
      hint_count: 8,
      current_player: first_player,
      message: "Welcome to Hanabi!"
    }
  end

  # Used for testing a non-random deck
  @doc false
  def new_game([first_player | _] = players, deck) do
    deck = Deck.init(deck)

    {updated_deck, initial_players} =
      Enum.reduce(players, {deck, []}, fn username, {deck_acc, player_acc} ->
        {new_deck, new_player} = create_player(username, deck_acc)

        {new_deck, [new_player | player_acc]}
      end)

    %__MODULE__{
      deck: updated_deck,
      players: initial_players,
      board: initial_board(),
      discard_pile: initial_discard_pile(),
      strikes: 0,
      hint_count: 8,
      current_player: first_player,
      message: "Welcome to Hanabi!"
    }
  end

  @spec tally(Hanabi.Game.t(), String.t()) :: tally() | {:error, String.t()}
  def tally(game, username) do
    with {:ok, player} <- fetch_player(game, username) do
      players =
        Enum.filter(game.players, &(Player.username(&1) != username))
        |> Enum.into(%{}, fn p -> {Player.username(p), Player.hand(p)} end)

      %{
        game
        | players: players,
          deck: Deck.count(game.deck)
      }
      |> Map.put(:hand, Enum.map(Player.hand(player), &Tile.tally/1))
    end
  end

  @spec play_tile(Hanabi.Game.t(), String.t(), non_neg_integer()) :: Hanabi.Game.t()
  def play_tile(game, player_username, position) do
    with {:ok, player} <- fetch_player(game, player_username),
         {:ok, tile, updated_player} <- Player.take_tile(player, position) do
      {new_deck, tiles} = Deck.draw_tiles(game.deck, 1)

      updated_player = Enum.reduce(tiles, updated_player, &Player.deal_tile/2)

      new_players = update_players(game, updated_player)

      case add_tile_to_board(game.board, tile) do
        {:ok, new_board} ->
          %__MODULE__{
            game
            | board: new_board,
              players: new_players,
              deck: new_deck,
              current_player: next_player(game)
          }

        {:error, _reason} ->
          new_discard_pile =
            Map.update(
              game.discard_pile,
              Tile.color(tile),
              [Tile.number(tile)],
              &[Tile.number(tile) | &1]
            )

          %__MODULE__{
            game
            | players: new_players,
              current_player: next_player(game),
              deck: new_deck,
              strikes: game.strikes + 1,
              discard_pile: new_discard_pile
          }
      end
    end
  end

  @spec give_hint(
          Hanabi.Game.t(),
          String.t(),
          String.t(),
          Hanabi.Tile.tile_color() | Hanabi.Tile.tile_number()
        ) :: Hanabi.Game.t()
  def give_hint(%__MODULE__{hint_count: 0} = game, _hinting_player, _hinted_player, _value) do
    %__MODULE__{
      game
      | message: "There are no hints left, choose another action"
    }
  end

  def give_hint(game, hinting_player, hinted_player, value) do
    with {:ok, player_receiving_hint} <- fetch_player(game, hinted_player) do
      updated_player = Player.give_hint(player_receiving_hint, value)

      new_players = update_players(game, updated_player)

      %__MODULE__{
        game
        | players: new_players,
          hint_count: game.hint_count - 1,
          current_player: next_player(game),
          message: "#{hinting_player} hinted #{hinted_player} #{value}"
      }
    end
  end

  @spec create_player(String.t(), Deck.t()) :: {Deck.t(), Player.t()}
  defp create_player(username, deck) do
    {new_deck, tile_list} = Deck.draw_tiles(deck, 5)
    {new_deck, Player.init(username, tile_list)}
  end

  @spec add_tile_to_board(board(), Hanabi.Tile.t()) :: {:ok, board()} | {:error, String.t()}
  defp add_tile_to_board(board, tile) do
    tile_color = Tile.color(tile)
    tile_number = Tile.number(tile)
    tile_set = Map.get(board, tile_color, MapSet.new())

    cond do
      tile_number == 1 and MapSet.size(tile_set) == 0 ->
        {:ok, Map.update(board, tile_color, MapSet.new(), &MapSet.put(&1, tile_number))}

      MapSet.member?(tile_set, tile_number - 1) and !MapSet.member?(tile_set, tile_number) ->
        {:ok, Map.update(board, tile_color, MapSet.new(), &MapSet.put(&1, tile_number))}

      true ->
        {:error, "Invalid Tile"}
    end
  end

  @spec fetch_player(Hanabi.Game.t(), String.t()) ::
          {:ok, Hanabi.Player.t()} | {:error, String.t()}
  defp fetch_player(%__MODULE__{players: players}, player_username) do
    case Enum.find(players, &(Player.username(&1) == player_username)) do
      nil ->
        {:error, "Could not find a player with the username #{player_username}"}

      player ->
        {:ok, player}
    end
  end

  defp update_players(game, updated_player) do
    Enum.map(game.players, fn player ->
      if Player.username(player) == Player.username(updated_player),
        do: updated_player,
        else: player
    end)
  end

  @spec next_player(Hanabi.Game.t()) :: String.t()
  defp next_player(%__MODULE__{current_player: current_player, players: players}) do
    current_player_index = Enum.find_index(players, &(Player.username(&1) == current_player))

    if current_player_index == length(players) - 1 do
      List.first(players)
      |> Player.username()
    else
      players
      |> Enum.with_index()
      |> Enum.find(fn {_, index} -> index - 1 == current_player_index end)
      |> elem(0)
      |> Player.username()
    end
  end

  defp initial_board() do
    %{
      red: MapSet.new(),
      green: MapSet.new(),
      blue: MapSet.new(),
      yellow: MapSet.new(),
      white: MapSet.new(),
      rainbow: MapSet.new()
    }
  end

  defp initial_discard_pile() do
    %{
      red: [],
      green: [],
      blue: [],
      yellow: [],
      white: [],
      rainbow: []
    }
  end
end
