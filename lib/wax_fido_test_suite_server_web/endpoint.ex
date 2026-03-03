defmodule WaxFidoTestSuiteServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :wax_fido_test_suite_server

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :wax_fido_test_suite_server,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug WaxFidoTestSuiteServerWeb.Plugs.CORS
  plug WaxFidoTestSuiteServerWeb.Plugs.Health

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_wax_fido_test_suite_server_key",
    signing_salt: "roSevdgr"

  plug WaxFidoTestSuiteServerWeb.Router
end
