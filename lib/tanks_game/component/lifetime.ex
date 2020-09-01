defmodule TanksGame.Components.Lifetime do
  @type t :: %__MODULE__{
          pid: pid(),
          state: %{
            die_at: Integer.t()
          }
        }

  use ECS.Component

  defstruct [:pid, :state]

  def new(lifetime) do
    now = System.os_time(:millisecond)
    state = %{die_at: now + lifetime}
    ECS.Component.new(__MODULE__, state)
  end
end
