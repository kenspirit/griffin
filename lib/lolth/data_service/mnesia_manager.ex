defmodule Lolth.Mnesia.Manager do
  use GenServer

  alias :mnesia, as: Mnesia

  @schema_modules [
    {Lolth.Spider.Counter, :set},
    {Lolth.Spider.Config, :set},
    Lolth.Spider.Page
  ]

  # api
  def start_link(_) do
    GenServer.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  # server impl
  def init(:no_args) do
    master_node = System.get_env("MASTER_NODE", "")

    if master_node == "" do
      init_master()
    else
      master_node
      |> String.to_atom()
      |> add_self_to_cluster()
    end

    {:ok, %{}}
  end

  def init_master() do
    Mnesia.stop()

    node_list = [node()]

    Mnesia.create_schema(node_list)

    Mnesia.start()

    table_names = create_tables(@schema_modules, node_list)

    Mnesia.wait_for_tables(table_names, 5_000)
  end

  def add_self_to_cluster(master_node) do
    Node.connect(master_node)

    Mnesia.start()

    :rpc.call(master_node, Lolth.Mnesia.Manager, :add_child_to_cluster, [node()])

    Enum.map(@schema_modules, fn module ->
      table_name = get_table_name(module)
      Mnesia.add_table_copy(table_name, node(), :disc_copies)
    end)
  end

  def add_child_to_cluster(child_node) do
    Mnesia.change_config(:extra_db_nodes, [child_node])

    Mnesia.change_table_copy_type(:schema, child_node, :disc_copies)
  end

  defp create_tables(modules, node_list) do
    Enum.map(modules, fn module ->
      create_table(module, node_list)
    end)
  end

  defp create_table(module, node_list) do
    table_name = get_table_name(module)

    options =
      get_table_options(module)
      |> Enum.concat([disc_copies: node_list])

    Mnesia.create_table(table_name, options)

    table_name
  end

  defp get_table_name({module, _type}) do
    get_table_name(module)
  end

  defp get_table_name(module) do
    module.__schema__(:source)
      |> String.to_atom
  end

  defp get_table_options({module, type}) do
    get_table_options(module)
      |> Enum.concat([type: type])
  end

  defp get_table_options(module) do
    [
      record_name: module,
      attributes: module.__schema__(:fields)
    ]
  end
end
