Portable Ambient Link - Project State

Summary

This device is intended as a visualizer for audio playback for a linked device. While not connected, the device can be configured to show the current time, weather, live updates or other custom views. When connected and playing audio, the device adapts to display the artwork of the currently playing song. It will also include a player UI so the track can be paused or changed from the touchscreen display. The device will also utilize Milkdrop Visualizer to display responsive animations based on the music, and potentially other views can be configured (such as a photo slideshow, koi pond, live wallpaper, (tbd)).


## 1. System Architecture & Tech Stack
* **UI Framework:** Flutter (Desktop / Embedded / Android Target)
* **Visualizer Engine:** libprojectM / MilkDrop (C++ native library integrated via Flutter FFI/Textures)
* **Data Sources:** WebSockets / HTTP APIs for weather, audio metadata, ReplayGain/playback state

## 2. Current Architecture & Folder Structure
* `lib/ui/` -> Watch-style circular/square widgets, page transitions
* `lib/visualizer/` -> FFI bridge to libprojectM, preset switcher
* `lib/services/` -> Audio metadata listener, weather service

## 3. Completed Features
* [x] Basic Flutter UI layout with widget grid
* [x] FFI bindings generated for projectM native library

## 4. Current Task / Active Focus
* [ ] Implementing real-time audio FFT/PCM data stream into projectM native texture

## 5. Next Steps / Roadmap
1. Polishing MilkDrop preset transition animations
2. Adding watch-style gesture navigation (swipes/rotations)

## 6. Known Bugs & Tech Debt
* Frame rate drops when switching heavy `.milk` presets