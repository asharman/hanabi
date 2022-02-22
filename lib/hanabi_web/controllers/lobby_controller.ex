defmodule HanabiWeb.LobbyController do
  use HanabiWeb, :controller

  def index(conn, _params) do
    name = Hanabi.GameId.generate_id()
    redirect(conn, to: Routes.lobby_path(conn, :index, name))
  end
end
