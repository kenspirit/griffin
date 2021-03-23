defmodule Lolth.DataService.Repo.Mnesia do
  use Ecto.Repo,
    otp_app: :griffin,
    adapter: Ecto.Adapters.Mnesia
end
