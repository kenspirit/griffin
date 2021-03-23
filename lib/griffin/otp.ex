defmodule Griffin.OTP do
  def secret do
    :crypto.strong_rand_bytes(20) |> Base.encode32(padding: false)
  end

  def totp(secret) do
    :pot.totp(secret)
  end

  def valid_totp?(token, secret) do
    :pot.valid_totp(token, secret)
  end

  def totp_uri(secret, account \\ "Griffin_Master") do
    issuer = "Griffin"
    "otpauth://totp/#{issuer}:#{URI.encode(account)}?secret=#{secret}&issuer=#{issuer}"
  end

  def qr_code_png(totp_uri) do
    totp_uri |> EQRCode.encode |> EQRCode.png
  end

  def qr_code_svg(totp_uri) do
    totp_uri |> EQRCode.encode |> EQRCode.svg
  end
end
