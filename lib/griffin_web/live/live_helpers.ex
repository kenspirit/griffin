defmodule GriffinWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers
  import Phoenix.HTML
  import Phoenix.HTML.Form

  @doc """
  Renders a component inside the `GriffinWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, GriffinWeb.GemLive.FormComponent,
        id: @gem.id || :new,
        action: @live_action,
        gem: @gem,
        return_to: Routes.gem_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, GriffinWeb.ModalComponent, modal_opts)
  end

  def my_date_select(form, field, opts \\ []) do
    today = DateTime.to_date(DateTime.utc_now())
    today = {today.year, today.month, today.day}

    builder = fn b ->
      ~e"""
      <%= b.(:year, opts) %> / <%= b.(:month, opts) %> / <%= b.(:day, opts) %>
      """
    end

    date_select(form, field, [builder: builder, default: today] ++ opts)
  end

  def assign_defaults(socket, session) do
    case Griffin.Auth.Guardian.resource_from_token(session["guardian_default_token"]) do
      {:ok, user, _claims} ->
        assign(socket, :current_user, user)
      _ ->
        push_redirect(socket, to: "/login")
    end
  end

  def apply_common_assigns(socket, title, entity, search_field_names, params) do
    socket
    |> assign(:page_title, title)
    |> assign(:entity, entity)
    |> assign(:params, convert_search_params(search_field_names, params))
  end

  def convert_search_params(search_field_names, search_criteria) do
    Enum.reduce(search_field_names, Keyword.new(), fn field, acc ->
      if is_nil(search_criteria[field]) or search_criteria[field] == "" do
        acc
      else
        Keyword.put(acc, String.to_existing_atom(field), search_criteria[field])
      end
    end)
  end

  def remove_entity_from_page(page_data, entity_id) do
    id = String.to_integer(entity_id)
    entries = Enum.reject(page_data.entries, fn entry ->
      entry.id == id
    end)
    metadata = page_data.metadata

    page_data = %{page_data | entries: entries}
    %{page_data | metadata: %{metadata | total_count: metadata.total_count - 1}}
  end

  def permalink(bytes_count) do
    bytes_count
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
