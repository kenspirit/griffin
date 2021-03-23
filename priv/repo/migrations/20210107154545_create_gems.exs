defmodule Griffin.Repo.Migrations.CreateGems do
  use Ecto.Migration

  def change do
    create table(:gems) do
      add :name, :string
      add :type, :string
      add :amount, :integer
      add :price, :decimal

      timestamps(type: :utc_datetime_usec)
    end

  end
end
