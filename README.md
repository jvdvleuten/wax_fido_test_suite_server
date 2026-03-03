# WaxFidoTestSuiteServer

## Support

OTP25+

## Configuration

Use local-only config overrides so public commits stay clean.

1. Copy the local template:

```bash
cp config/dev.local.exs.example config/dev.local.exs
```

`config/dev.local.exs` is gitignored. Put your personal Cloudflare and MDS values there.

2. For TPM conformance tests, use config (no source edits in `wax` needed):

```elixir
config :wax_, :tpm_allow_conformance_fake_manufacturer, true
```

3. You can also set values with environment variables:

- `WAX_FIDO_ORIGIN`
- `WAX_FIDO_HTTP_PORT`
- `WAX_FIDO_HTTPS_PORT`
- `WAX_FIDO_MDS_ROOT_CERT_PATH`
- `WAX_FIDO_MDS_EXECUTE_ENDPOINTS` (comma/newline separated)
- `WAX_FIDO_MDS_SKIP_EXECUTE_ENDPOINTS` (comma/newline separated)
- `WAX_FIDO_ALLOWED_ORIGINS` (comma/newline separated, defaults to `[WAX_FIDO_ORIGIN, "null"]`)
- `WAX_FIDO_MDS_CONNECT_TIMEOUT_MS`
- `WAX_FIDO_MDS_REQUEST_TIMEOUT_MS`
- `WAX_FIDO_WAX_PATH` (optional local path to a `wax` checkout; defaults to Hex package)

### Downloading the test suite

It is not publicly available. See
[https://fidoalliance.org/certification/functional-certification/conformance/](https://fidoalliance.org/certification/functional-certification/conformance/)
to be granted access.

### Cloudflare + MDS3 setup

Start a quick tunnel to your local HTTPS server:

```bash
cloudflared tunnel --protocol http2 --url https://127.0.0.1:4101 --no-tls-verify
cloudflared tunnel --protocol http2 --url https://127.0.0.1:4001 --no-tls-verify
```

Copy the generated `https://<name>.trycloudflare.com` URL into:

- `config/dev.local.exs` as `config :wax_, :origin, ...`
- `config/dev.local.exs` as `config :wax_fido_test_suite_server, :cors_allowed_origins, [...]`
- FIDO conformance app `Server URL`

For the official tool flow, include `"null"` in `:cors_allowed_origins`.

Then open [https://mds3.fido.tools/](https://mds3.fido.tools/) and:

1. Enter the same server URL.
2. Generate the 5 execute endpoints.
3. Put them into `:mds_execute_endpoints` in `config/dev.local.exs`.
4. Put the revoked-leaf endpoint into `:mds_skip_execute_endpoints`.

Download root cert and save it to the configured path:

```bash
mkdir -p priv/fido2_metadata
curl -fL https://mds3.fido.tools/pki/MDS3ROOT.crt -o priv/fido2_metadata/MDS3ROOT.crt
```

### Starting the test server

```bash
MIX_ENV=dev mix phx.server
```

### Launch tests

In the FIDO app:

1. Open `FIDO2 Tests`.
2. Set `Server URL` to your current Cloudflare tunnel URL.
3. Run `Server tests`.

## Testing from a Linux host

The test suite does not support Linux (support was silently dropped at some point).
One solution consists in installing a Windows VM and use the test suite from it:

### Download a Windows VM

[Windows 10 VM](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines)
(licence lasts 90 days).

### Install the test suite

You might have to disable UAC to run the test suite. Once it's done, a binary
is installed in `C:\Program Files(x86)\FIDO Conformance Tools Installer` whose
name is `F`.

Double click to open it

### Configuring network

The VM should be configured to share IP addresses between VM and hosts OSes.
With VirtualBox, this is the "Bridged networking" option.

This is no sufficient to successfully run the test suite. Indeed, the origin is set by the
test suite in client data according to the value set in the "Server URL" field. This must
be, according to the FIDO2 specification, either an HTTPS URL or `localhost`. Configuring
SSL is possibly impossible, and the VM's localhost is always `127.0.0.1` whereas your test
server has another address, for example `192.168.100.97` (and Windows 10 cannot be tweaked
to
[change what localhost resolves to](https://medium.com/software-developer/change-what-localhost-resolves-to-in-windows-for-testing-ie-edge-on-parallels-or-virtualbox-vm-60a002849d94)).

It is however possible to redirect traffic with the following commands:

```powershell
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=4000 connectaddress=192.168.100.97 connectport=4000

netsh interface portproxy add v6tov4 listenaddress=::1 listenport=4000 connectaddress=192.168.100.97 connectport=4000
```

## Curl test command

```
curl --header "Content-Type: application/json" --request POST --cookie "fido_test_suite=abcdef" --data '{"username":"johndoe@example.com","displayName":"John Doe","authenticatorSelection":{"residentKey":false,"authenticatorAttachment":"cross-platform","userVerification":"preferred"},"attestation":"direct"}' http://localhost:4000/attestation/options | jq
```
