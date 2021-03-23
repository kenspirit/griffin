defmodule Griffin.Treasure.Gem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gems" do
    field :code, :string
    field :name, :string
    field :enname, :string
    field :type, :string
    field :location, :string
    field :market, :string
    field :industry, :string
    field :create_user_id, :integer, default: 0

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(gem, attrs) do
    gem
    |> cast(attrs, [:code, :name, :type, :location, :enname, :market, :industry, :create_user_id])
    |> validate_required([:code, :name, :type, :location, :create_user_id])
    |> unique_constraint(:code, name: :gems_code_index)
  end

  def search_changeset(gem, attrs \\ %{}) do
    gem
    |> cast(attrs, [:name, :type, :location])
  end

  def display_info(gem) do
    "#{gem.name} (#{gem.code})"
  end
end
