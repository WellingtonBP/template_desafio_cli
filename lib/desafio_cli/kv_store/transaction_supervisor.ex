defmodule DesafioCli.KvStore.TransactionSupervisor do
  alias DesafioCli.KvStore.Transaction
  alias DesafioCli.KvStore.TransactionSupervisor

  use DynamicSupervisor

  @me TransactionSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_transaction(name, idx) do
    {:ok, pid} = DynamicSupervisor.start_child(@me, {Transaction, {name, idx}})
    pid
  end
end
