defmodule GriffinWeb.GemLive.FormComponent do
  use GriffinWeb, :live_component

  alias Griffin.Treasure

  @impl true
  def update(%{entity: gem} = assigns, socket) do
    changeset = Treasure.change_gem(gem)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"gem" => gem_params}, socket) do
    changeset =
      socket.assigns.entity
      |> Treasure.change_gem(gem_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"gem" => gem_params}, socket) do
    save_gem(socket, socket.assigns.action, gem_params)
  end

  defp save_gem(socket, :edit, gem_params) do
    case Treasure.update_gem(socket.assigns.entity, gem_params) do
      {:ok, _gem} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gem updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_gem(socket, :new, gem_params) do
    case Treasure.create_gem(socket.assigns.current_user, gem_params) do
      {:ok, _gem} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gem created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
