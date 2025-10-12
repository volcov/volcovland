defmodule VolcovlandWeb.PageController do
  use VolcovlandWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
