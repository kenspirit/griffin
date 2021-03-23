defmodule Griffin.Repo.Migrations.RemoveAmountPriceFromGem do
  use Ecto.Migration

  def change do
    alter table(:gems) do
      remove :amount, :integer
      remove :price, :decimal
    end
  end
end
