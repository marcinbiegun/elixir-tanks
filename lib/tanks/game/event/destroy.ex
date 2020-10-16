defmodule Tanks.Game.Event.Destroy do
  @type t :: %__MODULE__{
          entity_id: Integer.t(),
          entity_module: String.t()
        }

  defstruct [:entity_module, :entity_id]

  def new(entity_module, entity_id) do
    %__MODULE__{entity_module: entity_module, entity_id: entity_id}
  end
end
