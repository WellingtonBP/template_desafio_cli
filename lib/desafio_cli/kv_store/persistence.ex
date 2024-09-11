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

  def write_file(path, content) do
    GenServer.cast(@me, {:write, path, content})
  end

  def read_file(path) do
    GenServer.call(@me, {:read, path})
  end

  def handle_call({:read, path}, _from_, nil) do
    reply =
      path
      |> File.read()
      |> case do
        {:ok, content} ->
          :erlang.binary_to_term(content)

        _ ->
          nil
      end

    {:reply, reply, nil}
  end

  def handle_cast({:write, path, content}, nil) do
    File.write(path, :erlang.term_to_binary(content))
    {:noreply, nil}
  end
end
