defmodule GriffinWeb.GemTypeLive.Index do
  use GriffinWeb, :module_view

  alias Griffin.Treasure
  alias Griffin.Treasure.GemType

  @search_field_names ["code", "name", "enname"]

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)
    |> list_gem_types(params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    gem_type = Treasure.get_gem_type!(id)

    apply_common_assigns(socket, "Show Gem type", gem_type, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    gem_type = Treasure.get_gem_type!(id)

    apply_common_assigns(socket, "Edit Gem type", gem_type, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New Gem type", %GemType{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing Gem types", nil, @search_field_names, params)
    |> list_gem_types(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gem_type = Treasure.get_gem_type!(id)
    {:ok, _} = Treasure.delete_gem_type(gem_type)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("search", %{"gem_type" => search_criteria}, socket) do
      {:noreply, push_patch(socket, to: Routes.gem_type_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_gem_types(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_gem_types(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp list_gem_types(socket, search_criteria, opts \\ []) do
    changeset = GemType.search_changeset(%GemType{}, search_criteria)
    gem_types = Treasure.list_gem_types(search_criteria, opts)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:params, params)
    |> assign(:data, gem_types)
  end
end
