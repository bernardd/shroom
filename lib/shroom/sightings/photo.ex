defmodule Shroom.Sightings.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :data, :binary
    field :content_type, :string
    field :filename, :string
    field :caption, :string
    field :size, :integer

    belongs_to :sighting, Shroom.Sightings.Sighting

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:data, :content_type, :filename, :caption, :size, :sighting_id])
    |> validate_required([:data, :content_type, :sighting_id])
    |> validate_content_type()
  end

  defp validate_content_type(changeset) do
    case get_field(changeset, :content_type) do
      nil ->
        changeset

      content_type ->
        if String.starts_with?(content_type, "image/") do
          changeset
        else
          add_error(changeset, :content_type, "must be an image")
        end
    end
  end
end
