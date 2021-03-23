defmodule Griffin.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :loginid, :string
    field :totp_secret, :string
    field :totp_token, :string, virtual: true
    field :roles, {:array, :string}, default: ["NORMAL_USER"]

    timestamps(type: :utc_datetime_usec)
  end

  def registration_changeset(user, params) do
    fields = ~w(loginid totp_token totp_secret)a
    user
    |> cast(params, fields)
    |> validate_required(fields)
    |> unique_constraint(:loginid)
    |> unique_constraint(:totp_secret)
  end

  def login_changeset(user, params) do
    fields = ~w(loginid totp_token)a
    user
    |> cast(params, fields)
    |> validate_required(fields)
  end
end
