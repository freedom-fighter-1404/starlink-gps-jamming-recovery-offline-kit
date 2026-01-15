# Audit / fact-check notes

This document explains what was checked when building this kit, and what can/can’t be validated without Starlink hardware.

## Key facts

### 1) Local dish address/port
Starlink user terminals expose a local interface at `192.168.100.1`.

### 2) GPS inhibit request exists (and shape is known)
The request field `dish_inhibit_gps` with sub-field `inhibit_gps` exists on supported Starlink firmware.

This is why this kit sends:
`{"dishInhibitGps":{"inhibitGps":true}}`

to:
`192.168.100.1:9200 SpaceX.API.Device.Device/Handle`

### 3) Reflection is optional (offline schema included)
Some firmware versions disable the gRPC reflection API. This kit includes a minimal schema so it can still call the local API without reflection:
- `proto/starlink_minimal.proto` (human-readable schema)
- `proto/starlink.protoset` (compiled descriptor set used by `grpcurl`)

### 4) Official app toggle exists (when supported)
Some Starlink app versions include a debug setting:
- **"Use Starlink positioning exclusively"**

Public reporting indicates this can instruct the terminal **not to use GPS**, which can make GPS jamming ineffective. Reported trade-offs include longer startup/acquisition time and poorer behavior while moving (vehicle/boat).

### 5) Physical GPS reception improvements are documented publicly
External GPS antenna modifications and other reception improvements have been documented publicly (model-specific) and include test results.

### 6) `inhibitGps` may appear as a spoofing countermeasure (public reporting)
Some public debug telemetry reports show `gpsValid: true` with a normal satellite count while `inhibitGps: true`, and interpret this as the terminal disabling GPS-based positioning due to suspected spoofing.

This is not an official vendor document, and it should not be treated as definitive — but it is consistent with the idea that `inhibitGps` can be set by the terminal as a safety response.

### 7) Firmware age can block recovery (public reporting)
Some public reporting indicates certain firmware versions may be required for a terminal to continue functioning on the network, and that long-stored/paused hardware may require an update before it will connect.

## What is deliberately NOT relied on
- “Universal” gRPC‑web binary payload strings for port `9201` that cannot be validated against the live schema; these are commonly reposted without proof and may be firmware-specific or simply wrong.

## What cannot be verified here (no hardware)
- Whether your specific firmware supports `dish_inhibit_gps` and/or the Starlink app “positioning exclusively” toggle (use the kit’s **Probe** mode and practical testing).
- Whether disabling GPS fully mitigates your local jamming conditions (depends on jammer type/power/distance, link jamming vs GPS jamming, and antenna environment).

## Public references used for fact-checking
- Starlink local IP + gRPC examples: https://github.com/sparky8512/starlink-grpc-tools
- `dish_inhibit_gps` usage in code (pinned commit): https://github.com/sparky8512/starlink-grpc-tools/blob/ca8c1d5b5ee6fad0d8c1c9b146711e084889f03a/dish_control.py
- Field numbers + message/service names (pinned proto sources):
  - https://raw.githubusercontent.com/andywwright/starlink-grpc-client/ad72ecdda352e6af288d7bc1ef4bdc29193c68b4/protos/starlink_protos/spacex/api/device/device.proto
  - https://raw.githubusercontent.com/andywwright/starlink-grpc-client/ad72ecdda352e6af288d7bc1ef4bdc29193c68b4/protos/starlink_protos/spacex/api/device/dish.proto
- Starlink app toggle wording + GNSS/jamming context (article + comments): https://olegkutkov.me/2023/11/07/connecting-external-gps-antenna-to-the-starlink-terminal/
- Secondary summary of the antenna mod work: https://hackaday.com/2024/03/06/gps-antenna-mods-make-starlink-terminal-immune-to-jammers/
- Public debug telemetry report discussing `gpsStats.inhibitGps` in Iran: https://github.com/narimangharib/starlink-iran-gps-spoofing/blob/main/starlink-iran.md
- Public reporting on minimum firmware requirements / mandatory updates: https://www.rvmobileinternet.com/some-starlink-terminals-require-mandatory-software-updates-to-continue-to-function-on-starlinks-network/
