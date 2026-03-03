defmodule WaxFidoTestSuiteServer.MDSBootstrap do
  @moduledoc false

  require Logger

  @mdsv3_key {Wax.Metadata, :mdsv3}
  @default_mds_connect_timeout 2_000
  @default_mds_request_timeout 5_000

  def load_entries do
    endpoints = Application.get_env(:wax_fido_test_suite_server, :mds_execute_endpoints, [])

    skipped_endpoints =
      Application.get_env(:wax_fido_test_suite_server, :mds_skip_execute_endpoints, [])

    root_cert_path = Application.get_env(:wax_fido_test_suite_server, :mds_root_cert_path)

    with true <- is_binary(root_cert_path),
         {:ok, root_cert_der} <- load_root_cert(root_cert_path) do
      entries =
        endpoints
        |> Enum.reject(&(&1 in skipped_endpoints))
        |> Enum.flat_map(&load_entries_from_endpoint(&1, root_cert_der))
        |> dedupe_entries()

      if entries != [] do
        :persistent_term.put(@mdsv3_key, entries)
        Logger.info("Loaded #{length(entries)} MDSv3 entries from configured execute endpoints")
      end

      :ok
    else
      _ ->
        :ok
    end
  end

  defp load_root_cert(path) do
    case File.read(path) do
      {:ok, pem} ->
        cert_der =
          pem
          |> X509.Certificate.from_pem!()
          |> X509.Certificate.to_der()

        {:ok, cert_der}

      {:error, reason} ->
        Logger.warning("Unable to read MDS root cert at #{path}: #{inspect(reason)}")
        {:error, reason}
    end
  rescue
    e ->
      Logger.warning("Unable to parse MDS root cert at #{path}: #{Exception.message(e)}")
      {:error, :invalid_cert}
  end

  defp load_entries_from_endpoint(url, root_cert_der) do
    connect_timeout =
      Application.get_env(
        :wax_fido_test_suite_server,
        :mds_connect_timeout_ms,
        @default_mds_connect_timeout
      )

    request_timeout =
      Application.get_env(
        :wax_fido_test_suite_server,
        :mds_request_timeout_ms,
        @default_mds_request_timeout
      )

    http_opts = [connect_timeout: connect_timeout, timeout: request_timeout]
    request_opts = [body_format: :binary]

    case :httpc.request(:get, {to_charlist(url), []}, http_opts, request_opts) do
      {:ok, {{_http_vsn, 200, _status}, _headers, body}} ->
        body
        |> Wax.Utils.JWS.verify_with_x5c(root_cert_der)
        |> case do
          {:ok, %{"entries" => entries}} when is_list(entries) ->
            entries

          {:ok, _} ->
            []

          {:error, reason} ->
            Logger.warning("MDS execute endpoint #{url} failed validation: #{inspect(reason)}")
            []
        end

      {:ok, {{_http_vsn, status, _status_text}, _headers, _body}} ->
        Logger.warning("MDS execute endpoint #{url} returned HTTP #{status}")
        []

      {:error, reason} ->
        Logger.warning("MDS execute endpoint #{url} request error: #{inspect(reason)}")
        []
    end
  end

  defp dedupe_entries(entries) do
    entries
    |> Enum.uniq_by(fn entry ->
      {entry["aaguid"], entry["aaid"], entry["attestationCertificateKeyIdentifiers"]}
    end)
  end
end
