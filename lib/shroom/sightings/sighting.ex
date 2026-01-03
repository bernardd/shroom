defmodule Shroom.Sightings.Sighting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sightings" do
    field :fungi_name, :string
    field :location_name, :string
    field :location, Geo.PostGIS.Geometry
    field :sighted_at, :utc_datetime
    field :notes, :string

    has_many :photos, Shroom.Sightings.Photo

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sighting, attrs) do
    sighting
    |> cast(attrs, [:fungi_name, :location_name, :location, :sighted_at, :notes])
    |> validate_required([:sighted_at])
  end
end
