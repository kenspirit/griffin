defmodule Griffin.Dashboard do
  import Ecto.Query, warn: false

  alias Griffin.Repo
  alias Griffin.Exchange.ExchangeLocation
  alias Griffin.Exchange.ExchangeGem
  alias Griffin.Treasure.Gem
  alias Griffin.Treasure.Location

  def overall_statistics_by_location_and_type(user_id) do
    query = ExchangeGem
    |> where(user_id: ^user_id)
    |> join(:inner, [e], g in Gem, on: g.id == e.gem_id)
    |> join(:inner, [e], l in ExchangeLocation, on: l.id == e.location_id)
    |> group_by([e, g, l], [g.type, l.name])
    |> select([e, g, l], %{
      "total_amount" => sum(e.amount * e.price),
      "location_name" => l.name,
      "gem_type" => g.type
    })

    Repo.all(query)
  end
end
