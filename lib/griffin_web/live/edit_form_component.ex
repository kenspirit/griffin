defmodule GriffinWeb.EditFormComponent do
  use GriffinWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, socket
      |> assign(assigns)
    }
  end
end
