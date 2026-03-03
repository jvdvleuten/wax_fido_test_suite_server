defmodule WaxFidoTestSuiteServerWeb.Plugs.CORS do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    origin = List.first(get_req_header(conn, "origin"))

    allowed_origins =
      Application.get_env(:wax_fido_test_suite_server, :cors_allowed_origins, [])
      |> Enum.map(&to_string/1)

    cors_headers = [
      {"access-control-allow-methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS"},
      {"access-control-allow-headers", "content-type,authorization,x-requested-with"},
      {"access-control-expose-headers", "content-type,set-cookie"}
    ]

    case {origin, origin_allowed?(origin, allowed_origins), conn.method} do
      {origin, true, "OPTIONS"} ->
        conn
        |> put_resp_header("access-control-allow-origin", origin)
        |> put_resp_header("vary", "origin")
        |> put_resp_header("access-control-allow-credentials", "true")
        |> put_resp_headers(cors_headers)
        |> send_resp(204, "")
        |> halt()

      {origin, true, _} ->
        conn
        |> put_resp_header("access-control-allow-origin", origin)
        |> put_resp_header("vary", "origin")
        |> put_resp_header("access-control-allow-credentials", "true")
        |> put_resp_headers(cors_headers)

      {_origin, false, "OPTIONS"} ->
        conn
        |> send_resp(403, "")
        |> halt()

      _ ->
        conn
    end
  end

  defp put_resp_headers(conn, headers) do
    Enum.reduce(headers, conn, fn {key, value}, acc ->
      put_resp_header(acc, key, value)
    end)
  end

  defp origin_allowed?(nil, _allowed_origins), do: false
  defp origin_allowed?(_origin, []), do: false
  defp origin_allowed?(origin, allowed_origins), do: origin in allowed_origins
end
