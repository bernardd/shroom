defmodule ShroomWeb.SightingLive.Index do
  use ShroomWeb, :live_view

  alias Shroom.Sightings
  alias Shroom.Sightings.Sighting

  @impl true
  def mount(_params, _session, socket) do
    page = 1
    per_page = 20
    pagination = Sightings.list_sightings_paginated(page: page, per_page: per_page)

    {:ok,
     socket
     |> assign(:sightings, pagination.entries)
     |> assign(:search_params, %{})
     |> assign(:page, page)
     |> assign(:per_page, per_page)
     |> assign(:total_pages, pagination.total_pages)
     |> assign(:total_entries, pagination.total_entries)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Fungi Sightings")
    |> assign(:sighting, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Sighting")
    |> assign(:sighting, %Sighting{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Sighting")
    |> assign(:sighting, Sightings.get_sighting!(id))
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Sighting Details")
    |> assign(:sighting, Sightings.get_sighting!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    sighting = Sightings.get_sighting!(id)
    {:ok, _} = Sightings.delete_sighting(sighting)

    {:noreply, reload_sightings(socket)}
  end

  @impl true
  def handle_event("search", %{"search" => search_params}, socket) do
    pagination = Sightings.search_sightings_paginated(
      search_params,
      page: 1,
      per_page: socket.assigns.per_page
    )

    {:noreply,
     socket
     |> assign(:sightings, pagination.entries)
     |> assign(:search_params, search_params)
     |> assign(:page, 1)
     |> assign(:total_pages, pagination.total_pages)
     |> assign(:total_entries, pagination.total_entries)}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply, load_page(socket, page)}
  end

  @impl true
  def handle_event("change_per_page", %{"per_page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    {:noreply,
     socket
     |> assign(:per_page, per_page)
     |> load_page(1)}
  end

  @impl true
  def handle_info({:sighting_created, _sighting}, socket) do
    {:noreply, reload_sightings(socket)}
  end

  @impl true
  def handle_info({:sighting_updated, _sighting}, socket) do
    {:noreply, reload_sightings(socket)}
  end

  defp load_page(socket, page) do
    search_params = socket.assigns.search_params

    pagination =
      if map_size(search_params) == 0 do
        Sightings.list_sightings_paginated(page: page, per_page: socket.assigns.per_page)
      else
        Sightings.search_sightings_paginated(search_params, page: page, per_page: socket.assigns.per_page)
      end

    socket
    |> assign(:sightings, pagination.entries)
    |> assign(:page, page)
    |> assign(:total_pages, pagination.total_pages)
    |> assign(:total_entries, pagination.total_entries)
  end

  defp reload_sightings(socket) do
    load_page(socket, socket.assigns.page)
  end
end
