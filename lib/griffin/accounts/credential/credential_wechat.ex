defmodule Griffin.Accounts.Credential.CredentialWechat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credential_wechats" do
    belongs_to :user, Griffin.Accounts.User
    field :openid, :string
    field :unionid, :string
    field :meta, :map

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(credential_wechat, attrs) do
    credential_wechat
    |> cast(attrs, [:openid, :unionid, :meta])
    |> validate_required([:openid, :unionid, :meta])
  end
end
