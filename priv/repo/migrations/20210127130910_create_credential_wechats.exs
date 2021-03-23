defmodule Griffin.Repo.Migrations.CreateCredentialWechats do
  use Ecto.Migration

  def change do
    create table(:credential_wechats) do
      add :user_id, references(:users, on_delete: :nothing)
      add :openid, :string
      add :unionid, :string
      add :meta, :map

      timestamps(type: :utc_datetime_usec)
    end

  end
end
