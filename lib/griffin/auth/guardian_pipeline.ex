defmodule Griffin.Auth.GuardianPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :griffin,
    error_handler: Griffin.Auth.GuardianErrorHandler,
    module: Griffin.Auth.Guardian

  plug Guardian.Plug.VerifyHeader, realm: "Bearer", claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
