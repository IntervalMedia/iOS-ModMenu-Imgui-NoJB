# AI Agent Instructions

## Purpose
This repository is an iOS Theos-based tweak template for a jailed (non-jailbroken) mod menu with a Dear ImGui + Metal UI layer. Keep new work modular so the template remains useful as a starting point for future projects.

## Theos build system notes
- **Build tooling**: The project is built as a Theos tweak using the root `Makefile` with `TWEAK_NAME = KTemp` and arm64 targeting.
- **Source inclusion**: Objective-C/Objective-C++ sources under `MenuLoad/` and `Source/` are included by the existing wildcard rules. ImGui sources live under `ImGui/`.
- **Typical commands**: `make`, `make package`, and `make install`.

## Runtime flow
1. `TweakManager` is the single tweak bootstrap point. Its `+load` preserves the template's short delayed startup and calls `start` once.
2. `TweakManager` initializes non-UI feature logic (`BasicCheats.Initialize()`) and starts `MenuLoad`.
3. `MenuLoad` owns UIKit composition: active-window discovery, the secure capture host used by streamer mode, the floating launcher, and the touch-routing view.
4. `ImGuiDrawView` owns the `MTKView`, Metal device/queue, and one concise per-frame render loop.
5. `ImGuiController` owns the Dear ImGui lifecycle: context/font/backend initialization, `NewFrame`, render submission, touch-to-ImGui input translation, and shutdown.
6. `UserMenu` contains only ImGui drawing. `Draw(bool menuVisible)` draws the interactive menu when visible and the non-interactive overlay every frame.
7. `AppState` contains shared runtime values. `KTempVars` remains as a compatibility alias so existing feature code can migrate incrementally.

## Design boundaries
- **TweakManager**: startup/coordinator only. Do not put rendering, hooks, or feature implementation here.
- **MenuLoad**: UIKit overlay/controller only. Keep host-app window handling, launcher behavior, touch routing, and streamer-mode presentation here.
- **ImGuiDrawView**: Metal frame orchestration only. A frame should read as: acquire pass -> begin ImGui frame -> draw menu -> render -> present.
- **ImGuiController**: all Dear ImGui lifecycle/backend/input details.
- **UserMenu**: ImGui controls and draw-list code only. Avoid memory writes or gameplay logic inside widgets.
- **AppState**: lightweight shared state with no UIKit or Metal dependencies.
- **Source/**: feature/game logic. UI should bind to state rather than performing memory edits directly.
- **utils/**: low-level reusable helpers such as `KPatch.hpp`.

## Dependency guidance
Prefer explicit includes. `Includes.h` exists only as a compatibility header for older feature modules and should stay small. Do not turn it back into an umbrella header importing Metal, ImGui internals, menu controllers, and unrelated STL headers.

Features should depend on state, not ImGui. For example, an ImGui checkbox should update an `AppState` field, while a feature module reads that field and performs its own work.

## Input and overlays
- `MenuInteraction` forwards touches only when they fall inside the current ImGui menu bounds, allowing the host app to receive touches elsewhere.
- The floating launcher uses one transparent input surface plus one visual mirror inside the capture host. Keep this separation because the visual layer may be hosted inside the secure text-field hierarchy for streamer mode.
- Rendering-only overlays should use ImGui draw lists directly; do not create invisible full-screen ImGui windows unless input/layout behavior genuinely requires one.

## Extension points
- Add new menu controls in `UserMenu` and store their state in `AppState` or a dedicated feature state object.
- Add feature implementations under `Source/` rather than expanding `UserMenu`.
- If feature count grows, split `AppState` into smaller domain-specific state objects instead of adding unrelated globals.
- Prefer dedicated hook/feature modules over placing hooks in the renderer or menu controller.
