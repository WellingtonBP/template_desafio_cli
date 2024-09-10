defmodule DesafioCli.KvStore.Application do
  use Application

  alias DesafioCli.KvStore.{Backbone, ShardSupervisor, Persistence, TransactionSupervisor}

  @application :kv_store

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: :kv_store_registry},
      {Backbone, Application.get_env(@application, :shards, 2)},
      Persistence,
      ShardSupervisor,
      TransactionSupervisor
    ]

    opts = [strategy: :one_for_all, name: KvStore]
    Supervisor.start_link(children, opts)
  end
end
