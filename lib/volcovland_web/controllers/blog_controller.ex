defmodule VolcovlandWeb.BlogController do
  use VolcovlandWeb, :controller

  alias Volcovland.Blog

  def index(conn, _params) do
    posts = Blog.all_posts()
    render(conn, :index, posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post_by_id!(id)
    render(conn, :show, post: post)
  end
end
