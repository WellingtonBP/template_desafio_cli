defmodule DesafioCli.Adt.Btree.Node do
  defstruct [
    :left,
    :right,
    :value
  ]

  @type t :: %__MODULE__{
          left: __MODULE__.t(),
          right: __MODULE__.t(),
          value: {String.t(), String.t() | boolean() | integer()}
        }
end
