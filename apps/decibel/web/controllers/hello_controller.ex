defmodule Decibel.HelloController do
  use Decibel.Web, :controller

  def index(conn, _params) do
    ip_address = Enum.join(Tuple.to_list(conn.remote_ip), ".")
    {:ok, address_store} = KV.Registry.lookup(KV.Registry, "addresses")
    mac_address = KV.Store.get(address_store, ip_address)
    {:ok, channel_store} = KV.Registry.lookup(KV.Registry, "channels")
    uuid =
      case KV.Store.get(channel_store, mac_address) do
        nil ->
          uuid = :uuid.to_string(:uuid.uuid1())
          KV.Store.put(channel_store, mac_address, uuid)
          uuid
        uuid -> uuid
      end
    render conn, "index.html", ip_address: ip_address, mac_address: mac_address, uuid: uuid
  end
end
