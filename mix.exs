defmodule WaxFidoTestSuiteServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :wax_fido_test_suite_server,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WaxFidoTestSuiteServer.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    wax_dep =
      case System.get_env("WAX_FIDO_WAX_PATH") do
        nil -> {:wax_, ">= 0.6.0 and < 1.0.0", override: true}
        path -> {:wax_, path: path, override: true}
      end

    [
      {:phoenix, "~> 1.6.2"},
      {:phoenix_pubsub, "~> 2.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug, "~> 1.18", override: true},
      {:plug_cowboy, "~> 2.7", override: true},
      {:cowboy, "~> 2.13", override: true},
      {:cowlib, "~> 2.15", override: true},
      {:ranch, "~> 2.2", override: true},
      {:wax_api_rest, "~> 0.4.0"},
      wax_dep,
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end
end
