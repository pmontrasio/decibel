defmodule Arp.Table do

  def start_link do
    regexp = ~r/\A(\d+\.\d+\.\d+\.\d+) +[^ ]* +([0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+:[0-9abcdef]+)/

    Task.start_link(fn -> poll(regexp) end)
  end

  # this calls arp -n once per second to maintain a fresh map of ip to mac addresses
  def poll(regexp) do
    { arp_output, 0 } = System.cmd("arp", ["-n"])
    {:ok, address_store} = KV.Registry.lookup(KV.Registry, "addresses")
    addresses = String.split(arp_output, "\n")
    Enum.each(addresses, fn line -> process(regexp, line, address_store) end)
    :timer.sleep(1000)
    poll(regexp)
  end

  def process(regexp, line, address_store) do
    case Regex.run(regexp, line) do
      [_, ip_address, mac_address] -> KV.Store.put(address_store, ip_address, mac_address)
      _ -> nil
    end
  end

  def get(ip_address) do
    {:ok, address_store} = KV.Registry.lookup(KV.Registry, "addresses")
    KV.Store.get(address_store, ip_address)
  end

  def addresses() do
    {:ok, address_store} = KV.Registry.lookup(KV.Registry, "addresses")
    address_store
  end


end
