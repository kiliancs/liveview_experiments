defmodule Vs.State do
  use GenServer

  @type leaderboard :: %{String.t() => number}
  @type state :: {:idle, leaderboard}, {:countdown, number, leaderboard} | {:playing, number, leaderboard} | {:ended, leaderboard}

  @game_duration 15
  @countdown_duration 3

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Vs.PubSub, self(), "vs")
    get_state()
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(Vs.PubSub, self(), "vs")
  end

  def get_state, do: GenServer.call(__MODULE__, :get_state)
  def add_team(name), do: GenServer.call(__MODULE__, {:add_team, name})
  def inc_team(team), do: GenServer.call(__MODULE__, {:inc_team, team})
  def start, do: GenServer.call(__MODULE__, :start_countdown)

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_call({:add_team, name}, _from, {:idle, leaderboard}) do
    {:reply, :ok, {:idle, Map.put_new(leaderboard, name, 0)}}
  end

  @impl true
  def handle_call({:inc_team, name}, _from, {:playing, countdown, leaderboard}) do
    Phoenix.PubSub.broadcast!(Vs.PubSub, "vs", {:inc_team, name})
    new_score = Map.get(leaderboard, name) + 1
    {:reply, {:ok, new_score}, {:playing, countdown, Map.put(leaderboard, name, new_score)}}
  end

  @impl true
  def handle_call({:inc_team, _}, _from, {:ended, leaderboard}) do
    {:reply, {:error, :ended}, {:ended, leaderboard}}
  end

  @impl true
  def handle_call(:start_countdown, _from, {_status, leaderboard}) do
    :timer.send_after(1000, :dec_countdown)

    new_leaderboard = leaderboard |> Enum.map(fn ({team, _score}) -> {team, 0} end) |> Map.new

    Phoenix.PubSub.broadcast!(Vs.PubSub, "vs", {:countdown, @countdown_duration, new_leaderboard})
    {:reply, :ok, {:countdown, @countdown_duration, new_leaderboard}}
  end

  @impl true
  def handle_info(:dec_countdown, {:countdown, 1, leaderboard}) do
    :timer.send_after(1000, :dec_countdown)

    Phoenix.PubSub.broadcast!(Vs.PubSub, "vs", {:play, @game_duration})
    {:noreply, {:playing, @game_duration, leaderboard}}
  end

  @impl true
  def handle_info(:dec_countdown, {:playing, 1, leaderboard}) do
    Phoenix.PubSub.broadcast!(Vs.PubSub, "vs", :ended)
    {:noreply, {:ended, leaderboard}}
  end

  @impl true
  def handle_info(:dec_countdown, {status, seconds_to_go, leaderboard}) do
    :timer.send_after(1000, :dec_countdown)

    new_seconds_to_go = seconds_to_go - 1

    Phoenix.PubSub.broadcast!(Vs.PubSub, "vs", {:dec_countdown, new_seconds_to_go})
    {:noreply, {status, new_seconds_to_go, leaderboard}}
  end
end
