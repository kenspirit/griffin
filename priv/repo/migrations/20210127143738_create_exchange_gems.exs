defmodule Griffin.Repo.Migrations.CreateExchangeGems do
  use Ecto.Migration

  def change do
    create table(:exchange_gems) do
      add :amount, :integer
      add :price, :decimal
      add :user_id, references(:users, on_delete: :nothing)
      add :gem_id, references(:gems, on_delete: :nothing)
      add :location_id, references(:exchange_locations, on_delete: :nothing)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:exchange_gems, [:user_id])
    create index(:exchange_gems, [:gem_id])
    create index(:exchange_gems, [:location_id])
  end
end
