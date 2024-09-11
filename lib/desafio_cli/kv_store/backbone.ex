defmodule DesafioCli.KvStore.Backbone do
  alias DesafioCli.KvStore.TransactionSupervisor
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
      ShardSupervisor.add_shard(get_via_tuple("shard_#{idx}"), idx)
    end)

    {:noreply, state}
  end

  def handle_call({:set, _, nil}, _from, state) do
    {:reply, "FALSE NIL", state}
  end

  def handle_call(
        {:set, key, value} = command,
        _from,
        %{shards_count: shards_count, transactions: transactions} = state
      ) do
    shard_idx = shard_idx_for_key(key, shards_count)
    shard_name = get_via_tuple("shard_#{shard_idx}")

    reply =
      transactions
      |> case do
        [{_, transaction_name} | lower_transactions] ->
          existing = process_get(key, shards_count, lower_transactions)
          status = GenServer.call(transaction_name, {shard_name, command})

          case existing do
            :not_found ->
              status

            _ ->
              :updated
          end

        [] ->
          GenServer.call(shard_name, command)
      end
      |> set_command_response(value)

    {:reply, reply, state}
  end

  def handle_call(
        {:get, key},
        _from,
        %{shards_count: shards_count, transactions: transactions} = state
      ) do
    reply =
      key
      |> process_get(shards_count, transactions)
      |> get_command_response()

    {:reply, reply, state}
  end

  def handle_call({:begin}, _from, %{transactions: []} = state) do
    transaction_name = get_via_tuple("transaction_#{1}")
    TransactionSupervisor.add_transaction(transaction_name)

    {:reply, 1, %{state | transactions: [{1, transaction_name}]}}
  end

  def handle_call({:begin}, _from, %{transactions: [{last_idx, _} | _t] = transactions} = state) do
    transaction_idx = last_idx + 1
    transaction_name = get_via_tuple("transaction_#{transaction_idx}")
    TransactionSupervisor.add_transaction(transaction_name)

    {:reply, transaction_idx,
     %{state | transactions: [{transaction_idx, transaction_name} | transactions]}}
  end

  def handle_call({:commit}, _from, %{transactions: []} = state) do
    {:reply, "ERR \"COMMIT at level 0\"", state}
  end

  def handle_call(
        {:commit},
        _from,
        %{transactions: [{transaction_idx, transaction_name} | lower_transactions]} = state
      ) do
    stopped_transaction_state = GenServer.call(transaction_name, {:commit})

    case lower_transactions do
      [] ->
        Enum.each(stopped_transaction_state, fn {shard_name, tree} ->
          GenServer.cast(shard_name, {:merge, tree})
        end)

      [{_, lower_transaction_name} | _] ->
        GenServer.cast(lower_transaction_name, {:merge, stopped_transaction_state})
    end

    {:reply, transaction_idx - 1, %{state | transactions: lower_transactions}}
  end

  def handle_call({:rollback}, _from, %{transactions: []} = state) do
    {:reply, "ERR \"ROLLBACK at level 0\"", state}
  end

  def handle_call(
        {:rollback},
        _from,
        %{transactions: [{transaction_idx, transaction_name} | transactions]} = state
      ) do
    GenServer.cast(transaction_name, {:rollback})
    {:reply, transaction_idx - 1, %{state | transactions: transactions}}
  end

  defp get_via_tuple(id) do
    {:via, Registry, {:kv_store_registry, id}}
  end

  defp shard_idx_for_key(key, shards_count) do
    :erlang.phash2(key, shards_count) + 1
  end

  defp process_get(key, shards_count, transactions) do
    shard_idx = shard_idx_for_key(key, shards_count)
    shard_name = get_via_tuple("shard_#{shard_idx}")

    transactions
    |> case do
      [] ->
        GenServer.call(shard_name, {:get, key})

      transactions ->
        get_in_transactions(transactions, {shard_name, {:get, key}}, nil)
    end
  end

  defp set_command_response(:inserted, value), do: "FALSE #{value}"
  defp set_command_response(:updated, value), do: "TRUE #{value}"

  defp get_command_response(:not_found), do: "NIL"
  defp get_command_response({:found, {_key, value}}), do: value

  defp get_in_transactions([], {shard_name, command}, :not_found),
    do: GenServer.call(shard_name, command)

  defp get_in_transactions([], _payload, response), do: response
  defp get_in_transactions(_, _payload, {:found, _} = response), do: response

  defp get_in_transactions([{_, transaction_name} | transactions], payload, _response),
    do: get_in_transactions(transactions, payload, GenServer.call(transaction_name, payload))
end
