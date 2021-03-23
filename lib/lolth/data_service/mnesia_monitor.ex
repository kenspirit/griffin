defmodule Lolth.DataService.Monitor.Mnesia do
  use GenServer

  @name __MODULE__

  def start_link(state) do
    GenServer.start_link(@name, state, name: @name)
  end

  def init(state) do
    :mnesia.subscribe(:system)
    :mnesia.subscribe({:table, :content, :simple})

    {:ok, state}
  end

  def handle_info({:mnesia_system_event, event}, state) do
    IO.puts "Received system event"
    IO.inspect event
    {:noreply, state}
  end

  def handle_info({:mnesia_table_event, event}, state) do
    IO.puts "Received table event"
    IO.inspect event
    {:noreply, state}
  end
end
