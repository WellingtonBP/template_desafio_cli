defmodule DesafioCli.KvStore.Shard do
  alias DesafioCli.Adt.Btree.Tree
  use GenServer, restart: :permanent

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def init(nil) do
    {:ok, nil}
  end

  def handle_call({:set, key, value}, _from, tree) do
    {status, updated_tree} = Tree.insert(tree, {key, value})

    reply =
      status
      |> case do
        :inserted ->
          "FALSE #{value}"

        :updated ->
          "TRUE #{value}"
      end

    {:reply, reply, updated_tree}
  end

  def handle_call({:get, key}, _from, tree) do
    reply =
      tree
      |> Tree.search(key)
      |> case do
        :not_found ->
          "NIL"

        {:found, {_, value}} ->
          value
      end

    {:reply, reply, tree}
  end
end
