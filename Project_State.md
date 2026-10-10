Portable Ambient Link - Project State

Summary

This device is intended as a visualizer for audio playback for a linked device. While not connected, the device can be configured to show the current time, weather, live updates or other custom views. When connected and playing audio, the device adapts to display the artwork of the currently playing song. It will also include a player UI so the track can be paused or changed from the touchscreen display. The device will also utilize Milkdrop Visualizer to display responsive animations based on the music, and potentially other views can be configured (such as a photo slideshow, koi pond, live wallpaper, (tbd)).



## 1\. System Architecture \& Tech Stack

* **UI Framework:** Flutter (Desktop / Embedded / Android Target)
* **Visualizer Engine:** libprojectM / MilkDrop (C++ native library integrated via Flutter FFI/Textures)
* **Data Sources:** WebSockets / HTTP APIs for weather, audio metadata, ReplayGain/playback state







DEVELOPMENT PHASES



PHASE 1: Pure UI Layout \& Widescreen Adaptation (Work Computer)

Goal: Build and refine all views targeting the 800x480 resolution aspect ratio.



\[ ] Lock window dimensions to 800x480 across test targets.

\[ ] Optimize Standby View layout (Clock faces, Weather widget, Status cards) for widescreen landscape.

\[ ] Build interactive Now Playing / Player UI (Track metadata, cover art, play/pause controls, seek bar scrubbing).

\[ ] Expand Settings \& Subpages (Dual-column layout, view reordering, theme customization, preset selectors).

\[ ] Integrate MockAudioService to stream fake PCM arrays (128-sample buffers) for UI visualizer previewing.







PHASE 2: Data Synchronization \& Simulated Communication Loop (Work Computer)

Goal: Connect UI state layer to network/websocket channels using local unprivileged mocks.



\[ ] Implement MockPlaybackService to handle dynamic song switching, playback states, and progress ticks.

\[ ] Build lib/services/player\_sync\_service.dart using WebSocket (web\_socket\_channel) and HTTP.

\[ ] Create a local Python/Node mock server to emit real-time WebSocket track updates and serve mock cover art via HTTP.

\[ ] Integrate state management (Provider) to dynamically bind UI controls to real-time events.









PHASE 3: Native Engine Integration \& FFI Plumbing (Home Computer)

Goal: Connect C++ libprojectM visualizer engine to Flutter via FFI and Native Textures.



\[ ] Compile libprojectM shared dynamic libraries (.dll for Windows, .so for Linux) using CMake \& VS 2022.

\[ ] Generate Dart FFI bindings using ffigen (lib/visualizer/generated\_bindings.dart).

\[ ] Implement native C++ Texture Entry to pipe libprojectM OpenGL/DirectX frame output directly into Flutter.

\[ ] Pass mock PCM audio streams across FFI boundary into libprojectM to verify frame rendering.











PHASE 4: Hardware Audio Loopback \& Raspberry Pi Deployment (Home Computer \& Pi)

Goal: Replace mock audio with real hardware loopback and deploy to the target 800x480 device.



\[ ] Implement low-level audio loopback capturing live PCM frames:

\- WASAPI for Windows environment.

\- PulseAudio / ALSA for Linux / Raspberry Pi target.

\[ ] Deploy Flutter application to 800x480 touchscreen display (Kiosk Mode).

\[ ] Calibrate touch and swipe gestures (pull-down overlay, view swiping, volume control).

\[ ] Profile rendering performance, reduce FFI memory allocations, and resolve frame drops during complex MilkDrop preset transitions.







WORK

Remove-Item -Recurse -Force .\\build

$env:Path += ";C:\\Program Files\\Git\\cmd;C:\\Users\\michael.emborsky\\Dev\\flutter\\bin"

flutter run -d edge --no-pub



HOME

Remove-Item -Recurse -Force .\\build

flutter run -d windows






Get-ChildItem -Recurse -File | Where-Object { $_.Extension -in '.dart','.yaml','.md' -and $_.FullName -notmatch '[\\/](\.git|build|\.dart_tool|\.idea|\.vscode)[\\/]' } | ForEach-Object { "=== File: $($_.FullName) ==="; Get-Content $_.FullName -Raw } | Out-File project_context.txt -Encoding utf8








ASCII Folder Structure



PAL/

├── android/

├── build/

├── ios/

├── lib/

│   ├── models/

│   │   └── widget\_config.dart

│   ├── services/

│   │   └── mock\_audio\_service.dart

│   ├── ui/

│   │   ├── settings/

│   │   │   ├── active\_listening\_settings\_page.dart

│   │   │   ├── general\_settings\_page.dart

│   │   │   ├── main\_settings\_widget.dart

│   │   │   ├── view\_detail\_page.dart

│   │   │   └── views\_management\_page.dart

│   │   ├── widgets/

│   │   │   ├── active\_listening\_widget.dart

│   │   │   ├── clock\_widget.dart

│   │   │   └── weather\_widget.dart

│   │   └── standby\_view.dart

│   └── main.dart

├── linux/

├── macos/

└── test/

&#x20;   └── widget\_test.dart





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

