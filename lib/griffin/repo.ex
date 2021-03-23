defmodule Griffin.Repo do
  use Ecto.Repo,
    otp_app: :griffin,
    adapter: Ecto.Adapters.Postgres

  use Paginator
end
