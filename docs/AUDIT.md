# Audit / fact-check notes

This document explains what was checked when building this kit, and what can/can’t be validated without Starlink hardware.

## What was compared
- `starlink-iran-toolkit-verified.zip`: documentation + scripts that assume `grpcurl` is already installed.
- `starlink-iran-toolkit-offline.zip`: offline-focused bundle that includes platform `grpcurl` binaries + click-to-run launchers.

Baseline choice: the offline kit is the better default for non-technical users because it bundles `grpcurl` and provides one-click launchers.

## Key facts

### 1) Local dish address/port
Starlink user terminals expose a local interface at `192.168.100.1`.

### 2) GPS inhibit request exists (and shape is known)
The request field `dish_inhibit_gps` with sub-field `inhibit_gps` exists on supported Starlink firmware.

This is why this kit sends:
`{"dish_inhibit_gps":{"inhibit_gps":true}}`

to:
`192.168.100.1:9200 SpaceX.API.Device.Device/Handle`

## What is deliberately NOT relied on
- “Universal” gRPC‑web binary payload strings for port `9201` that cannot be validated against the live schema; these are commonly reposted without proof and may be firmware-specific or simply wrong.

## What cannot be verified here (no hardware)
- Whether your specific firmware exposes `dish_inhibit_gps` (use the kit’s **Probe** mode).
- Whether disabling GPS fully mitigates your local jamming conditions (depends on jammer type/power/distance, link jamming vs GPS jamming, and antenna environment).
