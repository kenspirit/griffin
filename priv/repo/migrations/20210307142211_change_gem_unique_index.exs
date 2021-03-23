defmodule Griffin.Repo.Migrations.ChangeGemUniqueIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:gems, [:code])
    create unique_index(:gems, [:code, :type, :location])
  end
end
