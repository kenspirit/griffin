defmodule Griffin.Repo.Migrations.AddGemCodeAndLocation do
  use Ecto.Migration

  def change do
    alter table(:gems) do
      add :code, :string
      add :location, :string
    end
  end
end
