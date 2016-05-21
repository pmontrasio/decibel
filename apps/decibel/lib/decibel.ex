defmodule Decibel do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    _ = spawn fn -> init_registries end

    children = [
      supervisor(Arp.Table, []),
      supervisor(MacAddress, []),
      # Start the endpoint when the application starts
      supervisor(Decibel.Endpoint, []),
      # Start the Ecto repository
      supervisor(Decibel.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Decibel.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Decibel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Decibel.Endpoint.config_change(changed, removed)
    :ok
  end

  def init_registries do
    KV.Registry.create(KV.Registry, "channels")
    KV.Registry.create(KV.Registry, "addresses")
  end

  def display do
    receive do
      devices ->
        Enum.each(devices, fn(device_info) ->
          {mac_address, average_dbm, len} = device_info
          IO.puts("#{mac_address}, #{len}, #{average_dbm}")
          {:ok, channel_store} = KV.Registry.lookup(KV.Registry, "channels")
          uuid = KV.Store.get(channel_store, mac_address)
          unless uuid == nil do
            IO.puts("Send #{average_dbm} to '#{mac_address}'")
            Decibel.Endpoint.broadcast! "rooms:" <> to_string(uuid), "dbm", %{dbm: average_dbm}
          end
        end)
        IO.puts("=====")
    end
    display
  end

end
