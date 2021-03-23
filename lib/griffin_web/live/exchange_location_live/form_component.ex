defmodule GriffinWeb.ExchangeLocationLive.FormComponent do
  use GriffinWeb, :live_component

  alias Griffin.Exchange

  @impl true
  def update(%{entity: exchange_location} = assigns, socket) do
    changeset = Exchange.change_exchange_location(exchange_location)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"exchange_location" => exchange_location_params}, socket) do
    changeset =
      socket.assigns.entity
      |> Exchange.change_exchange_location(exchange_location_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"exchange_location" => exchange_location_params}, socket) do
    save_exchange_location(socket, socket.assigns.action, exchange_location_params)
  end

  defp save_exchange_location(socket, :edit, exchange_location_params) do
    case Exchange.update_exchange_location(socket.assigns.entity, exchange_location_params) do
      {:ok, _exchange_location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exchange location updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_exchange_location(socket, :new, exchange_location_params) do
    case Exchange.create_exchange_location(socket.assigns.current_user, exchange_location_params) do
      {:ok, _exchange_location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exchange location created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
