# iex -S mix run

KV.Registry.create(KV.Registry, "addresses")
{:ok, _} = Arp.Table.start_link()
:timer.sleep(2500)
IO.puts Arp.Table.get("192.168.1.254")


# or
# nvm use v5.7.0
# iex -S mix phoenix.server
# KV.Registry.create(KV.Registry, "addresses")
# {:ok, _} = Arp.Table.start_link()
# {:ok, store} = KV.Registry.lookup(KV.Registry, "addresses")
# IO.puts KV.Store.get(store, "192.168.1.254")

# TODO
# Aggiungere rotta per la home page a un controller
# Leggere l'IP address della richiesta
# Query allo store
# Mandarla via web socket
# defmodule WiFi.Monitor in polling su tshark
#   probabilmente tshark scrive su una pipe e Elixir legge
#   parse delle righe, tenere in memoria i dati
#   ogni X secondi mandare a Phoenix il sommario
#   Phoenix manda i dbm ai client via websocket
