defmodule Solcsv.Ports.Types.ViacepInput do
  @moduledoc false

  @type t :: %__MODULE__{
    cep: String.t(),
  }

  @enforce_keys [:cep]
  defstruct [:cep]
end
