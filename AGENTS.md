# AI Agent Instructions

## Purpose
This repository is an iOS Theos-based tweak template for a jailed (non-jailbroken) mod menu with an ImGui UI layer. Use the notes below when making changes or answering questions.

## Theos build system notes
- **Build tooling**: The project is built as a Theos tweak using the `Makefile` in the repo root. It defines `TWEAK_NAME = KTemp` and builds arm64 for `iphone:clang:latest:latest`.
- **Source inclusion**: The tweak pulls Objective-C/Objective-C++ sources from `MenuLoad/`, `Source/`, and ImGui sources under `ImGui/` via wildcard globs in the Makefile.
- **Typical commands** (from Theos conventions): `make`, `make package`, and `make install` are the usual entry points. Ensure the Theos toolchain is installed as described in the README.

## Entry points / runtime flow
- **Initial load**: `MenuLoad` uses `+load` to initialize the UI after a delay (via a timer) and inserts the ImGui view and menu button into the app window hierarchy.
- **ImGui bootstrap**: `ImGuiDrawView` initializes the Metal device, ImGui context, and font in `-initWithNibName:bundle:`. It calls `BasicCheats.Initialize()` to start the gameplay loop/hack thread once the view is created.
- **Render loop**: `ImGuiDrawView` implements `MTKViewDelegate` and draws ImGui every frame in `-drawInMTKView:`. Menu visibility is gated by `MenDeal` and toggled from the floating button.
- **Hack loop**: `BasicHacks::Initialize()` starts a GCD timer that repeatedly calls `BasicHacks::HacksThread()` at ~30 FPS to apply memory edits (e.g., FOV changes).

## Codebase system design
- **UI layer**: `MenuLoad/` owns UI composition (floating button + ImGui view) and touch routing for the menu interaction layer.
- **Menu content**: `UserMenu` defines ImGui windows and menu state binding to `KTempVars` values (e.g., FOV, streamer mode).
- **Gameplay logic**: `Source/BasicHacks.mm` contains the example “hack” loop and offsets for an Unreal Engine-based title. It uses `KomaruPatch` for memory reads/writes.
- **Memory utilities**: `utils/KPatch.hpp` implements guarded read/write helpers using `mach_vm_region` and `vm_read_overwrite` for safety on jailed devices.
- **ImGui integration**: Core ImGui sources live in `ImGui/`, with the Metal backend invoked from the ImGui draw view.

## Notable TODOs / next features (expected follow-up work)
- **Offset maintenance**: Update the Unreal Engine offsets in `Source/BasicHacks.mm` per target game version and platform updates. This requires per-title reverse engineering and validation in runtime tests.
- **Feature wiring**: Add additional menu toggles and tie them to new memory edits in `BasicHacks` or new modules. This requires new `KTempVars` fields and corresponding ImGui controls in `UserMenu`.
- **UI polish**: Improve the floating menu button UX (snap-to-edge, persistence, or scaling). This requires UI state handling in `MenuLoad`.
- **Rendering overlay**: Fill out the rendering-only overlay in `UserMenu::RenderingMenu()` for ESP or debug visuals, which requires new ImGui draw calls and access to game state.
