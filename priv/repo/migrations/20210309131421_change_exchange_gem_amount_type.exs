defmodule Griffin.Repo.Migrations.ChangeExchangeGemAmountType do
  use Ecto.Migration

  def change do
    alter table(:exchange_gems) do
      modify :amount, :decimal
    end
  end
end
