defmodule DesafioCli.CLI do
  alias DesafioCli.KvStore.Backbone

  def start do
    loop()
  end

  defp loop do
    "> "
    |> IO.gets()
    |> String.trim()
    |> DesafioCli.Parser.parse()
    |> case do
      {:ok, command} ->
        command
        |> Backbone.execute()
        |> IO.puts()

        loop()

      {:error, reason} ->
        IO.puts("ERR #{reason}")
        loop()
    end
  end
end
