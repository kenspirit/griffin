defmodule GriffinWeb.SpiderConfigLive.FormComponent do
  use GriffinWeb, :live_component

  alias Lolth.DataService.Provider.Default, as: Spider
  alias Lolth.Spider.Config, as: SpiderConfig

  @impl true
  def update(%{entity: spider_config} = assigns, socket) do
    changeset = SpiderConfig.changeset(spider_config)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"config" => spider_config_params}, socket) do
    spider_config_params = convert_json(spider_config_params)

    changeset =
      socket.assigns.entity
      |> SpiderConfig.changeset(spider_config_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"config" => spider_config_params}, socket) do
    spider_config_params = convert_json(spider_config_params)

    save_spider_config(socket, socket.assigns.action, spider_config_params)
  end

  defp convert_json(spider_config_params) do
    params = spider_config_params["params"]

    if not is_nil(params) or params != "" do
      json = Jason.decode(params)
      case json do
        {:ok, value} ->
          Map.put(spider_config_params, "params", value)
        {:error, _} ->
          spider_config_params
      end
    else
      spider_config_params
    end
  end

  defp save_spider_config(socket, :edit, spider_config_params) do
    case Spider.update_spider_config(socket.assigns.entity, spider_config_params) do
      {:ok, _spider_config} ->
        {:noreply,
         socket
         |> put_flash(:info, "Spider config updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_spider_config(socket, :new, spider_config_params) do
    case Spider.add_spider_config(spider_config_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
      _spider_config ->
        {:noreply,
         socket
         |> put_flash(:info, "Spider config created successfully")
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
