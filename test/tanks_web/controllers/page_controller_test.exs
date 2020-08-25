defmodule TanksWeb.PageControllerTest do
  use TanksWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Tanks"
  end
end
