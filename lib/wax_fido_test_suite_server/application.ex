defmodule WaxFidoTestSuiteServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    _ = Application.ensure_all_started(:inets)

    _ =
      Task.start(fn ->
        _ = WaxFidoTestSuiteServer.MDSBootstrap.load_entries()
      end)

    children = [
      WaxFidoTestSuiteServerWeb.Endpoint
    ]

    :ets.new(:session, [:named_table, :public])
    :ets.new(:wax_fido_test_user_keys, [:named_table, :set, :public])
    :ets.new(:wax_fido_test_challenges, [:named_table, :set, :public])

    opts = [strategy: :one_for_one, name: WaxFidoTestSuiteServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    WaxFidoTestSuiteServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
