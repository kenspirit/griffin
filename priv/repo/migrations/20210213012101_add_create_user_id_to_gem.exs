defmodule Griffin.Repo.Migrations.AddCreateUserIdToGem do
  use Ecto.Migration

  def change do
    alter table(:gems) do
      add :create_user_id, references(:users, on_delete: :nothing)
    end
  end
end
