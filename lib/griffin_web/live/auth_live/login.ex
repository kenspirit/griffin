defmodule GriffinWeb.AuthLive.Login do
  use GriffinWeb, :live_view

  alias Griffin.Accounts
  alias Griffin.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> assign(:changeset, Accounts.login_changeset(%User{}))

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket = case socket.assigns.live_action do
      :logout ->
        assign(socket, :current_user, nil)
      :login ->
        socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Accounts.login_changeset(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    with {:ok, user} <- Accounts.authenticate_locally(user_params["loginid"], user_params["totp_token"]) do
      id = permalink(16)

      :ets.insert(:login_user, {id, user.id})

      {:noreply, redirect(socket, to: Routes.session_path(GriffinWeb.Endpoint, :sign_in_from_live_view, lid: id, returns_to: "/exchange_gems"))}
    else
      {:error, :invalid_credentials} ->
        socket = socket
        |> put_flash(:error, "Invalid login & token combination.")

        {:noreply, socket}
    end
  end
end
