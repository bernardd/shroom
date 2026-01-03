defmodule Shroom.Repo.Migrations.CreatePhotosTable do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :sighting_id, references(:sightings, on_delete: :delete_all), null: false
      add :data, :binary, null: false
      add :content_type, :text, null: false
      add :filename, :text
      add :caption, :text
      add :size, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:photos, [:sighting_id])

    alter table(:sightings) do
      remove :photo_url
    end
  end
end
