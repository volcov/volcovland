defmodule VolcovlandWeb.PageControllerTest do
  use VolcovlandWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Bruno"
    assert html_response(conn, 200) =~ "volcovland"
  end

  test "GET / features the latest post", %{conn: conn} do
    post = hd(Volcovland.Blog.recent_posts(1))

    conn = get(conn, ~p"/")
    html = html_response(conn, 200)

    assert html =~ post.title
    assert html =~ ~p"/blog/#{post.id}"
  end
end
