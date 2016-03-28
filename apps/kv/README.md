# KV

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add kv to your list of dependencies in `mix.exs`:

        def deps do
          [{:kv, "~> 0.0.1"}]
        end

  2. Ensure kv is started before your application:

        def application do
          [applications: [:kv]]
        end



# Running

iex -S mix

:observer.start
KV.Registry.create KV.Registry, "addresses"
{:ok, addresses} = KV.Registry.lookup(KV.Registry, "addresses")
KV.Store.put(addresses, "192.168.1.1", "00:11:22:33:44:55")
KV.Store.put(addresses, "192.168.1.2", "11:11:22:33:44:55")


mix run arp.exs
