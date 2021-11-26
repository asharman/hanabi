defmodule HanabiWeb.PageController do
  use HanabiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
