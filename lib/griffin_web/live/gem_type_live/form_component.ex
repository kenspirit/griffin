defmodule GriffinWeb.GemTypeLive.FormComponent do
  use GriffinWeb, :live_component

  alias Griffin.Treasure

  @impl true
  def update(%{entity: gem_type} = assigns, socket) do
    changeset = Treasure.change_gem_type(gem_type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"gem_type" => gem_type_params}, socket) do
    changeset =
      socket.assigns.entity
      |> Treasure.change_gem_type(gem_type_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"gem_type" => gem_type_params}, socket) do
    save_gem_type(socket, socket.assigns.action, gem_type_params)
  end

  defp save_gem_type(socket, :edit, gem_type_params) do
    case Treasure.update_gem_type(socket.assigns.entity, gem_type_params) do
      {:ok, _gem_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gem type updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_gem_type(socket, :new, gem_type_params) do
    case Treasure.create_gem_type(gem_type_params) do
      {:ok, _gem_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gem type created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
