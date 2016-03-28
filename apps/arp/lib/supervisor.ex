defmodule Arp.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
                #worker(Arp.Table, [Arp.Table]),
      supervisor(Arp.Table.Supervisor, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
