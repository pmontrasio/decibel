defmodule Arp do
  use Application

  def start(_type, _args) do
    Arp.Supervisor.start_link
  end
end
