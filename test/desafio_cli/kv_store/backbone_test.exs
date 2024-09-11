defmodule DesafioCli.KvStore.BackboneTest do
  alias DesafioCli.KvStore
  use ExUnit.Case

  test "kvstore backbone" do
    key = to_string(System.os_time())

    # set
    assert KvStore.Backbone.execute({:set, key, "value1"}) == "FALSE value1"
    assert KvStore.Backbone.execute({:set, key, "value2"}) == "TRUE value2"

    assert KvStore.Backbone.execute({:set, "quoted_value_#{key}", "\"value quoted\""}) ==
             "FALSE \"value quoted\""

    # get
    assert KvStore.Backbone.execute({:get, key}) == "value2"
    assert KvStore.Backbone.execute({:get, "unexisting_#{key}"}) == "NIL"
    assert KvStore.Backbone.execute({:get, "quoted_value_#{key}"}) == "\"value quoted\""

    # transactions
    assert KvStore.Backbone.execute({:begin}) == 1
    assert KvStore.Backbone.execute({:set, key, "value3"}) == "TRUE value3"
    assert KvStore.Backbone.execute({:get, key}) == "value3"
    assert KvStore.Backbone.execute({:begin}) == 2
    assert KvStore.Backbone.execute({:set, key, "value4"}) == "TRUE value4"
    assert KvStore.Backbone.execute({:get, key}) == "value4"
    assert KvStore.Backbone.execute({:rollback}) == 1
    assert KvStore.Backbone.execute({:commit}) == 0
    assert KvStore.Backbone.execute({:get, key}) == "value3"
  end
end
