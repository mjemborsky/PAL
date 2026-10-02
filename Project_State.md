Portable Ambient Link - Project State

Summary

This device is intended as a visualizer for audio playback for a linked device. While not connected, the device can be configured to show the current time, weather, live updates or other custom views. When connected and playing audio, the device adapts to display the artwork of the currently playing song. It will also include a player UI so the track can be paused or changed from the touchscreen display. The device will also utilize Milkdrop Visualizer to display responsive animations based on the music, and potentially other views can be configured (such as a photo slideshow, koi pond, live wallpaper, (tbd)).



## 1\. System Architecture \& Tech Stack

* **UI Framework:** Flutter (Desktop / Embedded / Android Target)
* **Visualizer Engine:** libprojectM / MilkDrop (C++ native library integrated via Flutter FFI/Textures)
* **Data Sources:** WebSockets / HTTP APIs for weather, audio metadata, ReplayGain/playback state



Portable Ambient Link — Software Development Roadmap



Phase 1: Native Engine \& Flutter FFI Plumbing (Week 1)

Goal: Get libprojectM rendering .milk presets inside a Flutter desktop target.
\[ ] Build dynamic native libraries (.dll / .so) for libprojectM using CMake.
\[ ] Configure ffigen and generate Dart FFI bindings (lib/visualizer/generated\_bindings.dart).
\[ ] Connect libprojectM rendering output to Flutter using a native C++ Texture Entry.
\[ ] Create a mock PCM generator to feed fake audio data via FFI and verify visual rendering.





Phase 2: Audio Streaming \& Data Synchronization (Week 2)

Goal: Hook up live system audio loopback and setup real-time metadata syncing.
\[ ] Implement desktop audio loopback (WASAPI/PulseAudio) to feed real 16/32-bit float PCM buffers.
\[ ] Implement WebSocket client in lib/services/ for live audio player state changes.
\[ ] Build HTTP service for track metadata, artwork loading, and ReplayGain values.
\[ ] Build a local Python/Node mock server to emit simulated playback events and art URLs.







Phase 3: Watch UI, Gestures \& Preset Switcher (Week 3)

Goal: Develop app state engine, gesture controls, and preset management.
\[ ] Build State Machine: Standby View (clock/weather) vs. Active View (art/controls/visualizer).
\[ ] Build watch-style UI widgets (lib/ui/) with swipe gestures for preset and page switching.
\[ ] Implement .milk preset manager for manual selection and automated crossfade cycling.







Phase 4: Weather Integration, Optimization \& Prep (Week 4)

Goal: Polish performance, resolve frame drops, and simulate final screen resolution.
\[ ] Integrate Open-Meteo API in weather\_service.dart for standby weather widgets.
\[ ] Profile and resolve frame drops during complex preset transitions; optimize FFI memory allocation.
\[ ] Lock desktop preview to target resolution (e.g., 480x480 circular/square layout) for UI scaling tests.













$env:Path += ";C:\\Program Files\\Git\\cmd;C:\\Users\\michael.emborsky\\Dev\\flutter\\bin"



flutter clean



Remove-Item -Force .flutter-plugins-dependencies

Remove-Item -Force .flutter-plugins

Remove-Item -Recurse -Force .\\build

flutter run -d edge --no-pub







\# PAL Native Environment Setup Guide (Home Desktop)



\## 1. Prerequisites Checklist

\* \[ ] Visual Studio 2022 (with "Desktop development with C++" workload)

\* \[ ] CMake (v3.15+)

\* \[ ] Git

\* \[ ] Flutter SDK



\## 2. Compile libprojectM Shared Library

1\. Open PowerShell or Command Prompt.

2\. Clone libprojectM with submodules:

&#x20;  ```powershell

&#x20;  git clone --recursive \[https://github.com/projectM-visualizer/projectm.git](https://github.com/projectM-visualizer/projectm.git)

&#x20;  cd project



FOR CONTEXT I AM DEVELOPING ON TWO SEPARATE MACHINES



One machine is my work computer. This is where I am using those custom environment paths, as it is managed and I don't always have permissions.



The other machine is my personal computer. This is not managed and I can do whatever with this, but its a desktop at home. 



I play to do a lot of developing on the work one if possible and then more of the testing on the personal computer.

