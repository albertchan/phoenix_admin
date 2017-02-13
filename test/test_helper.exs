ExUnit.start

Code.require_file "./controllers/controller_test_helpers.exs", __DIR__

Ecto.Adapters.SQL.Sandbox.mode(PhoenixAdmin.Repo, :manual)
