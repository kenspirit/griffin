defmodule Lolth.SpiderEngine.Manager do
  use GenServer

  require Logger

  @me __MODULE__

  @data_provider_impl Application.get_env(:griffin, :lolth) |> Keyword.fetch!(:data_provider)

  # api
  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  def engine_status() do
    GenServer.call(__MODULE__, :engine_status)
  end

  def add_spider_config(spider_config) do
    GenServer.call(__MODULE__, {:add_spider, spider_config})
  end

  def terminate_spider(spider_name) do
    GenServer.call(__MODULE__, {:terminate_spider, spider_name})
  end

  def start_spider(spider_name) do
    GenServer.call(__MODULE__, {:start_spider, spider_name})
  end

  # server impl
  def init(:no_args) do
    Process.send_after(self(), :kickoff, 0)

    {:ok, %{ all_engines: %{} }}
  end

  def handle_info(:kickoff, _) do
    all_spiders = @data_provider_impl.get_all_spider_config(%{"disabled" => false})

    engines =
      all_spiders
      |> Enum.into(%{}, fn spider_config ->
          start_spider(spider_config, %{})
        end)

    { :noreply, %{ all_engines: engines } }
  end

  def handle_call(:engine_status, _from, state) do
    status = get_process_info(Process.whereis(Lolth.SpiderEngine))

    {:reply, status, state}
  end

  def handle_call({:terminate_spider, spider_name}, _from, state) do
    spider_pid = Map.get(state.all_engines, spider_name)

    result =
      case spider_pid do
        nil -> {:error, :not_found}
        _ -> DynamicSupervisor.terminate_child(Lolth.SpiderEngine.Supervisor, spider_pid)
      end

    {:reply, result, %{ state | all_engines: Map.delete(state.all_engines, spider_name) }}
  end

  def handle_call({:add_spider, spider_config}, _from, state) do
    created_config = @data_provider_impl.add_spider_config(spider_config)

    status = start_spider(created_config, state.all_engines)

    {:reply, status, state}
  end

  def handle_call({:start_spider, spider_name}, _from, state) do
    all_spiders = @data_provider_impl.get_all_spider_config(%{"disabled" => false})

    spider_config = Enum.find(all_spiders, fn config ->
      config.name == spider_name
    end)

    status = start_spider(spider_config, state.all_engines)

    {:reply, status, %{ state | all_engines: Map.put(state.all_engines, spider_name, status) }}
  end

  defp get_process_info(pid) do
    %{
      pid: pid,
      children: Enum.map(Supervisor.which_children(pid),
        fn {id, child_pid, type, [module]} ->
          result = %{ id: id, pid: child_pid, module: module }
          if type == :supervisor do
            Map.put(result, :supervisor_info, get_process_info(child_pid))
          else
            result
          end
        end)
    }
  end

  defp start_spider(spider_config, _all_engines) when is_nil(spider_config) do
    {:error, :not_found}
  end

  defp start_spider(%{ name: spider_name }, all_engines) when is_map_key(all_engines, spider_name) do
    { spider_name, Map.get(all_engines, spider_name) }
  end

  defp start_spider(spider_config, _all_engines) do
    child_pid = Lolth.SpiderEngine.Supervisor.start_engine(spider_config)
    child_pid =
      case child_pid do
        {:ok, child} -> child
        :ignore -> {:error, :ignore}
        _ -> child_pid
      end
    { spider_config.name, child_pid }
  end
end
