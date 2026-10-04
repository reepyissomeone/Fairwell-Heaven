# Fairwell Heaven

A modular client-side Roblox toolkit with persistent settings, live updates, and game-specific feature modules.

## Loader

Permanent loader:

https://raw.githubusercontent.com/reepyissomeone/Fairwell-Heaven/main/loader.lua

The loader downloads the current main branch and can detect repository updates while running.

## Current DOORS features

- DOORS Core — tracks the player's current room and previous room.
- DOORS Room Tracker — exposes the current room number.
- DOORS Door Tracker — finds the current room's door, including doors that spawn after the room.
- DOORS Highlights — room-scoped highlights for doors, keys, and keycards.
- DOORS Entity Notifications — alerts for common entities when they appear.
- DOORS Room HUD — small live room/door status display.
- Visual FPS Counter — live frame-rate overlay.
- Visual Clock — live local-time overlay.
- Visual Crosshair — optional center-screen crosshair.
- Visual Performance HUD — optional FPS/memory monitor.
- Visual DOORS Item Labels — optional labels for doors, keys, keycards, and levers.
- Visual DOORS Entity Markers — optional floating labels for active entities.
- Main UI — status, development, Fairwell Chat, Visual, and Settings pages.

## Settings

Persistent settings are stored when the runtime provides isfile, readfile, and writefile.

Current settings include:

- Feature enable/disable state.
- Main window position.
- Main window collapsed state.
- Live update-check interval.

## Structure

- loader.lua — bootstrap and live updater.
- core/ — hub, game detection, manifest, and settings.
- features/ — UI and game-specific modules.
- features/doors/ — DOORS-specific functionality.
- features/visual/ — standalone visual overlays and DOORS visual helpers.

## Adding features

Add a module under features/, register its path in core/Manifest.lua, and return a feature table with a Name and optional Start/Stop methods.
