defmodule VolcovlandWeb.AboutController do
  use VolcovlandWeb, :controller

  def index(conn, _params) do
    render(conn, :index, page_title: "About me")
  end
end
