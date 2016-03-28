defmodule Arp.TableTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, _} = Arp.Table.start_link
    regexp = ~r/\A(\d+\.\d+\.\d+\.\d+) +[^ ]* +([0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+)/
    {:ok, regexp: regexp}
  end

#  test "stores a valid line", %{store: store, arp_table: arp_table, regexp: regexp} do
  test "stores a valid line", %{regexp: regexp} do
    line = "192.168.1.254            ether   00:11:22:33:44:55   C                     eth0"
    store = Arp.Table.addresses()
    Arp.Table.process(regexp, line, store)
    assert Arp.Table.get("192.168.1.254") == "00:11:22:33:44:55"
  end

#  test "doesn't store an invalid line", %{store: store, arp_table: arp_table, regexp: regexp} do
  test "doesn't store an invalid line", %{regexp: regexp} do
    line = "192.168.1.65                     (incomplete)                              eth0"
    store = Arp.Table.addresses()
    Arp.Table.process(regexp, line, store)
    assert Arp.Table.get("192.168.1.254") == nil
  end

#  test "doesn't store the header", %{store: store, arp_table: arp_table, regexp: regexp} do
  test "doesn't store the header", %{regexp: regexp} do
    line = "Address                  HWtype  HWaddress           Flags Mask            Iface"
    store = Arp.Table.addresses()
    Arp.Table.process(regexp, line, store)
    assert Arp.Table.get("Address") == nil
  end

#  test "doesn't store the footer", %{store: store, arp_table: arp_table, regexp: regexp} do
  test "doesn't store the footer", %{regexp: regexp} do
    line = ""
    store = Arp.Table.addresses()
    Arp.Table.process(regexp, line, store)
    assert Arp.Table.get("") == nil
  end
end
