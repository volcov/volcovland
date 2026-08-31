defmodule VolcovlandWeb.PageControllerTest do
  use VolcovlandWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Bruno"
    assert html_response(conn, 200) =~ "volcovland"
  end

  test "GET / renders the bare site title and default meta tags", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    assert html =~ ~r{<title[^>]*>\s*Volcovland\s*</title>}
    assert html =~ ~s(<meta name="description" content="My little world on the internet)
    assert html =~ ~s(<meta property="og:type" content="website")
    assert html =~ ~s(<meta property="og:image" content="http)
  end

  test "GET / features the latest post", %{conn: conn} do
    post = hd(Volcovland.Blog.recent_posts(1))

    conn = get(conn, ~p"/")
    html = html_response(conn, 200)

    assert html =~ post.title
    assert html =~ ~p"/blog/#{post.id}"
  end
end
