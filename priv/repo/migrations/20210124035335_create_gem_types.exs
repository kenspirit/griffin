defmodule Griffin.Repo.Migrations.CreateGemTypes do
  use Ecto.Migration

  def change do
    create table(:gem_types) do
      add :code, :string
      add :name, :string
      add :enname, :string

      timestamps(type: :utc_datetime_usec)
    end

  end
end
