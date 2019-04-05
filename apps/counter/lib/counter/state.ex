defmodule Counter.State do
  use GenServer

  def start_link(initial_count) do
    GenServer.start_link(__MODULE__, initial_count, name: __MODULE__)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Counter.PubSub, self(), "counter")
    get_count()
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(Counter.PubSub, self(), "counter")
  end

  def get_count, do: GenServer.call(__MODULE__, :get_count)
  def inc, do: GenServer.call(__MODULE__, :inc)
  def dec, do: GenServer.call(__MODULE__, :dec)

  @impl true
  def init(initial_count), do: {:ok, initial_count}

  @impl true
  def handle_call(:get_count, _from, count), do: {:reply, count, count}

  @impl true
  def handle_call(:inc, _from, count) do
    new_count = count + 1

    Phoenix.PubSub.broadcast!(Counter.PubSub, "counter", {:count, new_count})
    {:reply, new_count, new_count}
  end

  @impl true
  def handle_call(:dec, _from, count) do
    new_count = count - 1

    Phoenix.PubSub.broadcast!(Counter.PubSub, "counter", {:count, new_count})
    {:reply, new_count, new_count}
  end
end
