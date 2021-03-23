defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Index do
  use <%= inspect context.web_module %>, :live_view

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>

  @search_field_names <%= inspect Enum.map(schema.attrs, fn attr ->
    elem(attr, 0) |> Atom.to_string()
  end) %>

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)
    |> list_<%= schema.plural %>(params)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(id)

    apply_common_assigns(socket, "Show <%= schema.human_singular %>", <%= schema.singular %>, @search_field_names, params)
  end

  defp apply_action(socket, :edit, %{"id" => id} = params) do
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(id)

    apply_common_assigns(socket, "Edit <%= schema.human_singular %>", <%= schema.singular %>, @search_field_names, params)
  end

  defp apply_action(socket, :new, params) do
    apply_common_assigns(socket, "New <%= schema.human_singular %>", %<%= inspect schema.alias %>{}, @search_field_names, params)
  end

  defp apply_action(socket, :index, params) do
    socket
    |> apply_common_assigns("Listing <%= schema.human_plural %>", nil, @search_field_names, params)
    |> list_<%= schema.plural %>(params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(id)
    {:ok, _} = <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>)

    {:noreply,
      socket
      |> assign(:data, remove_entity_from_page(socket.assigns.data, id))
      |> put_flash(:info, "Deleted successfully.")
    }
  end

  @impl true
  def handle_event("search", %{"<%= schema.singular %>" => search_criteria}, socket) do
      {:noreply, push_patch(socket, to: Routes.<%= schema.route_helper %>_index_path(socket, :index, convert_search_params(@search_field_names, search_criteria)) )}
  end

  @impl true
  def handle_event("get_by_page", %{"before" => before_page}, socket) do
    {:noreply, list_<%= schema.plural %>(socket, socket.assigns.search_criteria.changes, before: before_page)}
  end

  @impl true
  def handle_event("get_by_page", %{"after" => after_page}, socket) do
    {:noreply, list_<%= schema.plural %>(socket, socket.assigns.search_criteria.changes, after: after_page)}
  end

  defp list_<%= schema.plural %>(socket, search_criteria, opts \\ []) do
    changeset = <%= inspect schema.alias %>.search_changeset(%<%= inspect schema.alias %>{}, search_criteria)
    <%= schema.plural %> = <%= inspect context.alias %>.list_<%= schema.plural %>(changeset, opts)

    params = convert_search_params(@search_field_names, search_criteria)

    socket
    |> assign(:search_criteria, changeset)
    |> assign(:params, params)
    |> assign(:data, <%= schema.plural %>)
  end
end
