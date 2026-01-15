# Older firmware or restricted schema — what to do

If the “Disable GPS” option fails, it usually means one of these:
1) You are **not** on the dish’s local network (Starlink Wi‑Fi / LAN), or
2) Your firmware does **not** support `dish_inhibit_gps` (older firmware / feature missing), or
3) The problem is **not** GPS/GNSS jamming (for example, Ku/Ka user‑link jamming).

Note: this kit includes an offline gRPC schema (`proto/starlink.protoset`), so it can work even when gRPC reflection is disabled.

## Step 1: Run the Probe (recommended)
- Windows: `START_WINDOWS.bat` → “Probe”
- macOS/Linux: `./scripts/starlink_gps.sh probe`

What Probe can tell you:
- Whether your device can reach `192.168.100.1:9200` on the local network.
- Whether the dish exposes gRPC **reflection** (some firmwares disable it).
- If reflection is available, whether `dish_inhibit_gps` appears in the live schema.

If reflection is disabled, Probe cannot list live fields. In that case, the practical test is simply:
- Try **Disable GPS**
- If it fails, continue with Step 2 and Step 3 below.

## Step 2: Try the official Starlink app setting (if present)
In the official Starlink app (connected to the dish over local Wi‑Fi), look for a toggle named:
- **"Use Starlink positioning exclusively"** (its location can vary by app version)

Public reporting indicates this tells the terminal **not to use GPS**, which can make GPS jamming ineffective. Reported trade-offs:
- Startup/acquisition may take longer.
- It may not work well while moving (vehicle/boat).

Public reference (toggle wording + GNSS/jamming context):
- https://olegkutkov.me/2023/11/07/connecting-external-gps-antenna-to-the-starlink-terminal/

## Step 3: Physical fallback options (firmware-independent)
When you cannot disable GPS via software, you may need a physical mitigation.

### Option A: External GPS antenna modification
Hardware modifications that relocate/extend the GPS antenna path are documented in technical articles.
This does **not** depend on a specific firmware command.

Warnings:
- Requires opening the terminal (warranty risk).
- Requires electronics skills and careful RF work.

One public reference:
- https://olegkutkov.me/2023/11/07/connecting-external-gps-antenna-to-the-starlink-terminal/

### Option B: Get a firmware update (when possible)
If you can restore connectivity long enough (even briefly), allow the dish to update firmware.
Newer firmwares may include more positioning options.

## Step 4: If disabling GPS doesn’t help
If you have disabled GPS/positioning and the connection is still unstable, you may be seeing **Ku/Ka user‑link jamming** instead of GPS jamming. This kit does not address user‑link jamming.

## What not to rely on
- Random “binary payload” strings for port 9201: these are often unverified and can be wrong for your firmware.
