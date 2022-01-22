defmodule HanabiWeb.PageControllerTest do
  use HanabiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Hanabi!"
  end
end
