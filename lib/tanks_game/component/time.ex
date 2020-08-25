defmodule TanksGame.Components.Time do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            created_at: Integer.t()
          }
        }

  use ECS.Component

  # defstruct [:created_at]
  defstruct [:pid, :state]

  def new(_state \\ %{}) do
    now_unixtime_miliseconds = (System.os_time(:nanosecond) / 1000) |> floor()
    state = %{created_at: now_unixtime_miliseconds}
    ECS.Component.new(__MODULE__, state)
  end
end
