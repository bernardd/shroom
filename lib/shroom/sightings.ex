defmodule Shroom.Sightings do
  @moduledoc """
  The Sightings context.
  """

  import Ecto.Query, warn: false
  alias Shroom.Repo

  alias Shroom.Sightings.Sighting
  alias Shroom.Sightings.Photo

  @doc """
  Returns the list of sightings.

  ## Examples

      iex> list_sightings()
      [%Sighting{}, ...]

  """
  def list_sightings do
    Sighting
    |> order_by([s], desc: s.sighted_at)
    |> preload(:photos)
    |> Repo.all()
  end

  @doc """
  Returns a paginated list of sightings.

  ## Options

    * `:page` - Page number (default: 1)
    * `:per_page` - Items per page (default: 20)

  Returns a map with:
    * `:entries` - List of sightings for the current page
    * `:page_number` - Current page number
    * `:page_size` - Number of items per page
    * `:total_entries` - Total number of sightings
    * `:total_pages` - Total number of pages

  """
  def list_sightings_paginated(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    query = from s in Sighting, order_by: [desc: s.sighted_at], preload: [:photos]

    total_entries = Repo.aggregate(Sighting, :count)
    total_pages = ceil(total_entries / per_page)

    entries =
      query
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      page_size: per_page,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  @doc """
  Gets a single sighting.

  Raises `Ecto.NoResultsError` if the Sighting does not exist.

  ## Examples

      iex> get_sighting!(123)
      %Sighting{}

      iex> get_sighting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sighting!(id) do
    Sighting
    |> preload(:photos)
    |> Repo.get!(id)
  end

  @doc """
  Creates a sighting.

  ## Examples

      iex> create_sighting(%{field: value})
      {:ok, %Sighting{}}

      iex> create_sighting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sighting(attrs \\ %{}) do
    %Sighting{}
    |> Sighting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sighting.

  ## Examples

      iex> update_sighting(sighting, %{field: new_value})
      {:ok, %Sighting{}}

      iex> update_sighting(sighting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sighting(%Sighting{} = sighting, attrs) do
    sighting
    |> Sighting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sighting.

  ## Examples

      iex> delete_sighting(sighting)
      {:ok, %Sighting{}}

      iex> delete_sighting(sighting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sighting(%Sighting{} = sighting) do
    Repo.delete(sighting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sighting changes.

  ## Examples

      iex> change_sighting(sighting)
      %Ecto.Changeset{data: %Sighting{}}

  """
  def change_sighting(%Sighting{} = sighting, attrs \\ %{}) do
    Sighting.changeset(sighting, attrs)
  end

  @doc """
  Searches sightings by fungi name, location name, and/or date range.
  """
  def search_sightings(params) do
    query = from s in Sighting, order_by: [desc: s.sighted_at]

    query
    |> filter_by_fungi_name(params["fungi_name"])
    |> filter_by_location_name(params["location_name"])
    |> filter_by_date_range(params["start_date"], params["end_date"])
    |> preload(:photos)
    |> Repo.all()
  end

  @doc """
  Searches sightings with pagination.
  """
  def search_sightings_paginated(params, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    base_query = from s in Sighting, order_by: [desc: s.sighted_at]

    query =
      base_query
      |> filter_by_fungi_name(params["fungi_name"])
      |> filter_by_location_name(params["location_name"])
      |> filter_by_date_range(params["start_date"], params["end_date"])

    total_entries = Repo.aggregate(query, :count)
    total_pages = ceil(total_entries / per_page)

    entries =
      query
      |> preload(:photos)
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      page_size: per_page,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  ## Photo functions

  @doc """
  Creates a photo for a sighting.
  """
  def create_photo(sighting_id, attrs \\ %{}) do
    %Photo{sighting_id: sighting_id}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single photo.
  """
  def get_photo!(id), do: Repo.get!(Photo, id)

  @doc """
  Deletes a photo.
  """
  def delete_photo(%Photo{} = photo) do
    Repo.delete(photo)
  end

  defp filter_by_fungi_name(query, nil), do: query
  defp filter_by_fungi_name(query, ""), do: query
  defp filter_by_fungi_name(query, fungi_name) do
    pattern = "%#{fungi_name}%"
    from s in query, where: ilike(s.fungi_name, ^pattern)
  end

  defp filter_by_location_name(query, nil), do: query
  defp filter_by_location_name(query, ""), do: query
  defp filter_by_location_name(query, location_name) do
    pattern = "%#{location_name}%"
    from s in query, where: ilike(s.location_name, ^pattern)
  end

  defp filter_by_date_range(query, nil, nil), do: query
  defp filter_by_date_range(query, start_date, nil) when not is_nil(start_date) do
    from s in query, where: s.sighted_at >= ^start_date
  end
  defp filter_by_date_range(query, nil, end_date) when not is_nil(end_date) do
    from s in query, where: s.sighted_at <= ^end_date
  end
  defp filter_by_date_range(query, start_date, end_date) do
    from s in query, where: s.sighted_at >= ^start_date and s.sighted_at <= ^end_date
  end
end
