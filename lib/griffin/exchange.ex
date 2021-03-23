defmodule Griffin.Exchange do
  @moduledoc """
  The Exchange context.
  """

  import Ecto.Query, warn: false

  alias Griffin.Repo
  alias Griffin.Accounts.User

  alias Griffin.Exchange.ExchangeLocation
  alias Griffin.Treasure.Gem

  @limit 10

  @doc """
  Returns the list of exchange_locations.

  ## Examples

      iex> list_exchange_locations()
      [%ExchangeLocation{}, ...]

  """
  def list_exchange_locations(%User{} = user) do
    list_exchange_locations(user, %{})
  end

  def list_exchange_locations(%User{} = user, search_phrase) when is_binary(search_phrase) do
    list_exchange_locations(user, %{"name" => search_phrase })
  end

  def list_exchange_locations(%User{} = user, search_criteria \\ %{}, opts \\ []) do
    query = ExchangeLocation
    |> where(user_id: ^user.id)
    |> where(^filter_exchange_location_where(search_criteria))
    |> order_by(asc: :name)

    Repo.paginate(query, Keyword.merge(opts, [include_total_count: true, total_count_limit: :infinity, cursor_fields: [:code], limit: @limit]))
  end

  defp filter_exchange_location_where(params) do
    Enum.reduce(Map.to_list(params), dynamic(true), fn
      {"name", value}, dynamic ->
        search_phrase = value
        |> String.replace("%", "")
        |> String.replace("_", "")

        dynamic([q], ^dynamic and ilike(q.name, ^"%#{search_phrase}%"))
    end)
  end

  @doc """
  Gets a single exchange_location.

  Raises `Ecto.NoResultsError` if the Exchange location does not exist.

  ## Examples

      iex> get_exchange_location!(123)
      %ExchangeLocation{}

      iex> get_exchange_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exchange_location!(id), do: Repo.get!(ExchangeLocation, id)

  @doc """
  Creates a exchange_location.

  ## Examples

      iex> create_exchange_location(%{field: value})
      {:ok, %ExchangeLocation{}}

      iex> create_exchange_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exchange_location(%User{} = user, attrs \\ %{}) do
    %ExchangeLocation{}
    |> ExchangeLocation.changeset(user, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exchange_location.

  ## Examples

      iex> update_exchange_location(exchange_location, %{field: new_value})
      {:ok, %ExchangeLocation{}}

      iex> update_exchange_location(exchange_location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exchange_location(%ExchangeLocation{} = exchange_location, attrs) do
    exchange_location
    |> ExchangeLocation.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a exchange_location.

  ## Examples

      iex> delete_exchange_location(exchange_location)
      {:ok, %ExchangeLocation{}}

      iex> delete_exchange_location(exchange_location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exchange_location(%ExchangeLocation{} = exchange_location) do
    Repo.delete(exchange_location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exchange_location changes.

  ## Examples

      iex> change_exchange_location(exchange_location)
      %Ecto.Changeset{data: %ExchangeLocation{}}

  """
  def change_exchange_location(%ExchangeLocation{} = exchange_location, attrs \\ %{}) do
    ExchangeLocation.update_changeset(exchange_location, attrs)
  end

  alias Griffin.Exchange.ExchangeGem

  @doc """
  Returns the list of exchange_gems.

  ## Examples

      iex> list_exchange_gems()
      [%ExchangeGem{}, ...]

  """
  def list_exchange_gems(%User{} = user, search_criteria \\ %{}, opts \\ []) do
    # query = from g in ExchangeGem, where: g.user_id == ^user.id, order_by: [desc: g.exchange_on]
    query = ExchangeGem
      |> where(user_id: ^user.id)
      |> where(^filter_exchange_gem_where(search_criteria))
      |> order_by(desc: :exchange_on)

    gem_type = Map.get(search_criteria, "gem_type")
    query = if is_nil(gem_type) or gem_type == "" do
      query
    else
      from g in query, join: gg in Gem, on: g.gem_id == gg.id, where: gg.type == ^gem_type
    end

    page = Repo.paginate(query, Keyword.merge(opts, [include_total_count: true, total_count_limit: :infinity, cursor_fields: [:code], limit: @limit]))
    Map.put(page, :entries, Repo.preload(page.entries, [:location, :gem]))
  end

  defp filter_exchange_gem_where(params) do
    Enum.reduce(Map.to_list(params), dynamic(true), fn
      {"gem_type", _value}, dynamic ->
        dynamic
      {"name", value}, dynamic ->
        search_phrase = value
        |> String.replace("%", "")
        |> String.replace("_", "")

        dynamic([q], ^dynamic and ilike(q.code, ^"%#{search_phrase}%") or ilike(q.name, ^"%#{search_phrase}%"))
      {"location_id", value}, dynamic ->
        dynamic([q], ^dynamic and q.location_id == ^value)
      {"gem_id", value}, dynamic ->
        dynamic([q], ^dynamic and q.gem_id == ^value)
      {"exchange_on_to", value}, dynamic ->
        dynamic([q], ^dynamic and q.exchange_on <= ^value)
      {"exchange_on_from", value}, dynamic ->
        dynamic([q], ^dynamic and q.exchange_on >= ^value)
    end)
  end

  @doc """
  Gets a single exchange_gem.

  Raises `Ecto.NoResultsError` if the Exchange gem does not exist.

  ## Examples

      iex> get_exchange_gem!(123)
      %ExchangeGem{}

      iex> get_exchange_gem!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exchange_gem!(id) do
    Repo.get!(ExchangeGem, id)
    |> Repo.preload([:location, :gem])
  end

  @doc """
  Creates a exchange_gem.

  ## Examples

      iex> create_exchange_gem(%{field: value})
      {:ok, %ExchangeGem{}}

      iex> create_exchange_gem(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exchange_gem(user, location, gem, attrs \\ %{}) do
    %ExchangeGem{}
    |> ExchangeGem.changeset(user, location, gem, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a exchange_gem.

  ## Examples

      iex> update_exchange_gem(exchange_gem, %{field: new_value})
      {:ok, %ExchangeGem{}}

      iex> update_exchange_gem(exchange_gem, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exchange_gem(%ExchangeGem{} = exchange_gem, attrs) do
    exchange_gem
    |> ExchangeGem.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a exchange_gem.

  ## Examples

      iex> delete_exchange_gem(exchange_gem)
      {:ok, %ExchangeGem{}}

      iex> delete_exchange_gem(exchange_gem)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exchange_gem(%ExchangeGem{} = exchange_gem) do
    Repo.delete(exchange_gem)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exchange_gem changes.

  ## Examples

      iex> change_exchange_gem(exchange_gem)
      %Ecto.Changeset{data: %ExchangeGem{}}

  """
  def change_exchange_gem(%ExchangeGem{} = exchange_gem, attrs \\ %{}) do
    ExchangeGem.update_changeset(exchange_gem, attrs)
  end
end
