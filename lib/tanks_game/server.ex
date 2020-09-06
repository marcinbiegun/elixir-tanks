defmodule TanksGame.Server do
  use GenServer
  require Logger

  @registry :servers_registry
  @tickms 16

  @initial_state %{
    id: nil,
    player_id: nil
  }

  @projectile_speed 5.0

  # API

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def state(id) do
    GenServer.call(via_tuple(id), :state)
  end

  def stop(id) do
    GenServer.stop(via_tuple(id))
  end

  def crash(id) do
    GenServer.cast(via_tuple(id), :raise)
  end

  def send_input(id, input) do
    GenServer.cast(via_tuple(id), {:update_input, input})
  end

  def send_action(id, :fire, {x, y}) do
    GenServer.cast(via_tuple(id), {:action, :fire, {x, y}})
  end

  # Callbacks

  def init(id) do
    Logger.info("Starting #{__MODULE__} #{id}")

    Process.send_after(self(), :tick, @tickms)

    player = TanksGame.Entity.Player.new()

    TanksGame.Entity.Wall.new(100, 100)
    TanksGame.Entity.Wall.new(100, 150)
    TanksGame.Entity.Wall.new(100, 200)
    TanksGame.Entity.Wall.new(500, 100)
    TanksGame.Entity.Wall.new(500, 150)
    TanksGame.Entity.Wall.new(500, 200)

    TanksGame.Entity.Zombie.new(250, 250)
    TanksGame.Entity.Zombie.new(250, 270)
    TanksGame.Entity.Zombie.new(250, 290)

    {:ok, %{@initial_state | id: id, player_id: player.id}}
  end

  def handle_info(:tick, state) do
    start_ns = System.os_time(:nanosecond)

    new_state = do_tick(state)
    client_state = state_for_client(new_state)

    TanksWeb.Endpoint.broadcast!("game:#{state.id}", "tick", client_state)

    took_ns = System.os_time(:nanosecond) - start_ns
    took_ms = Float.round(took_ns / 1_000_000, 2)

    # Logger.debug("Tick took #{round(took_ns / 1000)} μs")

    Process.send_after(self(), :tick, max(@tickms - round(took_ms), 0))
    {:noreply, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_cast({:update_input, input}, state) do
    event = TanksGame.Event.Control.new(TanksGame.Entity.Player, state.player_id, input)
    ECS.Queue.put(:input, event)

    {:noreply, state}
  end

  def handle_cast({:action, :fire, {velocity_x, velocity_y}}, state) do
    player = ECS.Registry.Entity.get(TanksGame.Entity.Player, state.player_id)
    %{x: player_x, y: player_y} = player.components.position.state

    TanksGame.Entity.Projectile.new(
      player_x,
      player_y,
      velocity_x * @projectile_speed,
      velocity_y * @projectile_speed,
      2000
    )

    {:noreply, state}
  end

  def handle_cast(:raise, state) do
    raise RuntimeError, message: "Error, #{__MODULE__} #{state.id} has crashed"
  end

  def terminate(reason, state) do
    Logger.info("Exiting worker: #{__MODULE__} #{state.id} with reason: #{inspect(reason)}")
  end

  ## Private
  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}

  defp do_tick(state) do
    process_input_events()
    TanksGame.System.LifetimeDying.process()
    TanksGame.System.Movement.process()
    TanksGame.System.Velocity.process()
    TanksGame.System.Collision.process()
    process_internal_events()
    state
  end

  defp state_for_client(state) do
    player = ECS.Registry.Entity.get(TanksGame.Entity.Player, state.player_id)
    %{x: player_x, y: player_y} = player.components.position.state

    projectiles =
      ECS.Registry.Entity.all(TanksGame.Entity.Projectile)
      |> Enum.map(fn entity ->
        data = entity.components.position.state |> Map.take([:x, :y])
        {entity.id, data}
      end)
      |> Map.new()

    walls =
      ECS.Registry.Entity.all(TanksGame.Entity.Wall)
      |> Enum.map(fn entity ->
        data = entity.components.position.state |> Map.take([:x, :y])
        {entity.id, data}
      end)
      |> Map.new()

    zombies =
      ECS.Registry.Entity.all(TanksGame.Entity.Zombie)
      |> Enum.map(fn entity ->
        data = entity.components.position.state |> Map.take([:x, :y])
        {entity.id, data}
      end)
      |> Map.new()

    %{x: player_x, y: player_y, projectiles: projectiles, walls: walls, zombies: zombies}
  end

  def process_input_events() do
    events = ECS.Queue.pop_all(:input) |> Enum.reverse()

    Enum.map(events, fn event ->
      TanksGame.EventProcessor.process_event(event)
    end)
  end

  def process_internal_events() do
    events = ECS.Queue.pop_all(:internal) |> Enum.reverse()

    Enum.map(events, fn event ->
      TanksGame.EventProcessor.process_event(event)
    end)
  end
end
