# AquaOracle: mobile app

[![Analyze](https://github.com/Vuduykhang2306/aquaoracle-app/actions/workflows/analyze.yml/badge.svg)](https://github.com/Vuduykhang2306/aquaoracle-app/actions/workflows/analyze.yml)

The Flutter app of AquaOracle, a system that watches the water in aquaculture
ponds and tries to predict where it is heading. The app reads sensor data from
Supabase, draws live charts, warns when a value leaves the safe range, and asks
Gemini to explain the forecast in plain words for the farmer.

It was our entry to the 2026 Vietnam Youth Innovation Contest. It won first
prize in Cluster 4 and went to the national final.

The firmware on the device is in
[Esp32_AquaOracle_Programm](https://github.com/Vuduykhang2306/Esp32_AquaOracle_Programm).

## Architecture

```
ESP32 + 4 sensors  --HTTPS/JSON every 2 min-->  Supabase (PostgreSQL, RLS on)
                                                   |
                                      API layer on Vercel (PatchTST)
                                                   |
                                         Flutter app  -->  Gemini
```

Measured: temperature (DS18B20), pH (Analog pH Meter Kit V2), TDS, turbidity.

## Screens

Intro, pond setup, live readings, overall assessment, history charts, forecast,
measurement log, and a chatbot for advice.

## Running it

There are no keys in the source. They are passed in at build time:

```bash
cp dart_define.example.json dart_define.json   # then fill in real values
flutter pub get
flutter run --dart-define-from-file=dart_define.json
```

`dart_define.json` is in `.gitignore`. Don't commit it.

## Security note

Earlier versions of this repo had the Supabase URL, the anon key and a Gemini
API key hardcoded in `lib/config/app_config.dart`. I rewrote the git history
with `git filter-repo` to take them out, and every old key has been revoked.
Config now comes from `--dart-define`.

It's the same kind of mistake I go looking for in other people's smart
contracts, so my own code gets the same check.

## Status

The contest is over. The Supabase project behind the demo has been deleted, so
running it again needs a new backend. The code stays up for reference.

Tiếng Việt: [README.vi.md](README.vi.md)
