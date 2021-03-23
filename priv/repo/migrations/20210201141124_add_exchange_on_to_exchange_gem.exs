defmodule Griffin.Repo.Migrations.AddExchangeOnToExchangeGem do
  use Ecto.Migration

  def change do
    alter table(:exchange_gems) do
      add :exchange_on, :date
    end
  end
end
