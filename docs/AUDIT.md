# Audit / fact-check notes

This document explains what was checked when building this kit, and what can/can’t be validated without Starlink hardware.

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

## Public references used for fact-checking
- Starlink local IP + example gRPC call: https://github.com/sparky8512/starlink-grpc-tools
- `dish_inhibit_gps` request usage in code: https://github.com/sparky8512/starlink-grpc-tools/blob/ca8c1d5b5ee6fad0d8c1c9b146711e084889f03a/dish_control.py
- Starlink app toggle wording + GNSS context: https://olegkutkov.me/2023/11/07/connecting-external-gps-antenna-to-the-starlink-terminal/
