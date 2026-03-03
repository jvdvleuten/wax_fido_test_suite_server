defmodule WaxFidoTestSuiteServerWeb.Plugs.CORSTest do
  use WaxFidoTestSuiteServerWeb.ConnCase, async: true

  test "allows configured origin on preflight request", %{conn: conn} do
    conn =
      conn
      |> put_req_header("origin", "https://allowed.example")
      |> options("/attestation/options")

    assert conn.status == 204
    assert get_resp_header(conn, "access-control-allow-origin") == ["https://allowed.example"]
    assert get_resp_header(conn, "access-control-allow-credentials") == ["true"]
  end

  test "rejects unknown origin on preflight request", %{conn: conn} do
    conn =
      conn
      |> put_req_header("origin", "https://evil.example")
      |> options("/attestation/options")

    assert conn.status == 403
    assert get_resp_header(conn, "access-control-allow-origin") == []
  end

  test "includes CORS headers for allowed simple request", %{conn: conn} do
    conn =
      conn
      |> put_req_header("origin", "https://allowed.example")
      |> get("/health")

    assert conn.status == 200
    assert get_resp_header(conn, "access-control-allow-origin") == ["https://allowed.example"]
  end
end
