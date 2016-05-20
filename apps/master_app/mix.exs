defmodule MasterApp.Mixfile do
  use Mix.Project

  def project do
    [
     app: :master_app,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps
    ]
  end

  def application do
    [applications: [:logger, :kv_server, :mac_address_server, :arp_server, :decibel],
     mod: {MasterApp, []}]
  end

  defp deps do
    [
     {:kv_server, in_umbrella: true},
     {:mac_address_server, in_umbrella: true},
     {:arp_server, in_umbrella: true},
     {:decibel, in_umbrella: true},
     {:exrm, "~> 1.0.4"}
    ]
  end
end
