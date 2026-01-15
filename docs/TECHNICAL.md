# Technical notes (brief, verified)

## Why GPS matters
Starlink terminals use GNSS/GPS as a source of **position and time**, which is important for "sky search" and scheduling.

## Local interface (no internet required)
The dish exposes a local gRPC interface on:
- `192.168.100.1:9200` (native gRPC; commonly supports reflection)

This kit uses `grpcurl` with JSON input to call:
- `SpaceX.API.Device.Device/Handle`

## GPS inhibit command (newer firmware)
This kit sends:
```json
{"dish_inhibit_gps":{"inhibit_gps":true}}
```

## Persistence
The GPS inhibit setting is commonly **not preserved across dish reboot**, so daemon mode may be required.

## What this kit deliberately does NOT do
- It does not use unverified gRPC-web “binary payload” strings.
- It does not attempt to generate “universal” payloads that might be wrong for your firmware.
