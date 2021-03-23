defmodule GriffinWeb.AuthLive.Signup do
  use GriffinWeb, :live_view

  alias Griffin.Accounts
  alias Griffin.Accounts.User
  alias Griffin.OTP

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, Accounts.registration_changeset(%User{}))}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params, "_target" => target}, socket) do
    IO.inspect(user_params)
    IO.inspect(target)
    changeset = case Enum.at(target, 1) do
      "loginid" ->
        assign_totp(user_params)
      "totp_token" ->
        Accounts.registration_changeset(%User{}, user_params)
        |> Ecto.Changeset.validate_change(:totp_token, fn :totp_token, token ->
          if not OTP.valid_totp?(token, user_params["totp_secret"]) do
            [totp_token: "Token is not valid."]
          else
            []
          end
        end)
    end

    {:noreply, assign(socket, :changeset, changeset |> Map.put(:action, :validate))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    with {:ok, user} <- Accounts.register(user_params) do
      id = permalink(16)

      :ets.insert(:login_user, {id, user.id})

      {:noreply, redirect(socket, to: Routes.session_path(GriffinWeb.Endpoint, :sign_in_from_live_view, lid: id, returns_to: "/exchange_gems"))}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_totp(user_params) do
    user_params = user_params
      |> Map.put("totp_secret", OTP.secret())
      |> Map.put("totp_token", nil)

    Accounts.registration_changeset(%User{}, user_params)
    |> Ecto.Changeset.validate_change(:loginid, fn :loginid, loginid ->
      if not is_nil(loginid) and Accounts.user_existed?(loginid) do
        [loginid: "The Login ID is taken."]
      else
        []
      end
    end)
  end

  defp get_totp_qrcode(changeset) do
    loginid = Ecto.Changeset.fetch_field!(changeset, :loginid)
    secret = Ecto.Changeset.fetch_field!(changeset, :totp_secret)

    if is_nil(loginid) or loginid == "", do: nil, else: OTP.totp_uri(secret, loginid) |> OTP.qr_code_png() |> Base.encode64()
  end
end
