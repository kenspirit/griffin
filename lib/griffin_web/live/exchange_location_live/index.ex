defmodule GriffinWeb.ExchangeLocationLive.Index do
  use GriffinWeb, :module_view

  alias Griffin.Exchange
  alias Griffin.Exchange.ExchangeLocation

  @search_field_names ["name"]

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)
    |> list_exchange_locations(params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    exchange_location = Exchange.get_exchange_location!(id)

    apply_common_assigns(socket, "Show Exchange location", exchange_location, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    exchange_location = Exchange.get_exchange_location!(id)

    apply_common_assigns(socket, "Edit Exchange location", exchange_location, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New Exchange location", %ExchangeLocation{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing Exchange locations", nil, @search_field_names, params)
    |> list_exchange_locations(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    exchange_location = Exchange.get_exchange_location!(id)
    {:ok, _} = Exchange.delete_exchange_location(exchange_location)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("search", %{"exchange_location" => search_criteria}, socket) do
      {:noreply, push_patch(socket, to: Routes.exchange_location_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_exchange_locations(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_exchange_locations(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp list_exchange_locations(socket, search_criteria, opts \\ []) do
    changeset = ExchangeLocation.search_changeset(%ExchangeLocation{}, search_criteria)
    exchange_locations = Exchange.list_exchange_locations(socket.assigns.current_user, search_criteria, opts)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:params, params)
    |> assign(:data, exchange_locations)
  end
end
