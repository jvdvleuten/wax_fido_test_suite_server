defmodule WaxFidoTestSuiteServerWeb.UserKeyCallbackImpl do
  @behaviour WaxAPIREST.Callback

  @impl true
  def user_info(conn) do
    %{id: user_handle_id(user_id(conn))}
  end

  @impl true
  def put_challenge(conn, challenge) do
    conn
    |> Plug.Conn.fetch_session()
    |> Plug.Conn.put_session(:wax_api_rest_challenge, challenge)
    |> Plug.Conn.put_session(:user_id, user_id(conn))
  end

  @impl true
  def get_challenge(conn) do
    conn
    |> Plug.Conn.fetch_session()
    |> Plug.Conn.get_session(:wax_api_rest_challenge) || raise "Challenge not found in session"
  end

  @impl true
  def register_key(conn, credential_id, authenticator_data, _attestation_result) do
    true =
      :ets.insert(:wax_fido_test_user_keys, {
        {user_id(conn), credential_id},
        authenticator_data.attested_credential_data.credential_public_key,
        authenticator_data.sign_count
      })

    conn
  end

  @impl true
  def user_keys(conn) do
    :ets.match_object(:wax_fido_test_user_keys, {{user_id(conn), :_}, :_, :_})
    |> Enum.map(fn {{_user_id, credential_id}, cose_key, sign_count} ->
      {credential_id, %{cose_key: cose_key, sign_count: sign_count}}
    end)
  end

  @impl true
  def on_authentication_success(conn, credential_id, authenticator_metadata) do
    :ets.update_element(
      :wax_fido_test_user_keys,
      {user_id(conn), credential_id},
      {3, authenticator_metadata.sign_count}
    )

    conn
  end

  defp user_id(%Plug.Conn{body_params: %{"username" => username}}) do
    username
  end

  defp user_id(conn) do
    conn
    |> Plug.Conn.fetch_session()
    |> Plug.Conn.get_session(:user_id)
  end

  defp user_handle_id(username) when is_binary(username) do
    :crypto.hash(:sha256, username)
    |> Base.url_encode64(padding: false)
  end
end
