#pragma once

#include "../ImGui/imgui.h"

// Shared runtime state used by the sample menu and feature modules.
// Keep this file free of UIKit/Metal dependencies so non-UI code can consume it.
struct AppState {
    static AppState& Shared() {
        static AppState instance;
        return instance;
    }

    ImVec2 MenuSize = ImVec2(0.0f, 0.0f);
    ImVec2 MenuOrigin = ImVec2(0.0f, 0.0f);

    bool StreamerMode = false;
    bool MoveMenu = false;

    bool ShowEspOverlay = true;
    bool ShowEspSnaplines = true;
    bool ShowEspMarkers = true;
    bool ShowEspBoxes = true;
    bool ShowEspLabels = true;
    bool ShowEspHealthBars = true;

    float CameraFOV = 90.0f;

private:
    AppState() = default;
};

// Compatibility alias for existing feature code.
static AppState& KTempVars = AppState::Shared();
