defmodule Counter.State do
  use GenServer

  @typep state :: %{count: number, subscribers: MapSet}

  def start_link(initial_count) do
    GenServer.start_link(__MODULE__, initial_count, name: __MODULE__)
  end

  def subscribe do
    GenServer.call(__MODULE__, {:subscribe, self()})
  end

  def inc do
    GenServer.call(__MODULE__, :inc)
  end

  def dec do
    GenServer.call(__MODULE__, :dec)
  end

  @spec broadcast_count(state) :: :ok
  defp broadcast_count(state) do
    Enum.each(state.subscribers, &send(&1, {:count, state.count}))
  end

  @impl true
  def init(initial_count) do
    {:ok, %{count: initial_count, subscribers: MapSet.new()}}
  end

  @impl true
  def handle_call(:inc, _from, state) do
    new_state = %{state | count: state.count + 1}

    broadcast_count(new_state)
    {:reply, new_state.count, new_state}
  end

  @impl true
  def handle_call(:dec, _from, state) do
    new_state = %{state | count: state.count - 1}

    broadcast_count(new_state)
    {:reply, new_state.count, new_state}
  end

  @impl true
  def handle_call({:subscribe, subscriber}, _from, state) do
    {:reply, state.count, Map.update!(state, :subscribers, &MapSet.put(&1, subscriber))}
  end
end
