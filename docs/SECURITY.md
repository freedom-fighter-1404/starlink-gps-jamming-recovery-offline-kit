# Security notes (high-risk environments)

This kit is designed to be shared offline (USB, AirDrop, local file transfer). In high-risk environments, assume that a toolkit file **can be tampered with** while being distributed.

## What to verify

### 1) Verify the extracted folder (recommended)
From the kit folder:
- Windows: run `verify_integrity.bat` (or `verify_integrity.ps1`)
- macOS/Linux: run `./verify_integrity.sh`

### 2) Visual “sanity checks” (quick)
For the user-facing scripts (`START_*` and `scripts/starlink_gps.sh`), confirm:
- **Dish IP:** `192.168.100.1`
- **Port:** `9200`
- **Method:** `SpaceX.API.Device.Device/Handle`
- **Request:** `dish_inhibit_gps`

If you see other IPs/domains, or anything that looks like telemetry/exfiltration, **do not run the kit**.

## Threat model (practical)
This verification helps detect:
- Files modified to connect to non-local servers
- Malicious tracking/telemetry additions
- Broken scripts distributed to waste time

This verification does **not** protect against:
- A compromised computer/phone (malware)
- Physical device compromise
- A compromised `grpcurl` binary from an untrusted build (verify bundled binaries as described in `docs/VERIFY.md`)

## If you redistribute this kit
- Share the official release URL and the release ZIP SHA‑256 via **at least two independent channels**.
- If you use signatures, also share/confirm the public key fingerprint (`release_keys/FINGERPRINT.txt`) via independent channels.
- Encourage users to verify the ZIP hash first, then run the built-in integrity checks before use.
