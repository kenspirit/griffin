defmodule Griffin.Exchange.ExchangeGem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exchange_gems" do
    field :amount, :decimal
    field :price, :decimal
    field :exchange_on, :date, default: Date.utc_today()
    belongs_to :location, Griffin.Exchange.ExchangeLocation
    belongs_to :user, Griffin.Accounts.User
    belongs_to :gem, Griffin.Treasure.Gem
    field :gem_type, :string, virtual: true
    field :exchange_on_from, :date, virtual: true
    field :exchange_on_to, :date, virtual: true

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(exchange_gem, user, _location, _gem, attrs) do
    exchange_gem
    |> cast(attrs, [:amount, :price, :exchange_on, :location_id, :gem_id])
    |> validate_required([:amount, :price, :exchange_on, :location_id, :gem_id])
    |> put_assoc(:user, user)
    # |> put_assoc(:location, location)
    # |> put_assoc(:gem, gem)
  end

  def update_changeset(exchange_gem, attrs) do
    exchange_gem
    |> cast(attrs, [:amount, :price, :exchange_on])
    |> validate_required([:amount, :price, :exchange_on])
  end

  def search_changeset(exchange_gem, attrs \\ %{}) do
    exchange_gem
    |> cast(attrs, [:exchange_on_from, :exchange_on_to, :location_id, :gem_type, :gem_id])
  end
end
