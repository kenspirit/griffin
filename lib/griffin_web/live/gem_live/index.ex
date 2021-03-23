defmodule GriffinWeb.GemLive.Index do
  use GriffinWeb, :module_view

  alias Griffin.Treasure
  alias Griffin.Treasure.Gem
  alias Griffin.Treasure.GemType
  alias Griffin.Treasure.Location

  @search_field_names ["name", "type", "location"]

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)
    |> assign(:locations, [%Location{} | Treasure.list_locations().entries])
    |> assign(:gem_types, [%GemType{} | Treasure.list_gem_types().entries])
    |> list_gems(params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    gem = Treasure.get_gem!(id)

    apply_common_assigns(socket, "Show Gem", gem, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    gem = Treasure.get_gem!(id)

    apply_common_assigns(socket, "Edit Gem", gem, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New Gem", %Gem{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing Gems", nil, @search_field_names, params)
    |> list_gems(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gem = Treasure.get_gem!(id)
    {:ok, _} = Treasure.delete_gem(gem)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("prepare-search", _assigns, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"gem" => search_criteria}, socket) do
    has_criteria = Map.values(search_criteria)
    |> Enum.map(&String.trim/1)
    |> Enum.any?(fn value -> String.length(value) > 0 end)

    if has_criteria do
      {:noreply, push_patch(socket, to: Routes.gem_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
    else
      {:noreply, put_flash(socket, :error, "Must input at least one criteria.")}
    end
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_gems(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_gems(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp list_gems(socket, search_criteria, opts \\ []) do
    changeset = Gem.search_changeset(%Gem{}, search_criteria)
    gems = Treasure.list_gems(search_criteria, opts)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:params, params)
    |> assign(:data, gems)
  end
end
