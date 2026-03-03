use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wax_fido_test_suite_server, WaxFidoTestSuiteServerWeb.Endpoint,
  http: [port: 4002],
  server: false

config :wax_fido_test_suite_server, :cors_allowed_origins, ["https://allowed.example", "null"]

# Print only warnings and errors during test
config :logger, level: :warn
