defmodule KV.Store do
  @doc """
  Starts a new store.
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `store` by `key`.
  """
  def get(store, key) do
    Agent.get(store, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `store`.
  """
  def put(store, key, value) do
    Agent.update(store, &Map.put(&1, key, value))
  end
end

