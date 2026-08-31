defmodule VolcovlandWeb.BlogController do
  use VolcovlandWeb, :controller

  alias Volcovland.Blog

  def index(conn, _params) do
    posts = Blog.all_posts()

    render(conn, :index,
      posts: posts,
      page_title: "Blog",
      meta_description: "Notes on Elixir, theme parks, and whatever else I've been chewing on."
    )
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post_by_id!(id)

    render(conn, :show,
      post: post,
      page_title: post.title,
      meta_description: post.description,
      og_type: "article"
    )
  end
end
