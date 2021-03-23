defmodule Griffin.Repo.Migrations.CreateExchangeLocations do
  use Ecto.Migration

  def change do
    create table(:exchange_locations) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:exchange_locations, [:user_id])
  end
end
