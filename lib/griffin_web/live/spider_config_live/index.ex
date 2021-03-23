defmodule GriffinWeb.SpiderConfigLive.Index do
  use GriffinWeb, :module_view

  alias Lolth.DataService.Provider.Default, as: Spider
  alias Lolth.Spider.Config, as: SpiderConfig

  @search_field_names ["name", "type"]

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)
    |> list_spider_configs(params)
    |> assign(:types, ["" | Spider.get_all_spider_types()])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    spider_config = Spider.get_spider_config!(id)

    apply_common_assigns(socket, "Show Spider config", spider_config, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    spider_config = Spider.get_spider_config!(id)

    apply_common_assigns(socket, "Edit Spider config", spider_config, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New Spider config", %SpiderConfig{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing Spider configs", nil, @search_field_names, params)
    |> list_spider_configs(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    spider_config = Spider.get_spider_config!(id)
    {:ok, _} = Spider.delete_spider_config(spider_config)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("search", %{"config" => search_criteria}, socket) do
      {:noreply, push_patch(socket, to: Routes.spider_config_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_spider_configs(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_spider_configs(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp list_spider_configs(socket, search_criteria, opts \\ []) do
    changeset = SpiderConfig.search_changeset(%SpiderConfig{}, search_criteria)
    spider_configs = Spider.get_all_spider_config(search_criteria)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:params, params)
    |> assign(:data, %{entries: spider_configs, metadata: %{before: nil, after: nil}})
  end
end
