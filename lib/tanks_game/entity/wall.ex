defmodule TanksGame.Entity.Wall do
  alias TanksGame.Components.{
    Position,
    Size
  }

  @type t :: %__MODULE__{
          id: Integer.t(),
          components: %{
            position: Position.t(),
            size: Size.t()
          }
        }

  defstruct [:id, :components]

  @size 30

  def new(x, y) do
    position = TanksGame.Components.Position.new(%{x: x, y: y})
    size = TanksGame.Components.Size.new(%{size: @size})

    components = %{
      position: position,
      size: size
    }

    ECS.Entity.new(__MODULE__, components)
  end
end
