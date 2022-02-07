defmodule HanabiWeb.GameController do
  use HanabiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, %{"id" => id, "player" => player}) do
    conn
    |> put_session(:player, player)
    |> live_render(HanabiWeb.GameLive, session: %{"id" => id})
  end

  def join(conn, %{"name" => name}) do
    live_render(conn, HanabiWeb.GameLive, session: %{"name" => name})
  end
end
