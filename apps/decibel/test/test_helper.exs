ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Decibel.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Decibel.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Decibel.Repo)

