defmodule DesafioCli.Adt.Btree.Tree do
  alias DesafioCli.Adt.Btree.Node, as: BtreeNode

  def insert(nil, key_value), do: {:inserted, %BtreeNode{value: key_value}}

  def insert(%BtreeNode{value: {key, _}} = root, {key, value}),
    do: {:updated, %BtreeNode{root | value: {key, value}}}

  def insert(%BtreeNode{left: left, value: {root_key, _}} = root, {key, _} = key_value)
      when root_key > key do
    {status, left} = insert(left, key_value)
    {status, %BtreeNode{root | left: left}}
  end

  def insert(%BtreeNode{right: right} = root, key_value) do
    {status, right} = insert(right, key_value)
    {status, %BtreeNode{root | right: right}}
  end

  def search(nil, _), do: :not_found
  def search(%BtreeNode{value: {key, value}} = _, key), do: {:found, {key, value}}

  def search(%BtreeNode{value: {key, _}, left: left} = _, searched_key)
      when key > searched_key,
      do: search(left, searched_key)

  def search(%BtreeNode{right: right} = _, searched_key),
    do: search(right, searched_key)

  def merge(root, tree) do
    tree
    |> values()
    |> Enum.reduce(root, fn value, acc ->
      acc
      |> insert(value)
      |> elem(1)
    end)
  end

  def values(nil), do: []

  def values(%BtreeNode{value: value, left: left, right: right}),
    do: values(left) ++ [value | values(right)]
end
