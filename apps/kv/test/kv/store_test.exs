defmodule KV.StoreTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, store} = KV.Store.start_link
    {:ok, store: store}
  end

  test "stores values by key", %{store: store} do
    assert KV.Store.get(store, "192.168.1.1") == nil
    KV.Store.put(store, "192.168.1.1", "aa:bb:cc:dd:ee:ff")
    assert KV.Store.get(store, "192.168.1.1") == "aa:bb:cc:dd:ee:ff"
  end

  test "updates an existing value", %{store: store} do
    KV.Store.put(store, "192.168.1.1", "aa:bb:cc:dd:ee:ff")
    KV.Store.put(store, "192.168.1.1", "00:11:22:33:44:55")
    assert KV.Store.get(store, "192.168.1.1") == "00:11:22:33:44:55"
  end
end
