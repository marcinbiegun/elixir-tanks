defmodule Tanks.Game.Components.Attack do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            range: float(),
            reload: Integer.t(),
            next_attack_at: Integer.t()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(%{range: range, reload: reload}) do
    state = %{range: range, reload: reload, next_attack_at: 0}
    ECS.Component.new(__MODULE__, state)
  end
end
