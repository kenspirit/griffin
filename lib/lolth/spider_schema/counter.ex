defmodule Lolth.Spider.Counter do
  use Ecto.Schema

  @primary_key {:type, :string, []}
  schema "counters" do
    field :count, :integer
  end
end
