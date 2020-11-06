defmodule Tanks.Game.System.Collision do
  alias Tanks.Game.Components.Position
  alias Tanks.Game.Components.Size
  alias :math, as: Math

  # Must be sorted alphabetically
  @entity_collisions [
    {Tanks.Game.Entity.Projectile, Tanks.Game.Entity.Wall},
    {Tanks.Game.Entity.Projectile, Tanks.Game.Entity.Zombie}
  ]

  defp interesting_collision?(entity_type, other_entity_type) do
    {entity_type, other_entity_type} in @entity_collisions
  end

  @component_types [Position, Size]
  def component_types, do: @component_types

  def process(game_id) do
    tuples =
      component_tuples(game_id)
      |> Enum.map(fn tuple -> build(tuple, :move) end)

    tuples
    |> detect_size_collisions(game_id)

    tuples
    |> detect_boards_collisions(game_id)
  end

  defp build({entity_type, entity_id, {position_pid, size_pid}}, :move) do
    %{x: pos_x, y: pos_y} = ECS.Component.get_state(position_pid)
    %{size: size} = ECS.Component.get_state(size_pid)

    {entity_type, entity_id, pos_x, pos_y, size}
  end

  defp detect_size_collisions(collidables, game_id) do
    Utils.Combinatorics.combinations(collidables, 2)
    |> Enum.map(fn collidables_pair ->
      collidables_pair |> Enum.sort_by(&elem(&1, 0))
    end)
    |> Enum.filter(fn [collidable, other_collidable] ->
      interesting_collision?(collidable |> elem(0), other_collidable |> elem(0))
    end)
    |> Enum.each(fn collidables_pair ->
      [
        {entity_type, entity_id, pos_x, pos_y, size},
        {other_entity_type, other_entity_id, other_pos_x, other_pos_y, other_size}
      ] = collidables_pair

      distance = Math.sqrt(Math.pow(other_pos_x - pos_x, 2) + Math.pow(other_pos_y - pos_y, 2))

      if distance < size / 2 + other_size / 2 do
        resolve_collision(
          game_id,
          entity_type,
          entity_id,
          other_entity_type,
          other_entity_id
        )
      end
    end)
  end

  # TODO: move to config module
  @board_entity_type Tanks.Game.Entity.Board
  @board_tile_size 32
  @board_collidables [:wall]

  defp detect_boards_collisions(collidables, game_id) do
    ECS.Registry.Entity.all(game_id, @board_entity_type)
    |> Enum.map(fn board ->
      detect_board_collisions(collidables, board, game_id)
    end)
  end

  defp detect_board_collisions(collidables, board, game_id) do
    tiles = board.components.tiles.state.tiles

    collidables
    |> Enum.map(fn {entity_type, entity_id, pos_x, pos_y, size} ->
      if Utils.TilesComp.collides?(
           tiles,
           @board_tile_size,
           @board_collidables,
           pos_x,
           pos_y,
           size
         ) do
        resolve_board_collision(game_id, board, entity_type, entity_id)
      end
    end)
  end

  def resolve_collision(
        game_id,
        Tanks.Game.Entity.Projectile,
        projectile_id,
        Tanks.Game.Entity.Wall,
        wall_id
      ) do
    hit_event =
      Tanks.Game.Event.Hit.new(
        Tanks.Game.Entity.Wall,
        wall_id
      )

    ECS.Queue.put(game_id, :internal, hit_event)

    destroy_projectile_event =
      Tanks.Game.Event.Destroy.new(
        Tanks.Game.Entity.Projectile,
        projectile_id
      )

    ECS.Queue.put(game_id, :internal, destroy_projectile_event)
  end

  def resolve_collision(
        game_id,
        Tanks.Game.Entity.Projectile,
        projectile_id,
        Tanks.Game.Entity.Zombie,
        zombie_id
      ) do
    destroy_zombie_event =
      Tanks.Game.Event.Destroy.new(
        Tanks.Game.Entity.Zombie,
        zombie_id
      )

    ECS.Queue.put(game_id, :internal, destroy_zombie_event)

    destroy_projectile_event =
      Tanks.Game.Event.Destroy.new(
        Tanks.Game.Entity.Projectile,
        projectile_id
      )

    ECS.Queue.put(game_id, :internal, destroy_projectile_event)
  end

  def resolve_collision(_, _, _, _) do
    :ok
  end

  def resolve_board_collision(game_id, _board, Tanks.Game.Entity.Projectile, projectile_id) do
    destroy_projectile_event =
      Tanks.Game.Event.Destroy.new(
        Tanks.Game.Entity.Projectile,
        projectile_id
      )

    ECS.Queue.put(game_id, :internal, destroy_projectile_event)
  end

  def resolve_board_collision(_, _, _, _), do: :ok

  defp component_tuples(game_id) do
    id = ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    ECS.Registry.ComponentTuple.get(game_id, id)
  end
end
