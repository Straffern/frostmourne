defmodule FrostmourneWeb.MainLive do
  use Surface.LiveView
  use FrostmourneWeb, :surface_view_helpers



  @impl true
  def render(assigns) do
    ~H"""
    <FrostmourneWeb.NavBar/>
    """
  end


end
