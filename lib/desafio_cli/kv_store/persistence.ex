defmodule DesafioCli.KvStore.Persistence do
  alias DesafioCli.KvStore.Persistence
  use GenServer

  @me Persistence

  def start_link(_) do
    GenServer.start(__MODULE__, :no_args, name: @me)
  end

  def init(:no_args) do
    {:ok, nil}
  end
end
