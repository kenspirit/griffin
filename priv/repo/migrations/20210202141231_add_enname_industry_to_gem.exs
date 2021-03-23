defmodule Griffin.Repo.Migrations.AddEnnameIndustryToGem do
  use Ecto.Migration

  def change do
    alter table(:gems) do
      add :enname, :string
      add :market, :string
      add :industry, :string
    end
  end
end
