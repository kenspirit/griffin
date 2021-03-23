defmodule Griffin.Treasure do
  @moduledoc """
  The Treasure context.
  """

  import Ecto.Query, warn: false

  alias Griffin.Repo
  alias Griffin.Treasure.Gem
  alias Griffin.Accounts.User

  @limit 10

  @doc """
  Returns the list of gems.

  ## Examples

      iex> list_gems()
      [%Gem{}, ...]

  """
  def list_gems() do
    list_gems(%{})
  end

  def list_gems(search_phrase) when is_binary(search_phrase) do
    list_gems(%{"name" => search_phrase })
  end

  def list_gems(search_criteria, opts \\ []) do
    if length(Map.keys(search_criteria)) == 0 do
      %Paginator.Page{entries: [], metadata: %Paginator.Page.Metadata{}}
    else
      query = Gem
      |> where(^filter_gem_where(search_criteria))
      |> order_by(asc: :code)

      Repo.paginate(query, Keyword.merge(opts, [include_total_count: true, total_count_limit: :infinity, cursor_fields: [:code], limit: @limit]))
    end
  end

  defp filter_gem_where(params) do
    Enum.reduce(Map.to_list(params), dynamic(true), fn
      {"type", value}, dynamic ->
        dynamic([q], ^dynamic and q.type == ^value)
      {"name", value}, dynamic ->
        search_phrase = value
        |> String.replace("%", "")
        |> String.replace("_", "")

        dynamic([q], ^dynamic and ilike(q.code, ^"%#{search_phrase}%") or ilike(q.name, ^"%#{search_phrase}%"))
      {"location", value}, dynamic ->
        dynamic([q], ^dynamic and q.location == ^value)
    end)
  end

  @doc """
  Gets a single gem.

  Raises `Ecto.NoResultsError` if the Gem does not exist.

  ## Examples

      iex> get_gem!(123)
      %Gem{}

      iex> get_gem!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gem!(id), do: Repo.get!(Gem, id)

  @doc """
  Creates a gem.

  ## Examples

      iex> create_gem(%{field: value})
      {:ok, %Gem{}}

      iex> create_gem(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gem(%User{} = user, attrs \\ %{}) do
    %Gem{}
    |> Map.put(:create_user_id, user.id)
    |> Gem.changeset(attrs)
    |> Repo.insert()
  end

  def create_gem_by_admin(gems \\ []) do
    admin = Griffin.Accounts.get_admin_user()
    now = DateTime.now!("Etc/UTC")

    chunks = Enum.chunk_every(gems, 50)
    Enum.map(chunks, fn chunk ->
      chunk = Enum.map(chunk, fn gem ->
        gem
        |> Map.put(:create_user_id, admin.id)
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

      Repo.insert_all(Gem, chunk, on_conflict: {:replace, [:name, :enname]}, conflict_target: [:code, :type, :location])
    end)
  end

  @doc """
  Updates a gem.

  ## Examples

      iex> update_gem(gem, %{field: new_value})
      {:ok, %Gem{}}

      iex> update_gem(gem, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gem(%Gem{} = gem, attrs) do
    gem
    |> Gem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a gem.

  ## Examples

      iex> delete_gem(gem)
      {:ok, %Gem{}}

      iex> delete_gem(gem)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gem(%Gem{} = gem) do
    Repo.delete(gem)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gem changes.

  ## Examples

      iex> change_gem(gem)
      %Ecto.Changeset{data: %Gem{}}

  """
  def change_gem(%Gem{} = gem, attrs \\ %{}) do
    Gem.changeset(gem, attrs)
  end

  alias Griffin.Treasure.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    list_locations(%{})
  end

  def list_locations(search_phrase) when is_binary(search_phrase) do
    %Location{}
    |> Location.search_changeset(%{"name" => search_phrase })
    |> list_locations()
  end

  def list_locations(search_criteria, opts \\ []) do
    query = Location
    |> where(^filter_location_where(search_criteria))
    |> order_by(asc: :code)

    Repo.paginate(query, Keyword.merge(opts, [include_total_count: true, total_count_limit: :infinity, cursor_fields: [:code], limit: @limit]))
  end

  defp filter_location_where(params) do
    Enum.reduce(Map.to_list(params), dynamic(true), fn
      {"name", value}, dynamic ->
        search_phrase = value
        |> String.replace("%", "")
        |> String.replace("_", "")

        dynamic([g], ^dynamic and ilike(g.code, ^"%#{search_phrase}%") or ilike(g.name, ^"%#{search_phrase}%") or ilike(g.enname, ^"%#{search_phrase}%"))
    end)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  alias Griffin.Treasure.GemType

  @doc """
  Returns the list of gem_types.

  ## Examples

      iex> list_gem_types()
      [%GemType{}, ...]

  """
  def list_gem_types do
    list_gem_types(%{})
  end

  def list_gem_types(search_phrase) when is_binary(search_phrase) do
    list_gem_types(%{"name" => search_phrase})
  end

  def list_gem_types(search_criteria, opts \\ []) do
    query = GemType
    |> where(^filter_gem_type_where(search_criteria))
    |> order_by(asc: :code)

    Repo.paginate(query, Keyword.merge(opts, [include_total_count: true, total_count_limit: :infinity, cursor_fields: [:code], limit: @limit]))
  end

  defp filter_gem_type_where(params) do
    Enum.reduce(Map.to_list(params), dynamic(true), fn
      {"name", value}, dynamic ->
        search_phrase = value
        |> String.replace("%", "")
        |> String.replace("_", "")

        dynamic([g], ^dynamic and ilike(g.code, ^"%#{search_phrase}%") or ilike(g.name, ^"%#{search_phrase}%") or ilike(g.enname, ^"%#{search_phrase}%"))
    end)
  end

  @doc """
  Gets a single gem_type.

  Raises `Ecto.NoResultsError` if the Gem type does not exist.

  ## Examples

      iex> get_gem_type!(123)
      %GemType{}

      iex> get_gem_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gem_type!(id), do: Repo.get!(GemType, id)

  @doc """
  Creates a gem_type.

  ## Examples

      iex> create_gem_type(%{field: value})
      {:ok, %GemType{}}

      iex> create_gem_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gem_type(attrs \\ %{}) do
    %GemType{}
    |> GemType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a gem_type.

  ## Examples

      iex> update_gem_type(gem_type, %{field: new_value})
      {:ok, %GemType{}}

      iex> update_gem_type(gem_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gem_type(%GemType{} = gem_type, attrs) do
    gem_type
    |> GemType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a gem_type.

  ## Examples

      iex> delete_gem_type(gem_type)
      {:ok, %GemType{}}

      iex> delete_gem_type(gem_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gem_type(%GemType{} = gem_type) do
    Repo.delete(gem_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gem_type changes.

  ## Examples

      iex> change_gem_type(gem_type)
      %Ecto.Changeset{data: %GemType{}}

  """
  def change_gem_type(%GemType{} = gem_type, attrs \\ %{}) do
    GemType.changeset(gem_type, attrs)
  end
end
