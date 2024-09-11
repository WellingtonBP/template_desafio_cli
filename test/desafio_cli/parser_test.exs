defmodule DesafioCli.ParserTest do
  use ExUnit.Case

  alias DesafioCli.Parser

  describe "parse/1" do
    test "parses 'SET' command with key and value" do
      assert Parser.parse("SET key value") == {:ok, {:set, "key", "value"}}
    end

    test "parses 'SET' command with key and integer value" do
      assert Parser.parse("SET key 123") == {:ok, {:set, "key", 123}}
    end

    test "parses 'SET' command with key and boolean value" do
      assert Parser.parse("SET key TRUE") == {:ok, {:set, "key", :TRUE}}
      assert Parser.parse("SET key FALSE") == {:ok, {:set, "key", :FALSE}}
    end

    test "parses 'SET' command with key and nil value" do
      assert Parser.parse("SET key NIL") == {:ok, {:set, "key", nil}}
    end

    test "parses 'GET' command with key" do
      assert Parser.parse("GET key") == {:ok, {:get, "key"}}
    end

    test "parses 'BEGIN' command" do
      assert Parser.parse("BEGIN") == {:ok, {:begin}}
    end

    test "parses 'COMMIT' command" do
      assert Parser.parse("COMMIT") == {:ok, {:commit}}
    end

    test "parses 'ROLLBACK' command" do
      assert Parser.parse("ROLLBACK") == {:ok, {:rollback}}
    end

    test "returns error for invalid 'SET' command" do
      assert Parser.parse("SET key") == {:error, "\"SET <chave> <valor> - Syntax error\""}
    end

    test "returns error for invalid 'GET' command" do
      assert Parser.parse("GET") == {:error, "\"GET <chave> - Syntax error\""}
    end

    test "returns error for unknown command" do
      assert Parser.parse("UNKNOWN command") == {:error, "\"No command UNKNOWN\""}
    end

    test "returns error for invalid 'BEGIN', 'ROLLBACK', 'COMMIT' commands" do
      assert Parser.parse("BEGIN extra") == {:error, "\"BEGIN - Syntax error\""}
      assert Parser.parse("ROLLBACK extra") == {:error, "\"ROLLBACK - Syntax error\""}
      assert Parser.parse("COMMIT extra") == {:error, "\"COMMIT - Syntax error\""}
    end

    test "parses quoted strings" do
      assert Parser.parse(~s(SET "key with spaces" "value with spaces")) ==
               {:ok, {:set, "key with spaces", "value with spaces"}}

      assert Parser.parse(~s(GET "key with spaces")) == {:ok, {:get, "key with spaces"}}
    end
  end
end
