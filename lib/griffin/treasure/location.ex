defmodule Griffin.Treasure.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :code, :string
    field :name, :string
    field :enname, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:code, :name, :enname])
    |> validate_required([:code, :name])
    |> unique_constraint(:code, name: :locations_code_index)
  end

  def search_changeset(location, attrs \\ %{}) do
    location
    |> cast(attrs, [:name])
  end
end
