defmodule DesafioCli.Parser do
  def parse(command) do
    command
    |> split()
    |> case do
      ["SET", key, value] ->
        {:ok, {:set, key, parse_value(value)}}

      ["GET", key] ->
        {:ok, {:get, key}}

      ["BEGIN"] ->
        {:ok, {:begin}}

      ["COMMIT"] ->
        {:ok, {:commit}}

      ["ROLLBACK"] ->
        {:ok, {:rollback}}

      ["SET" | _] ->
        {:error, "\"SET <chave> <valor> - Syntax error\""}

      ["GET" | _] ->
        {:error, "\"GET <chave> - Syntax error\""}

      [command | _] when command in ["BEGIN", "ROLLBACK", "COMMIT"] ->
        {:error, "\"#{command} - Syntax error\""}

      [command | _] ->
        {:error, "\"No command #{command}\""}
    end
  end

  def split(input) do
    ~r/"((?:\\.|[^"\\])*)"|(\S+)/x
    |> Regex.scan(input)
    |> Enum.map(fn
      [_, quoted] -> quoted
      [plain | _] -> plain
    end)
  end

  defp parse_value("TRUE"), do: :TRUE
  defp parse_value("FALSE"), do: :FALSE
  defp parse_value("NIL"), do: nil

  defp parse_value(value) do
    if String.match?(value, ~r/^\d+$/), do: String.to_integer(value), else: value
  end
end
