defmodule GriffinWeb.DashboardLive.Index do
  use GriffinWeb, :module_view

  alias Griffin.Dashboard

  @impl true
  def mount(params, session, socket) do
    socket = socket
    |> assign_defaults(session)

    overall_statistics = get_overall_statistics(socket.assigns.current_user.id)
    gem_types = Enum.uniq(Enum.map(overall_statistics, fn item -> Map.get(item, "gem_type") end))
    exchange_locations = Enum.uniq(Enum.map(overall_statistics, fn item -> Map.get(item, "location_name") end))

    socket = socket
    |> assign(:overall_statistics, overall_statistics|> Jason.encode!())
    |> assign(:gem_types, gem_types|> Jason.encode!())
    |> assign(:exchange_locations, exchange_locations|> Jason.encode!())

    {:ok, socket}
  end

  defp get_overall_statistics(user_id) do
    Dashboard.overall_statistics_by_location_and_type(user_id)
    # |> Jason.encode!()
  end
end
