defmodule HanabiWeb.GameController do
  use HanabiWeb, :controller

  @no_game_message "It doesn't look like you're currently in a game, share this URL with your friends to start a new game!"

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, %{"id" => id, "player" => player}) do
    with true <- Hanabi.check_game(id, player) do
      conn
      |> put_session(:id, id)
      |> put_session(:player, player)
      |> live_render(HanabiWeb.GameLive)
    else
      _ ->
        conn
        |> delete_session(:id)
        |> delete_session(:player)
        |> put_flash(:error, @no_game_message)

        redirect(conn, to: Routes.lobby_path(conn, :index))
    end
  end

  def join(conn, _params) do
    with id when not is_nil(id) <- get_session(conn, :id),
         player when not is_nil(player) <- get_session(conn, :player),
         true <- Hanabi.check_game(id, player) do
      conn
      |> live_render(HanabiWeb.GameLive)
    else
      _ ->
        conn
        |> delete_session(:id)
        |> delete_session(:player)
        |> put_flash(:error, @no_game_message)

        redirect(conn, to: Routes.lobby_path(conn, :index))
    end
  end
end
