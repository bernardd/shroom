defmodule ShroomWeb.SightingLive.FormComponent do
  use ShroomWeb, :live_component

  alias Shroom.Sightings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="sighting-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:fungi_name]} type="text" label="Fungi Name" />
        <.input field={@form[:location_name]} type="text" label="Location Name" />

        <div class="grid grid-cols-2 gap-4">
          <.input
            field={@form[:latitude]}
            type="number"
            label="Latitude"
            step="0.000001"
            placeholder="e.g., -37.8136"
          />
          <.input
            field={@form[:longitude]}
            type="number"
            label="Longitude"
            step="0.000001"
            placeholder="e.g., 144.9631"
          />
        </div>

        <.input field={@form[:sighted_at]} type="datetime-local" label="Sighted At" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />

        <div class="mt-4">
          <label class="block text-sm font-semibold leading-6 text-zinc-900">
            Upload Photos
          </label>
          <div
            class="mt-2"
            phx-drop-target={@uploads.photos.ref}
          >
            <.live_file_input upload={@uploads.photos} class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-zinc-50 file:text-zinc-700 hover:file:bg-zinc-100" />
          </div>
          <p class="mt-2 text-sm text-gray-500">
            You can select up to 10 images (max 10MB each). Drag and drop or click to browse.
          </p>

          <%= for entry <- @uploads.photos.entries do %>
            <div class="mt-2 flex items-center gap-4">
              <div class="flex-1">
                <div class="text-sm text-gray-700"><%= entry.client_name %></div>
                <progress value={entry.progress} max="100" class="w-full"><%= entry.progress %>%</progress>
              </div>
              <button
                type="button"
                phx-click="cancel_upload"
                phx-value-ref={entry.ref}
                phx-target={@myself}
                class="text-red-600 hover:text-red-800"
              >
                Cancel
              </button>
            </div>
          <% end %>
        </div>

        <%= if @sighting.id && length(@sighting.photos || []) > 0 do %>
          <div class="mt-4">
            <label class="block text-sm font-semibold leading-6 text-zinc-900">
              Current Photos
            </label>
            <div class="mt-2 grid grid-cols-3 gap-4">
              <%= for photo <- @sighting.photos do %>
                <div class="relative">
                  <img
                    src={~p"/photos/#{photo.id}"}
                    alt={photo.filename || "Fungi photo"}
                    class="h-32 w-full object-cover rounded"
                  />
                  <button
                    type="button"
                    phx-click="delete_photo"
                    phx-value-id={photo.id}
                    phx-target={@myself}
                    class="absolute top-1 right-1 bg-red-600 text-white rounded-full p-1 hover:bg-red-700"
                  >
                    <.icon name="hero-x-mark-solid" class="size-4" />
                  </button>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Sighting</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{sighting: sighting} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Sightings.change_sighting(sighting))
     end)
     |> allow_upload(:photos,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 10,
       max_file_size: 10_000_000
     )}
  end

  @impl true
  def handle_event("validate", %{"sighting" => sighting_params}, socket) do
    changeset = Sightings.change_sighting(socket.assigns.sighting, sighting_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"sighting" => sighting_params}, socket) do
    save_sighting(socket, socket.assigns.action, sighting_params)
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  def handle_event("delete_photo", %{"id" => id}, socket) do
    photo = Sightings.get_photo!(id)
    {:ok, _} = Sightings.delete_photo(photo)

    sighting = Sightings.get_sighting!(socket.assigns.sighting.id)

    {:noreply,
     socket
     |> assign(:sighting, sighting)
     |> put_flash(:info, "Photo deleted successfully")}
  end

  defp save_sighting(socket, :edit, sighting_params) do
    sighting_params = prepare_params(sighting_params)

    case Sightings.update_sighting(socket.assigns.sighting, sighting_params) do
      {:ok, sighting} ->
        upload_photos(socket, sighting)
        notify_parent({:sighting_updated, sighting})

        {:noreply,
         socket
         |> put_flash(:info, "Sighting updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_sighting(socket, :new, sighting_params) do
    sighting_params = prepare_params(sighting_params)

    case Sightings.create_sighting(sighting_params) do
      {:ok, sighting} ->
        upload_photos(socket, sighting)
        notify_parent({:sighting_created, sighting})

        {:noreply,
         socket
         |> put_flash(:info, "Sighting created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp upload_photos(socket, sighting) do
    consume_uploaded_entries(socket, :photos, fn %{path: path}, entry ->
      {:ok, data} = File.read(path)

      Sightings.create_photo(sighting.id, %{
        data: data,
        content_type: entry.client_type,
        filename: entry.client_name,
        size: entry.client_size
      })

      {:ok, path}
    end)
  end

  defp prepare_params(params) do
    params
    |> convert_location_to_geometry()
  end

  defp convert_location_to_geometry(%{"latitude" => lat, "longitude" => lon} = params)
       when lat != "" and lon != "" do
    {lat_float, _} = Float.parse(lat)
    {lon_float, _} = Float.parse(lon)

    geometry = %Geo.Point{coordinates: {lon_float, lat_float}, srid: 4326}

    params
    |> Map.put("location", geometry)
    |> Map.delete("latitude")
    |> Map.delete("longitude")
  end

  defp convert_location_to_geometry(params), do: params

  defp notify_parent(msg), do: send(self(), msg)
end
