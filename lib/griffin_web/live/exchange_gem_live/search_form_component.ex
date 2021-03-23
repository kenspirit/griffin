defmodule GriffinWeb.ExchangeGemLive.SearchFormComponent do
  use GriffinWeb, :live_component

  alias Griffin.Treasure
  alias Griffin.Treasure.Gem

  @impl true
  def render(assigns) do
    ~L"""
      <div id="<%= @id %>">
        <%= live_component @socket, GriffinWeb.SearchFormComponent,
          id: @id,
          search_criteria: @search_criteria,
          fields: [
            %{name: :exchange_on_from, label: "Exchange Date From", class: "lg:col-span-2 sm:col-span-6", type: "date"},
            %{name: :exchange_on_to, label: "To", class: "lg:col-span-2 sm:col-span-6", type: "date"},
            %{name: :gem_type, label: "Gem Type", class: "lg:col-span-1 sm:col-span-6", type: "select", selections: Enum.map(@gem_types, &{&1.name, &1.code})},
            %{name: :location_id, label: "Location", class: "lg:col-span-1 sm:col-span-6", type: "select", selections: Enum.map(@locations, &{&1.name, &1.id})},
            %{name: :gem_id, type: "hidden"},
            %{name: :keyword, label: "Gem", class: "col-span-2", type: "component", id: @id, component: GriffinWeb.AutoCompleteComponent, opts: [search_results: @search_results, selected_item: @selected_item]},
          ]
        %>
      </div>
    """
  end

  @impl true
  def handle_event("pick", %{"key" => selected_gem_id}, socket) do
    selected_gem = Treasure.get_gem!(String.to_integer(selected_gem_id))

    {:noreply, socket
      |> assign(:search_results, [])
      |> assign(:search_criteria, Ecto.Changeset.put_change(socket.assigns.search_criteria, :gem_id, selected_gem.id))
      |> assign(:selected_item, Gem.display_info(selected_gem))
    }
  end
end
