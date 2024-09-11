defmodule DesafioCli.Adt.Btree.TreeTest do
  use ExUnit.Case
  alias DesafioCli.Adt.Btree.Node
  alias DesafioCli.Adt.Btree.Tree

  setup do
    tree = %Node{
      value: {"b", 2},
      left: %Node{value: {"a", 1}},
      right: %Node{value: {"c", 3}}
    }

    {:ok, tree: tree}
  end

  test "inserts a new node into an empty tree", _context do
    assert Tree.insert(nil, {"a", 1}) == {:inserted, %Node{value: {"a", 1}}}
  end

  test "updates an existing node", %{tree: tree} do
    assert Tree.insert(tree, {"b", 10}) ==
             {:updated,
              %Node{value: {"b", 10}, left: %Node{value: {"a", 1}}, right: %Node{value: {"c", 3}}}}
  end

  test "inserts a new node to the left subtree", %{tree: tree} do
    assert Tree.insert(tree, {"a", 10}) ==
             {:updated,
              %Node{value: {"b", 2}, left: %Node{value: {"a", 10}}, right: %Node{value: {"c", 3}}}}
  end

  test "inserts a new node to the right subtree", %{tree: tree} do
    assert Tree.insert(tree, {"d", 4}) ==
             {:inserted,
              %Node{
                value: {"b", 2},
                left: %Node{value: {"a", 1}},
                right: %Node{
                  value: {"c", 3},
                  right: %Node{value: {"d", 4}}
                }
              }}
  end

  test "searches for an existing key", %{tree: tree} do
    assert Tree.search(tree, "b") == {:found, {"b", 2}}
  end

  test "searches for a non-existing key", %{tree: tree} do
    assert Tree.search(tree, "x") == :not_found
  end

  test "merges two trees", _context do
    tree1 = %Node{
      value: {"a", 1},
      left: %Node{value: {"b", 2}},
      right: %Node{value: {"c", 3}}
    }

    tree2 = %Node{
      value: {"d", 4},
      left: %Node{value: {"e", 5}},
      right: %Node{value: {"f", 6}}
    }

    merged_tree = Tree.merge(tree1, tree2)

    assert Tree.search(merged_tree, "a") == {:found, {"a", 1}}
    assert Tree.search(merged_tree, "d") == {:found, {"d", 4}}
    assert Tree.search(merged_tree, "e") == {:found, {"e", 5}}
    assert Tree.search(merged_tree, "f") == {:found, {"f", 6}}
  end
end
