defmodule Tanks.Game.Components.Brain do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            last_decision_at: Integer.t(),
            sight_range: float()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(%{sight_range: sight_range}) do
    now = System.os_time(:millisecond)
    state = %{last_decision_at: now, sight_range: sight_range}
    ECS.Component.new(__MODULE__, state)
  end
end
