defmodule Griffin.Exchange.ExchangeLocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exchange_locations" do
    field :name, :string
    belongs_to :user, Griffin.Accounts.User

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(exchange_location, user, attrs) do
    exchange_location
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_assoc(:user, user)
    # |> unique_constraint(:name, name: :exchange_locations_user_id_name_index)
  end

  def update_changeset(exchange_location, attrs) do
    exchange_location
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def search_changeset(exchange_location, attrs \\ %{}) do
    exchange_location
    |> cast(attrs, [:name])
  end
end
