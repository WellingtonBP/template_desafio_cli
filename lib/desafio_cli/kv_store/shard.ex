defmodule DesafioCli.KvStore.Shard do
  alias DesafioCli.KvStore.Persistence
  alias DesafioCli.Adt.Btree.Tree
  use GenServer, restart: :permanent

  def start_link({name, idx}) do
    GenServer.start_link(__MODULE__, %{tree: nil, shard_idx: idx}, name: name)
  end

  def init(state) do
    Process.send_after(self(), :load_data, 0)
    {:ok, state}
  end

  def handle_call({:set, key, value}, _from, %{tree: tree} = state) do
    {status, updated_tree} = Tree.insert(tree, {key, value})
    send(self(), :sync_data)
    {:reply, status, %{state | tree: updated_tree}}
  end

  def handle_call({:get, key}, _from, %{tree: tree} = state) do
    {:reply, Tree.search(tree, key), state}
  end

  def handle_cast({:merge, tree_to_merge}, %{tree: tree} = state) do
    updated_tree = Tree.merge(tree, tree_to_merge)
    send(self(), :sync_data)
    {:noreply, %{state | tree: updated_tree}}
  end

  def handle_info(:load_data, %{shard_idx: idx} = state) do
    {:noreply, %{state | tree: Persistence.read_file("shard_#{idx}")}}
  end

  def handle_info(:sync_data, %{tree: tree, shard_idx: idx} = state) do
    Persistence.write_file("shard_#{idx}", tree)
    {:noreply, state}
  end
end
