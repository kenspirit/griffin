defmodule GriffinWeb.GridComponent do
  use GriffinWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket
      |> assign(assigns)
      |> assign(params: Map.get(assigns, :params, []))
      |> assign(inner_block: Map.get(assigns, :inner_block))
      |> assign(default_entry_actions: Map.get(assigns, :default_entry_actions, true))
    }
  end

  def is_editable?(current_user, _entry) when is_nil(current_user) do
    false
  end

  def is_editable?(current_user, entry) do
    Griffin.Accounts.is_admin_user(current_user) || entry.create_user_id == current_user.id
  end
end
