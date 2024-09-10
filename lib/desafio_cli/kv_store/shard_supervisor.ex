defmodule DesafioCli.KvStore.ShardSupervisor do
  alias DesafioCli.KvStore.Shard
  alias DesafioCli.KvStore.ShardSupervisor

  use DynamicSupervisor

  @me ShardSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_shard(name, idx) do
    {:ok, pid} = DynamicSupervisor.start_child(@me, {Shard, {name, idx}})
    pid
  end
end
