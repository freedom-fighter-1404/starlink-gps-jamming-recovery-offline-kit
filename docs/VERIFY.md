# Verifying this offline kit (hashes + integrity)

This kit is meant to be shared offline (USB, AirDrop, local transfer). In high-risk environments, treat every copied file as potentially modified until you verify it.

## 1) Verify the release ZIP hash (recommended)
When you download a release, it should include:
- `…<platform>.zip`
- `…<platform>.zip.sha256`

Compute the ZIP’s SHA‑256 on your device and compare it to the value in the `.sha256` file:

**Windows (PowerShell):**
```powershell
Get-FileHash .\\your-file.zip -Algorithm SHA256
```

**Windows (Command Prompt):**
```bat
certutil -hashfile your-file.zip SHA256
```

**macOS:**
```bash
shasum -a 256 your-file.zip
```

**Linux:**
```bash
sha256sum your-file.zip
```

If the hash does not match, do not run the kit.

## 1b) Verify the release ZIP signature (optional, stronger than hash)
Some releases may also include an **OpenSSH signature** sidecar file:
- `…<platform>.zip.sshsig`

To verify a signature you need:
- the ZIP
- the matching `.sshsig`
- the signer public key material (`release_keys/allowed_signers`)

First, confirm the public key fingerprint out-of-band:
- `release_keys/FINGERPRINT.txt`

Then verify:
```bash
ssh-keygen -Y verify \
  -f release_keys/allowed_signers \
  -I starlink-gps-jamming-recovery-offline-kit \
  -n starlink-gps-jamming-recovery-offline-kit-release \
  -s your-file.zip.sshsig < your-file.zip
```

## 2) Verify the extracted folder (built-in integrity checks)
After extracting the ZIP, verify the folder contents:
- Windows: double‑click `verify_integrity.bat` (or run `verify_integrity.ps1`)
- macOS/Linux: run `./verify_integrity.sh`

If verification prints `OK: Integrity checks passed.`, then:
- The launchers + scripts match `CHECKSUMS.sha256`
- The bundled `grpcurl` binaries match `checksums/BUNDLED_FILES_SHA256.txt`

## Full disclosure: what is (and isn’t) provided
- This project provides **SHA‑256** checksums:
  - `…<platform>.zip.sha256` (release ZIP hash)
  - `CHECKSUMS.sha256` (scripts/docs after extraction)
  - `checksums/BUNDLED_FILES_SHA256.txt` (bundled binaries)
- Some releases may also include **OpenSSH signatures** (`.sshsig`). See above.
- This project does **not** include PGP/GPG signatures at this time.
- Verification is offline and does not contact the internet.

## Bundled component: grpcurl
- Version: `v1.9.3`
- License: `third_party/grpcurl/LICENSE`
- Checksums: `checksums/grpcurl_1.9.3_checksums.txt`
