# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Shroom.Repo.insert!(%Shroom.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Shroom.Repo
alias Shroom.Sightings
alias Shroom.Sightings.Sighting
alias Shroom.Sightings.Photo

# Clear existing data
Repo.delete_all(Photo)
Repo.delete_all(Sighting)

# Helper function to create a PostGIS point
defmodule SeedHelper do
  def point(lat, lon) do
    %Geo.Point{coordinates: {lon, lat}, srid: 4326}
  end

  def load_local_photo(filename) do
    path = Path.join([__DIR__, "sample_images", filename])
    IO.puts("    Loading photo from #{filename}...")

    case File.read(path) do
      {:ok, data} ->
        content_type = case Path.extname(filename) do
          ".jpg" -> "image/jpeg"
          ".jpeg" -> "image/jpeg"
          ".png" -> "image/png"
          ".gif" -> "image/gif"
          ".webp" -> "image/webp"
          _ -> "image/jpeg"
        end

        {:ok, data, content_type, filename, byte_size(data)}

      {:error, reason} ->
        IO.puts("    ⚠ Failed to load photo: #{inspect(reason)}")
        {:error, reason}
    end
  end
end

# Seed data with various fungi sightings
sightings = [
  %{
    fungi_name: "Lactarius indigo",
    location_name: "Dandenong Ranges, Victoria",
    location: SeedHelper.point(-37.8339, 145.3508),
    photo_filenames: [
      "Lactarius_indigo_48568.jpg"
    ],
    sighted_at: ~U[2024-11-15 14:30:00Z],
    notes: "Indigo milk cap. Beautiful blue mushroom with blue latex when cut. Rare find!"
  },
  %{
    fungi_name: "Hypomyces lactifluorum",
    location_name: "Royal Botanic Gardens, Melbourne",
    location: SeedHelper.point(-37.8304, 144.9796),
    photo_filenames: [
      "Hypomyces_lactifluorum_169126.jpg"
    ],
    sighted_at: ~U[2024-12-03 10:15:00Z],
    notes: "Lobster mushroom! A parasitic fungus that transforms other mushrooms. Orange-red and edible."
  },
  %{
    fungi_name: "Lycoperdon perlatum",
    location_name: "Yarra Valley, Victoria",
    location: SeedHelper.point(-37.6833, 145.4167),
    photo_filenames: [
      "Lycoperdon_perlatum,_Common_Puffball,_UK_,_2.jpg"
    ],
    sighted_at: ~U[2024-10-22 16:45:00Z],
    notes: "Common puffball mushroom. Edible when young and white inside. Releases spores in cloud when touched!"
  },
  %{
    fungi_name: "Pholiota squarrosa",
    location_name: "Black Mountain, Canberra",
    location: SeedHelper.point(-35.2744, 149.0997),
    photo_filenames: [
      "Sparrige_Schüppling_(Pholiota_squarrosa).jpg"
    ],
    sighted_at: ~U[2024-11-28 09:20:00Z],
    notes: "Shaggy scalycap mushroom. Beautiful scaly caps growing in dense cluster on tree trunk."
  },
  %{
    fungi_name: "Omphalotus nidiformis",
    location_name: "Grampians National Park, Victoria",
    location: SeedHelper.point(-37.2167, 142.5167),
    photo_filenames: [
      "Omphalotus_nidiformis_Binnamittalong_2_email.jpg"
    ],
    sighted_at: ~U[2024-12-10 18:00:00Z],
    notes: "Ghost fungus! Glows green in the dark. Found on dead wattle tree."
  },
  %{
    fungi_name: "Lactarius deliciosus",
    location_name: "Mount Macedon, Victoria",
    location: SeedHelper.point(-37.4000, 144.5833),
    sighted_at: ~U[2024-11-05 11:30:00Z],
    notes: "Saffron milk cap. Orange latex when cut. Edible and delicious under pines."
  },
  %{
    fungi_name: "Mycena interrupta",
    location_name: "Blue Mountains, NSW",
    location: SeedHelper.point(-33.7152, 150.3114),
    sighted_at: ~U[2024-12-01 13:15:00Z],
    notes: "Pixie's parasol! Bright blue bioluminescent mushroom. Rare find!"
  },
  %{
    fungi_name: "Trametes versicolor",
    location_name: "Brisbane Forest Park, Queensland",
    location: SeedHelper.point(-27.4328, 152.7631),
    sighted_at: ~U[2024-11-18 15:45:00Z],
    notes: "Turkey tail fungus. Beautiful concentric color bands. Very common on dead hardwood."
  },
  %{
    fungi_name: "Armillaria ostoyae",
    location_name: "Mount Donna Buang, Victoria",
    location: SeedHelper.point(-37.7167, 145.6833),
    photo_filenames: [
      "Armillaria_ostoyae_MO.jpg",
      "Fungus_in_a_Wood.jpg"
    ],
    sighted_at: ~U[2024-11-20 14:45:00Z],
    notes: "Dark honey mushroom cluster. Found two different groups growing on same dead log. Beautiful specimens in shaded woodland area."
  },
  %{
    fungi_name: "Ganoderma applanatum",
    location_name: "Belair National Park, South Australia",
    location: SeedHelper.point(-35.0167, 138.6333),
    sighted_at: ~U[2024-10-30 14:00:00Z],
    notes: "Artist's conk. White pore surface bruises brown when scratched."
  },
  %{
    fungi_name: "Unknown species",
    location_name: "Cradle Mountain, Tasmania",
    location: SeedHelper.point(-41.6848, 145.9399),
    sighted_at: ~U[2024-12-15 08:30:00Z],
    notes: "Small brown mushrooms growing in moss. Need to identify - possibly a Galerina species."
  },
  %{
    fungi_name: "Boletus edulis",
    location_name: "Adelaide Hills, South Australia",
    location: SeedHelper.point(-34.9833, 138.7667),
    sighted_at: ~U[2024-11-12 10:00:00Z],
    notes: "Porcini mushroom! Rare in Australia. Found under introduced oak tree. Large specimen, about 15cm cap."
  },
  %{
    fungi_name: "Chlorophyllum molybdites",
    location_name: "Centennial Park, Sydney",
    location: SeedHelper.point(-33.8967, 151.2358),
    sighted_at: ~U[2024-12-08 12:20:00Z],
    notes: "Green-spored parasol. Common on lawns. Poisonous - do not eat! Fairy ring formation."
  }
]

IO.puts("Seeding database with #{length(sightings)} fungi sightings...")
IO.puts("")

Enum.each(sightings, fn sighting_attrs ->
  # Extract photo_filenames and remove from attrs
  {photo_filenames, sighting_attrs} = Map.pop(sighting_attrs, :photo_filenames, [])

  # Create the sighting
  sighting =
    %Sighting{}
    |> Sighting.changeset(sighting_attrs)
    |> Repo.insert!()

  IO.puts("  ✓ Created: #{sighting_attrs.fungi_name} - #{sighting_attrs.location_name}")

  # Load photos from local files
  if length(photo_filenames) > 0 do
    Enum.each(photo_filenames, fn filename ->
      case SeedHelper.load_local_photo(filename) do
        {:ok, data, content_type, filename, size} ->
          {:ok, _photo} =
            Sightings.create_photo(sighting.id, %{
              data: data,
              content_type: content_type,
              filename: filename,
              size: size
            })

          IO.puts("    ✓ Added photo: #{filename} (#{Float.round(size / 1024, 1)} KB)")

        {:error, _reason} ->
          :ok
      end
    end)
  end
end)

IO.puts("")
IO.puts("Seeding completed!")
IO.puts("  #{Repo.aggregate(Sighting, :count)} total sightings")
IO.puts("  #{Repo.aggregate(Photo, :count)} total photos")
IO.puts("")
IO.puts("To add photos, visit http://localhost:4000 and edit each sighting to upload images.")
