defmodule Counter.State do
  use GenServer

  def start_link(initial_count) do
    GenServer.start_link(__MODULE__, initial_count)
  end

  def inc do
    GenServer.call(__MODULE__, :inc)
  end

  def dec do
    GenServer.call(__MODULE__, :dec)
  end

  @impl true
  def init(initial_count) do
    {:ok, initial_count}
  end

  @impl true
  def handle_call(:inc, _from, count) do
    new_count = count + 1
    {:reply, new_count, new_count}
  end

  @impl true
  def handle_call(:dec, _from, count) do
    new_count = count - 1
    {:reply, new_count, new_count}
  end
end
