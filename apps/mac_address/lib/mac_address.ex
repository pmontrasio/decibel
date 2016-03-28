defmodule MacAddress do
  def start_link(client) do
    Task.start_link(fn -> init(client) end)
  end

  def init(client) do
    cmd = System.get_env("TSHARK_CMD")
    port = Port.open({:spawn, cmd}, [:binary, {:line, 1000}])
    detect(port, %{}, :none, client)
  end


  defp detect(port, addresses, prev_second, client) do
    receive do

      {^port, {:data, {:eol, line}}} ->
        case String.rstrip(line) |> String.split("\t") do
          [_, timestamp, mac, dbm] ->
            second = String.split(timestamp, ".") |> List.first
            {float_dbm, _} = Float.parse(dbm)
            if second == prev_second do
              addresses = Map.update(addresses, mac, [float_dbm], &(&1 ++ [float_dbm]))
            else
              unless prev_second == :none, do: send_averages(client, addresses)
              addresses = %{mac => [float_dbm]}
            end
            detect(port, addresses, second, client)

          _ ->
            detect(port, addresses, prev_second, client)
        end

      _ -> Port.close(port)

    end
  end

  defp send_averages(client, addresses)  do

    send client, Enum.map(addresses, fn({mac_address, dbms}) ->
      sum = Enum.reduce(dbms, fn(float_dbm, sum) -> float_dbm + sum end)
      len = length(dbms)
      average_dbm = sum / len
      {mac_address, average_dbm, len}
    end)

  end

end
