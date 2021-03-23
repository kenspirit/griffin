defmodule Griffin.Repo.Migrations.AddIndexesToUser do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:loginid])
    create unique_index(:users, [:email])
    create unique_index(:users, [:mobile])
  end
end
