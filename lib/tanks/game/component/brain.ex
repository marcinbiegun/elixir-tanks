defmodule Tanks.Game.Components.Brain do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            last_decision_at: Integer.t()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(_params \\ %{}) do
    now = System.os_time(:millisecond)
    state = %{last_decision_at: now}
    ECS.Component.new(__MODULE__, state)
  end
end
