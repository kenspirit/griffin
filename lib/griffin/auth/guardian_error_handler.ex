defmodule Griffin.Auth.GuardianErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn |> resp(:found, "") |> put_resp_header("location", "/login")
  end
end
