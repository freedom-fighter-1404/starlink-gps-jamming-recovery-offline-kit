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

## Persistence
On some firmware versions, this setting may **reset on reboot/updates**. If you see it revert, use daemon mode.

## What this kit deliberately does NOT do
- It does not use unverified gRPC-web “binary payload” strings.
- It does not attempt to generate “universal” payloads that might be wrong for your firmware.
