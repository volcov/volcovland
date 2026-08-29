defmodule VolcovlandWeb.PageController do
  use VolcovlandWeb, :controller

  alias Volcovland.Blog

  # Ride tally shown on the home page. Bump these by hand after a park trip.
  @rides 196
  @parks 19

  @top_rides [
    %{name: "Jurassic World VelociCoaster", park: "Universal Islands of Adventure"},
    %{name: "Top Thrill 2", park: "Cedar Point"},
    %{name: "Mako", park: "SeaWorld Orlando"},
    %{name: "Millennium Force", park: "Cedar Point"},
    %{name: "Steel Vengeance", park: "Cedar Point"},
    %{name: "GateKeeper", park: "Cedar Point"},
    %{
      name: "Hagrid's Magical Creatures Motorbike Adventure",
      park: "Universal Islands of Adventure"
    },
    %{name: "Cheetah Hunt", park: "Busch Gardens Tampa"},
    %{name: "Dr. Diabolical's Cliffhanger", park: "Six Flags Fiesta Texas"},
    %{name: "The Incredible Hulk Coaster", park: "Universal Islands of Adventure"}
  ]

  def home(conn, _params) do
    render(conn, :home,
      latest_post: List.first(Blog.recent_posts(1)),
      rides: @rides,
      parks: @parks,
      top_rides: @top_rides
    )
  end
end
