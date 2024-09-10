defmodule DesafioCli.KvStore.Backbone do
  alias DesafioCli.KvStore.ShardSupervisor
  use GenServer

  @me Backbone

  def start_link(shards_count) do
    GenServer.start_link(__MODULE__, %{shards_count: shards_count, transactions: []}, name: @me)
  end

  def init(state) do
    Process.send_after(self(), :start_shards, 0)
    {:ok, state}
  end

  def execute(command) do
    GenServer.call(@me, command)
  end

  def handle_info(:start_shards, %{shards_count: shards_count} = state) do
    Enum.each(1..shards_count, fn idx ->
      ShardSupervisor.add_shard(get_via_tuple("shard_#{idx}"))
    end)

    {:noreply, state}
  end

  def handle_call({:set, key, _} = command, _from, %{shards_count: shards_count} = state) do
    shard_idx = shard_idx_for_key(key, shards_count)
    shard_name = get_via_tuple("shard_#{shard_idx}")

    reply = GenServer.call(shard_name, command)

    {:reply, reply, state}
  end

  def handle_call({:get, key} = command, _from, %{shards_count: shards_count} = state) do
    shard_idx = shard_idx_for_key(key, shards_count)
    shard_name = get_via_tuple("shard_#{shard_idx}")

    reply = GenServer.call(shard_name, command)

    {:reply, reply, state}
  end

  defp get_via_tuple(id) do
    {:via, Registry, {:kv_store_registry, id}}
  end

  defp shard_idx_for_key(key, shards_count) do
    :erlang.phash2(key, shards_count)
  end
end
