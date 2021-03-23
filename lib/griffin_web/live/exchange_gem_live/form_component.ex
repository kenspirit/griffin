defmodule GriffinWeb.ExchangeGemLive.FormComponent do
  use GriffinWeb, :live_component

  alias Griffin.Exchange
  alias Griffin.Treasure
  alias Griffin.Treasure.Gem

  @impl true
  def update(%{entity: exchange_gem} = assigns, socket) do
    changeset = Exchange.change_exchange_gem(exchange_gem)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"exchange_gem" => exchange_gem_params, "_target" => target}, socket) do
    socket = case Enum.at(target, 1) do
      "keyword" ->
        results = search(socket, exchange_gem_params["keyword"])

        assign(socket, :search_results, results)
      _ ->
        socket
    end

    changeset =
      socket.assigns.entity
      |> Exchange.change_exchange_gem(exchange_gem_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("pick", %{"key" => selected_gem_id}, socket) do
    selected_gem = Treasure.get_gem!(String.to_integer(selected_gem_id))

    changeset =
      socket.assigns.entity
      |> Exchange.change_exchange_gem(%{ gem_id: selected_gem_id })

    {:noreply, socket
      |> assign(:changeset, changeset)
      |> assign(:search_results, [])
      |> assign(:selected_item, Gem.display_info(selected_gem))
    }
  end

  def handle_event("save", %{"exchange_gem" => exchange_gem_params}, socket) do
    save_exchange_gem(socket, socket.assigns.action, exchange_gem_params)
  end

  defp search(_socket, ""), do: []
  defp search(_socket, search_phrase) do
    Treasure.list_gems(search_phrase).entries
  end

  defp save_exchange_gem(socket, :edit, exchange_gem_params) do
    case Exchange.update_exchange_gem(socket.assigns.entity, exchange_gem_params) do
      {:ok, _exchange_gem} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exchange gem updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_exchange_gem(socket, :copy, exchange_gem_params) do
    case Exchange.create_exchange_gem(socket.assigns.current_user, nil, nil, exchange_gem_params) do
      {:ok, _exchange_gem} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exchange gem created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_exchange_gem(socket, :new, exchange_gem_params) do
    case Exchange.create_exchange_gem(socket.assigns.current_user, nil, nil, exchange_gem_params) do
      {:ok, _exchange_gem} ->
        {:noreply,
         socket
         |> put_flash(:info, "Exchange gem created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
