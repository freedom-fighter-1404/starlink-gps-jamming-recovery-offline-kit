# Technical notes (brief)

## Why GPS matters
Starlink terminals use GNSS/GPS as a source of **position and time**, which is important for "sky search" and scheduling.

## Local interface (no internet required)
The dish exposes a local gRPC interface on:
- `192.168.100.1:9200` (native gRPC)

This kit uses `grpcurl` with JSON input to call:
- `SpaceX.API.Device.Device/Handle`

## Reflection is optional (offline schema included)
Some firmware versions disable the gRPC reflection API. This kit includes a minimal offline schema so it can still work:
- `proto/starlink.protoset` (built from `proto/starlink_minimal.proto`)

## GPS inhibit command (newer firmware)
This kit sends:
```json
{"dishInhibitGps":{"inhibitGps":true}}
```

## Reading `gpsStats` (jamming vs spoofing indicators)
When you run **Status**, the response may include a `gpsStats` block with fields like:
- `gpsValid` (boolean)
- `gpsSats` (count)
- `noSatsAfterTtff` (boolean)
- `inhibitGps` (boolean)

These can be helpful indicators, but they are **not definitive** on their own.

Common patterns:
- `inhibitGps: true` means GPS use is inhibited. If you used “Disable GPS”, this is expected.
- `gpsValid: false` and `gpsSats: 0` may indicate strong GPS jamming or a poor view of the sky.
- `gpsValid: true` with a normal satellite count but `inhibitGps: true` can happen if you enabled the inhibit setting; some public telemetry reports also suggest the terminal may inhibit GPS automatically during suspected spoofing.

## Persistence
On some firmware versions, this setting may **reset on reboot/updates**. If you see it revert, use daemon mode.

## What this kit deliberately does NOT do
- It does not use unverified gRPC-web “binary payload” strings.
- It does not attempt to generate “universal” payloads that might be wrong for your firmware.
