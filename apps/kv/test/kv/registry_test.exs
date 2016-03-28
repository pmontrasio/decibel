defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = KV.Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns stores", %{registry: registry} do
    assert KV.Registry.lookup(registry, "addresses") == :error

    KV.Registry.create(registry, "addresses")
    assert {:ok, store} = KV.Registry.lookup(registry, "addresses")

    assert KV.Store.get(store, "192.168.1.1") == nil
    KV.Store.put(store, "192.168.1.1", "aa:bb:cc:dd:ee:ff")
    assert KV.Store.get(store, "192.168.1.1") == "aa:bb:cc:dd:ee:ff"
  end

  test "updates an existing value", %{registry: registry} do
    KV.Registry.create(registry, "addresses")
    assert {:ok, store} = KV.Registry.lookup(registry, "addresses")

    KV.Store.put(store, "192.168.1.1", "aa:bb:cc:dd:ee:ff")
    KV.Store.put(store, "192.168.1.1", "00:11:22:33:44:55")
    assert KV.Store.get(store, "192.168.1.1") == "00:11:22:33:44:55"
  end

  test "removes store on exit", %{registry: registry} do
    KV.Registry.create(registry, "addresses")
    {:ok, store} = KV.Registry.lookup(registry, "addresses")
    Agent.stop(store)
    assert KV.Registry.lookup(registry, "addresses") == :error
  end

  test "removes store on crash", %{registry: registry} do
    KV.Registry.create(registry, "addresses")
    {:ok, store} = KV.Registry.lookup(registry, "addresses")

    # Stop the store with non-normal reason
    Process.exit(store, :shutdown)

    # Wait until the store is dead
    ref = Process.monitor(store)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert KV.Registry.lookup(registry, "addresses") == :error
  end

end
