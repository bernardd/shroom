defmodule ShroomWeb.SightingLive.Show do
  use ShroomWeb, :live_view

  alias Shroom.Sightings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    sighting = Sightings.get_sighting!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Sighting Details")
     |> assign(:sighting, sighting)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sighting = Sightings.get_sighting!(id)
    {:ok, _} = Sightings.delete_sighting(sighting)

    {:noreply,
     socket
     |> put_flash(:info, "Sighting deleted successfully")
     |> push_navigate(to: ~p"/sightings")}
  end
end
