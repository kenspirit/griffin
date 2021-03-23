defmodule Griffin.Repo.Migrations.AddCodeToLocation do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :code, :string
      add :enname, :string
    end
  end
end
