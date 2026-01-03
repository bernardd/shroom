defmodule Shroom.Repo.Migrations.CreateSightings do
  use Ecto.Migration

  def change do
    create table(:sightings) do
      add :fungi_name, :text
      add :location_name, :text
      add :location, :geometry
      add :photo_url, :text
      add :sighted_at, :utc_datetime
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:sightings, [:location], using: :gist)
    create index(:sightings, [:fungi_name])
    create index(:sightings, [:sighted_at])
  end
end
