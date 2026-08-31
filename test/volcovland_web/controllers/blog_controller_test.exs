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
    assert html =~ ~r{<title[^>]*>\s*Blog · Volcovland\s*</title>}
  end

  test "GET /blog/:id renders the post body", %{conn: conn, post: post} do
    html = conn |> get(~p"/blog/#{post.id}") |> html_response(200)

    assert html =~ post.title
    assert html =~ ~p"/blog"

    # NimblePublisher renders the markdown; makeup highlights the elixir blocks
    assert html =~ "<pre>"
    assert html =~ "Temper.Formatter"
  end

  test "GET /blog/:id carries the post's title and description in the meta tags",
       %{conn: conn, post: post} do
    html = conn |> get(~p"/blog/#{post.id}") |> html_response(200)

    assert html =~ ~r{<title[^>]*>\s*#{Regex.escape(post.title)} · Volcovland\s*</title>}

    assert html =~
             ~s(<meta name="description" content="#{Plug.HTML.html_escape(post.description)}")

    assert html =~ ~s(<meta property="og:title" content="#{Plug.HTML.html_escape(post.title)}")
    assert html =~ ~s(<meta property="og:type" content="article")
    assert html =~ ~s(<meta property="og:url" content="http)
  end
end
