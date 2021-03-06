defmodule Arp.Table.Supervisor do
  use Supervisor

  # A simple module attribute that stores the supervisor name
  @name Arp.Table.Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      worker(Arp.Table, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
