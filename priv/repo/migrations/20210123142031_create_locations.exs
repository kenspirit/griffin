defmodule Griffin.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string

      timestamps(type: :utc_datetime_usec)
    end

  end
end
