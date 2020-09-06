defmodule TanksGame.System.Collision do
  alias TanksGame.Components.Position
  alias TanksGame.Components.Size
  alias :math, as: Math

  # Must be sorted alphabetically
  @entity_collisions [
    {TanksGame.Entity.Projectile, TanksGame.Entity.Wall},
    {TanksGame.Entity.Projectile, TanksGame.Entity.Zombie}
  ]

  defp interesting_collision?(entity_type, other_entity_type) do
    {entity_type, other_entity_type} in @entity_collisions
  end

  @component_types [Position, Size]
  def component_types, do: @component_types

  def process do
    component_tuples()
    |> Enum.map(fn tuple -> build(tuple, :move) end)
    |> detect()
  end

  defp build({entity_type, entity_id, {position_pid, size_pid}}, :move) do
    %{x: pos_x, y: pos_y} = ECS.Component.get_state(position_pid)
    %{size: size} = ECS.Component.get_state(size_pid)

    {entity_type, entity_id, pos_x, pos_y, size}
  end

  defp detect(collidables) do
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
          entity_type,
          entity_id,
          other_entity_type,
          other_entity_id
        )
      end
    end)
  end

  def resolve_collision(
        TanksGame.Entity.Projectile,
        projectile_id,
        TanksGame.Entity.Wall,
        _wall_id
      ) do
    destroy_projectile =
      TanksGame.Event.Destroy.new(
        TanksGame.Entity.Projectile,
        projectile_id
      )

    ECS.Queue.put(:internal, destroy_projectile)
  end

  def resolve_collision(
        TanksGame.Entity.Projectile,
        projectile_id,
        TanksGame.Entity.Zombie,
        zombie_id
      ) do
    destroy_zombie =
      TanksGame.Event.Destroy.new(
        TanksGame.Entity.Zombie,
        zombie_id
      )

    ECS.Queue.put(:internal, destroy_zombie)

    destroy_projectile =
      TanksGame.Event.Destroy.new(
        TanksGame.Entity.Projectile,
        projectile_id
      )

    ECS.Queue.put(:internal, destroy_projectile)
  end

  def resolve_collision(_, _, _, _), do: :ok

  defp component_tuples do
    ECS.Registry.ComponentTuple.build_registry_id(@component_types)
    |> ECS.Registry.ComponentTuple.get()
  end
end
