
defmodule CentralizedLiveStateWeb.VsLive do
  use Phoenix.LiveView

  @impl true
  def render(assigns) do
    case assigns.status do
      :countdown ->
        ~L"""
        <div class="countdown">
          <span class="countdown-number"><%= @countdown %></span>
        </div>
        """
      :playing ->
        ~L"""
        <div class="playing">
          <span class="countdown-number"><%= @countdown %></span>
          <div class="teams">
            <%= for {team_name, team_score} <- @leaderboard do %>
              <div class="team">
                <h2 class="name"><%= team_name %></h2>
                <div class="score"><%= team_score %></div>
                <button class="inc-btn" phx-click="inc" value="<%= team_name %>">+</button>
              </div>
            <% end %>
          </div>
        </div>
        """
      :ended ->
        ~L"""
        <div class="ended">
          <p class="winner">
            <%= if @winner == nil do %>
              That's a tie!
            <% else %>
              <%= @winner %> wins!
            <% end %>
          </p>
          <table class="leaderboard">
            <%= for {{team_name, team_score}, i} <- Enum.with_index(@sorted_leaderboard) do %>
              <tr>
                  <td class="index"><%= i + 1 %></td>
                  <td class="team"><%= team_name %></td>
                  <td class="score"><%= team_score %></td>
              </tr>
            <% end %>
          </table>
        </div>
        """
      _ ->
        ~L"""
        <p>This hasn't started yet.</p>
        """
    end
  end

  @impl true
  def mount(_session, socket) do
    state = Vs.State.subscribe()
    {:ok, assign_from_state(socket, state)}
  end

  @impl true
  def handle_event("inc", team, socket) do
    Vs.State.inc_team(team)
    {:noreply, socket}
  end

  def handle_info({:play, countdown}, socket) do
    {:noreply, assign(socket, %{
      status: :playing,
      countdown: countdown,
    })}
  end

  def handle_info({:countdown, countdown, leaderboard}, socket) do
    {:noreply, assign(socket, %{
      status: :countdown,
      countdown: countdown,
      leaderboard: leaderboard
    })}
  end

  def handle_info({:dec_countdown, countdown}, socket) do
    {:noreply, assign(socket, :countdown, countdown)}
  end

  def handle_info({:inc_team, name}, socket) do
    new_score = Map.get(socket.assigns.leaderboard, name) + 1
    {:noreply, assign(socket, :leaderboard, Map.put(socket.assigns.leaderboard, name, new_score))}
  end

  def handle_info(:ended, socket) do
    {:noreply,
      socket
      |> assign(:status, :ended)
      |> assign_results(socket.assigns.leaderboard)
    }
  end

  defp assign_from_state(socket, {status, countdown, leaderboard}) do
    socket
    |> assign(%{
      status: status,
      countdown: countdown,
      leaderboard: leaderboard,
    })
    |> assign_results(leaderboard)
  end

  defp assign_from_state(socket, {status, leaderboard}) do
    socket
    |> assign(%{
      status: status,
      countdown: nil,
      leaderboard: leaderboard,
    })
    |> assign_results(leaderboard)
  end

  @impl true
  def terminate(_reason, _state) do
    Vs.State.unsubscribe()
  end

  def assign_results(socket, leaderboard) do
    sorted_leaderboard = leaderboard |> Enum.sort_by(fn ({_name, score}) -> score end, &(&1 >= &2))

    winner = case sorted_leaderboard |> Enum.take(2) do
      [{_, score}, {_, score}] -> nil
      [{winner_name, _}, _] -> winner_name
    end

    assign(socket, %{
      sorted_leaderboard: sorted_leaderboard,
      winner: winner,
    })
  end
end
