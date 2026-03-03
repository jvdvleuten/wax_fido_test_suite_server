defmodule WaxFidoTestSuiteServerWeb.Plugs.Health do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{method: "GET", request_path: "/"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ~s({"status":"ok"}))
    |> halt()
  end

  def call(%Plug.Conn{method: "GET", request_path: "/health"} = conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ~s({"status":"ok"}))
    |> halt()
  end

  def call(conn, _opts), do: conn
end
