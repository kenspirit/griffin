defmodule Griffin.Repo.Migrations.AddTotpSecretAndDropEmail do
  use Ecto.Migration

  def change do
    drop unique_index(:users, [:email])
    drop unique_index(:users, [:mobile])

    alter table(:users) do
      add :totp_secret, :string
      remove :email
      remove :mobile
      remove :password_hash
    end

    create unique_index(:users, [:totp_secret])
  end
end
