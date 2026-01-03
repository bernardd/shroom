defmodule ShroomWeb.MapLive.Index do
  use ShroomWeb, :live_view

  alias Shroom.Sightings

  @impl true
  def mount(_params, _session, socket) do
    sightings = Sightings.list_sightings()

    socket =
      socket
      |> assign(:sightings, sightings)
      |> assign(:filtered_sightings, sightings)
      |> assign(:fungi_name_filter, "")
      |> assign(:selected_sighting, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"fungi_name" => fungi_name}, socket) do
    filtered_sightings =
      if fungi_name == "" do
        socket.assigns.sightings
      else
        Enum.filter(socket.assigns.sightings, fn sighting ->
          String.contains?(
            String.downcase(sighting.fungi_name),
            String.downcase(fungi_name)
          )
        end)
      end

    {:noreply,
     socket
     |> assign(:fungi_name_filter, fungi_name)
     |> assign(:filtered_sightings, filtered_sightings)
     |> push_event("update_markers", %{sightings: serialize_sightings(filtered_sightings)})}
  end

  @impl true
  def handle_event("select_sighting", %{"id" => id}, socket) do
    sighting = Enum.find(socket.assigns.sightings, &(&1.id == String.to_integer(id)))
    {:noreply, assign(socket, :selected_sighting, sighting)}
  end

  @impl true
  def handle_event("close_details", _params, socket) do
    {:noreply, assign(socket, :selected_sighting, nil)}
  end

  def serialize_sightings(sightings) do
    Enum.map(sightings, fn sighting ->
      %{
        id: sighting.id,
        fungi_name: sighting.fungi_name,
        location_name: sighting.location_name,
        lat: sighting.location.coordinates |> elem(1),
        lng: sighting.location.coordinates |> elem(0),
        notes: sighting.notes,
        sighted_at: Calendar.strftime(sighting.sighted_at, "%B %d, %Y")
      }
    end)
  end
end
