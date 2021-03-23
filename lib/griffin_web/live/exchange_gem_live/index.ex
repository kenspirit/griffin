defmodule GriffinWeb.ExchangeGemLive.Index do
  use GriffinWeb, :module_view

  alias Griffin.Treasure
  alias Griffin.Treasure.Gem
  alias Griffin.Treasure.GemType
  alias Griffin.Exchange
  alias Griffin.Exchange.ExchangeGem
  alias Griffin.Exchange.ExchangeLocation

  @search_field_names ["location_id", "gem_type", "exchange_on_from", "exchange_on_to", "gem_id"]

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)

    socket = socket
    |> assign(:selected_item, "")
    |> assign(:search_results, [])
    |> assign(:locations, [%ExchangeLocation{} | Exchange.list_exchange_locations(socket.assigns.current_user).entries])
    |> assign(:gem_types, [%GemType{} | Treasure.list_gem_types().entries])
    |> list_exchange_gems(params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    exchange_gem = Exchange.get_exchange_gem!(id)

    socket
    |> assign(:selected_item, Gem.display_info(exchange_gem.gem))
    |> apply_common_assigns("Show Exchange gem", exchange_gem, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    exchange_gem = Exchange.get_exchange_gem!(id)

    socket
    |> assign(:selected_item, Gem.display_info(exchange_gem.gem))
    |> apply_common_assigns("Edit Exchange gem", exchange_gem, @search_field_names, params)
  end

  defp apply_action(socket, :copy, %{"id" => id} = params) do
    exchange_gem = Exchange.get_exchange_gem!(id)
    |> Map.put(:id, nil)

    socket
    |> assign(:selected_item, Gem.display_info(exchange_gem.gem))
    |> apply_common_assigns("Edit Exchange gem", exchange_gem, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New Exchange gem", %ExchangeGem{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing Exchange gems", nil, @search_field_names, params)
    |> list_exchange_gems(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    exchange_gem = Exchange.get_exchange_gem!(id)
    {:ok, _} = Exchange.delete_exchange_gem(exchange_gem)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("autocomplete", %{"value" => search_text}, socket) do
    results = search(socket, search_text)

    {:noreply, assign(socket, :search_results, results)}
  end

  @impl true
  def handle_event("search", %{"exchange_gem" => search_criteria}, socket) do
    {:noreply, push_patch(socket, to: Routes.exchange_gem_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_exchange_gems(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_exchange_gems(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp search(_socket, ""), do: []
  defp search(_socket, search_phrase) do
    Treasure.list_gems(search_phrase).entries
  end

  defp list_exchange_gems(socket, search_criteria, opts \\ []) do
    criteria_for_changeset = convert_date_criteria(search_criteria, "exchange_on_from")
    criteria_for_changeset = convert_date_criteria(criteria_for_changeset, "exchange_on_to")

    changeset = ExchangeGem.search_changeset(%ExchangeGem{}, criteria_for_changeset)

    exchange_gems = Exchange.list_exchange_gems(socket.assigns.current_user, criteria_for_changeset, opts)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:search_results, [])
    |> assign(:params, params)
    |> assign(:data, exchange_gems)
  end

  defp convert_date_criteria(search_criteria, field_name) do
    case Map.get(search_criteria, field_name) do
      nil ->
        search_criteria
      %{"day" => day, "month" => month, "year" => year} ->
        Map.put(search_criteria, field_name,
          Date.new!(String.to_integer(year), String.to_integer(month), String.to_integer(day)))
    end
  end
end
