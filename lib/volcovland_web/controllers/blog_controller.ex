defmodule VolcovlandWeb.BlogController do
  use VolcovlandWeb, :controller

  alias Volcovland.Blog

  def index(conn, _param) do
    render(conn, "index.html", posts: Blog.all_posts())
  end
end
