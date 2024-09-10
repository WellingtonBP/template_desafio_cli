defmodule DesafioCli.CLI do
  def start do
    loop()
  end

  defp loop do
    "> "
    |> IO.gets()
    |> String.trim()
    |> DesafioCli.Parser.parse()
    |> case do
      {:ok, result} ->
        IO.inspect(result)
        loop()

      {:error, reason} ->
        IO.puts("ERR #{reason}")
        loop()
    end
  end
end
