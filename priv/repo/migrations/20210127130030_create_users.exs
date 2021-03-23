defmodule Griffin.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :loginid, :string
      add :mobile, :string
      add :password_hash, :string

      timestamps(type: :utc_datetime_usec)
    end

  end
end
