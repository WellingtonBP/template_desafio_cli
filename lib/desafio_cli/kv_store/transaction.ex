defmodule DesafioCli.KvStore.Transaction do
  alias DesafioCli.Adt.Btree.Tree
  use GenServer, restart: :transient

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({shard_name, {:set, key, value}}, _from, state) do
    {status, updated_tree} =
      state
      |> Map.get(shard_name)
      |> Tree.insert({key, value})

    {:reply, status, Map.put(state, shard_name, updated_tree)}
  end

  def handle_call({shard_name, {:get, key}}, _from, state) do
    reply = Tree.search(Map.get(state, shard_name), key)
    {:reply, reply, state}
  end

  def handle_call({:commit}, _from, state) do
    send(self(), :stop)
    {:reply, state, state}
  end

  def handle_cast({:rollback}, state) do
    send(self(), :stop)
    {:noreply, state}
  end

  def handle_cast({:merge, stopped_transaction_state}, state) do
    updated_state =
      stopped_transaction_state
      |> Enum.map(fn {shard_name, tree} ->
        {shard_name, Tree.merge(Map.get(state, shard_name), tree)}
      end)
      |> Map.new()

    {:noreply, Map.merge(state, updated_state)}
  end

  def handle_info(:stop, _) do
    {:stop, :normal, nil}
  end
end
