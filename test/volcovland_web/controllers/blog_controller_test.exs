defmodule VolcovlandWeb.BlogControllerTest do
  use VolcovlandWeb.ConnCase

  alias Volcovland.Blog

  setup do
    %{post: hd(Blog.all_posts())}
  end

  test "GET /blog lists published posts", %{conn: conn, post: post} do
    html = conn |> get(~p"/blog") |> html_response(200)

    assert html =~ post.title
    assert html =~ post.description
    assert html =~ ~p"/blog/#{post.id}"
    refute html =~ "Nothing published yet"
  end

  test "GET /blog/:id renders the post body", %{conn: conn, post: post} do
    html = conn |> get(~p"/blog/#{post.id}") |> html_response(200)

    assert html =~ post.title
    assert html =~ ~p"/blog"

    # NimblePublisher renders the markdown; makeup highlights the elixir blocks
    assert html =~ "<pre>"
    assert html =~ "Temper.Formatter"
  end
end
