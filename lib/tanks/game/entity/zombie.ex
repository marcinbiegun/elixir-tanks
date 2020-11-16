defmodule Tanks.Game.Entity.Zombie do
  alias Tanks.Game.Components.{
    Attack,
    Brain,
    Control,
    Position,
    Size
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            attack: Attack.t(),
            brain: Brain.t(),
            control: Control.t(),
            meele_attack: Position.t(),
            position: Position.t(),
            size: Size.t()
          }
        }

  defstruct [:id, :components]

  @speed 1
  @size 20.0
  @shape :rectangle
  @meele_attack_range 20.0
  @meele_attack_reload 1000
  @sight_range 400.0

  def new(x, y) do
    attack =
      Attack.new(%{
        range: @meele_attack_range,
        reload: @meele_attack_reload
      })

    brain = Brain.new(%{sight_range: @sight_range})

    control =
      Control.new(%{
        down: false,
        left: false,
        right: false,
        up: false,
        speed: @speed
      })

    shape = {@shape, @size}
    size = Size.new(%{shape: shape})
    position = Position.new(%{x: x, y: y})

    components = %{
      attack: attack,
      brain: brain,
      control: control,
      position: position,
      size: size
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
