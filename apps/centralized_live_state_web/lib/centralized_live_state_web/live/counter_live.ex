defmodule CentralizedLiveStateWeb.CounterLive do
  use Phoenix.LiveView

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <h1 phx-click="boom">The count is: <%= @count %></h1>
      <button phx-click="boom" class="alert-danger">BOOM</button>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    """
  end

  @impl true
  def mount(_session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  @impl true
  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end
end
