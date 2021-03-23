defmodule Griffin.Repo.Migrations.AddParamsToSpiderConfig do
  use Ecto.Migration

  def change do
    alter table(:spider_configs) do
      add :params, :map, default: %{}
    end
  end
end
