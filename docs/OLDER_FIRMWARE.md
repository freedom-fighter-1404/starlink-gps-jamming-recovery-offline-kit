# Older firmware (no `dish_inhibit_gps`) — what to do

If the “Disable GPS” option fails, it usually means one of these:
1) Your firmware does not expose `dish_inhibit_gps`, or
2) gRPC reflection is unavailable (so grpcurl can’t discover the schema), or
3) You are not on the dish’s local network.

## Step 1: Run the Probe
- Windows: `START_WINDOWS.bat` → “Probe”
- macOS/Linux: `./scripts/starlink_gps.sh probe`

If the probe output does **not** include `dish_inhibit_gps`, treat this as “older firmware / no software toggle available”.

## Step 2: Try the official Starlink setting (if present)
If your Starlink settings include this toggle (offline, on local Wi‑Fi):
- Settings → Advanced → Debug Data
- Enable: **"Use Starlink positioning exclusively"**

## Step 3: Physical fallback options (firmware-independent)
When you cannot disable GPS via software, you may need a physical mitigation.

### Option A: External GPS antenna modification
Hardware modifications that relocate/extend the GPS antenna path are documented in technical articles.
This does **not** depend on a specific firmware command.

Warnings:
- Requires opening the terminal (warranty risk).
- Requires electronics skills and careful RF work.

### Option B: Get a firmware update (when possible)
If you can restore connectivity long enough (even briefly), allow the dish to update firmware.
Newer firmwares may include more positioning options.

## What not to rely on
- Random “binary payload” strings for port 9201: these are often unverified and can be wrong for your firmware.
