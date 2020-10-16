defmodule Tanks.Game.Event.Control do
  @type t :: %__MODULE__{
          data: map(),
          entity_id: Integer.t(),
          entity_module: String.t()
        }

  defstruct [:entity_id, :entity_module, :data]

  def new(entity_module, entity_id, data) do
    %__MODULE__{entity_module: entity_module, entity_id: entity_id, data: data}
  end
end
