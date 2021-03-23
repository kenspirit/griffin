defmodule GriffinWeb.SessionController do
  use GriffinWeb, :controller

  def sign_in_from_live_view(conn, %{"lid" => lid, "returns_to" => returns_to}) do
    user_id =
      case :ets.lookup(:login_user, lid) do
        [{_, id}] ->
          :ets.delete(:login_user, lid)
          id
        _ ->
          -1
      end

    case Griffin.Auth.Guardian.resource_from_claims(%{"sub" => user_id}) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:live_socket_id, "users_socket:#{user.id}")
        |> Griffin.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: returns_to)

      _ ->
        conn
        |> redirect(to: Routes.auth_login_path(conn, :login))
    end
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out(Griffin.Auth.Guardian)
    |> redirect(to: "/login")
  end
end
