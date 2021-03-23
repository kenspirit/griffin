defmodule Griffin.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:gems, [:code])
    create unique_index(:gem_types, [:code])
    create unique_index(:locations, [:code])
    create unique_index(:exchange_locations, [:name, :user_id])
  end
end
