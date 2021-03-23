defmodule GriffinWeb.LocationLive.Index do
  use GriffinWeb, :module_view

  alias Griffin.Treasure
  alias Griffin.Treasure.Location

  @search_field_names ["code", "name", "enname"]

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)
    |> list_locations(params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    location = Treasure.get_location!(id)

    apply_common_assigns(socket, "Show Location", location, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    location = Treasure.get_location!(id)

    apply_common_assigns(socket, "Edit Location", location, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New Location", %Location{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing Locations", nil, @search_field_names, params)
    |> list_locations(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Treasure.get_location!(id)
    {:ok, _} = Treasure.delete_location(location)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("search", %{"location" => search_criteria}, socket) do
      {:noreply, push_patch(socket, to: Routes.location_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_locations(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_locations(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp list_locations(socket, search_criteria, opts \\ []) do
    changeset = Location.search_changeset(%Location{}, search_criteria)
    locations = Treasure.list_locations(search_criteria, opts)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:params, params)
    |> assign(:data, locations)
  end
end
