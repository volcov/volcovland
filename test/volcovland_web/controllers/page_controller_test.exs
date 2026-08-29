defmodule VolcovlandWeb.PageControllerTest do
  use VolcovlandWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Bruno"
    assert html_response(conn, 200) =~ "volcovland"
  end

  test "GET / shows an empty state when there are no posts", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = html_response(conn, 200)

    if Volcovland.Blog.all_posts() == [] do
      assert html =~ "Nothing published yet"
    else
      assert html =~ Volcovland.Blog.recent_posts(1) |> hd() |> Map.fetch!(:title)
    end
  end
end
