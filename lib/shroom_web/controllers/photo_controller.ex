defmodule ShroomWeb.PhotoController do
  use ShroomWeb, :controller

  alias Shroom.Sightings

  def show(conn, %{"id" => id}) do
    photo = Sightings.get_photo!(id)

    conn
    |> put_resp_content_type(photo.content_type)
    |> put_resp_header("cache-control", "public, max-age=31536000")
    |> send_resp(200, photo.data)
  end
end
