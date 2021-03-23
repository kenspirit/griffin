defmodule Griffin.Treasure.GemType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gem_types" do
    field :code, :string
    field :name, :string
    field :enname, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(gem_type, attrs) do
    gem_type
    |> cast(attrs, [:code, :name, :enname])
    |> validate_required([:code, :name, :enname])
    |> unique_constraint(:code, name: :gem_types_code_index)
  end

  def search_changeset(gem_type, attrs \\ %{}) do
    gem_type
    |> cast(attrs, [:name])
  end
end
