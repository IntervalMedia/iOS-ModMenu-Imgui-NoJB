#include "UserMenu.h"
#include "AppState.h"

#import "MenuLoad.h"

#include "../ImGui/imgui.h"

#include <cmath>
#include <cstdio>

namespace {
constexpr float kMenuWindowWidth = 275.0f;
constexpr float kMenuWindowHeight = 250.0f;
constexpr ImU32 kHealthBarBackgroundColor = IM_COL32(18, 24, 30, 180);
constexpr float kMaxColorValue = 255.0f;
constexpr int kHealthBarFillBlue = 90;
constexpr int kHealthBarFillAlpha = 230;
constexpr float kOverlayHeaderX = 18.0f;
constexpr float kOverlayHeaderY = 18.0f;
constexpr float kOverlaySubheaderY = 38.0f;
constexpr float kOverlayStatusRightInset = 210.0f;
constexpr float kSnaplineThickness = 1.8f;
constexpr float kMarkerInnerRadius = 4.0f;
constexpr float kMarkerOuterBaseRadius = 9.0f;
constexpr float kMarkerPulseAmplitude = 1.5f;
constexpr int kMarkerSegments = 24;
constexpr float kMarkerOutlineThickness = 1.2f;

struct MockEspEntity {
    const char *name;
    float phaseOffset;
    float orbitScaleX;
    float orbitScaleY;
    float heightScale;
    float widthScale;
    ImU32 color;
    float healthOffset;
};

struct MockEspState {
    ImVec2 head;
    ImVec2 boxMin;
    ImVec2 boxMax;
    float boxHeight;
    float healthRatio;
    float distanceMeters;
    float markerOuterRadius;
};

void DrawHealthBar(ImDrawList *drawList, const ImVec2& topLeft, float height, float healthRatio) {
    constexpr float barWidth = 6.0f;
    constexpr float barPadding = 8.0f;

    ImVec2 barMin(topLeft.x - barPadding - barWidth, topLeft.y);
    ImVec2 barMax(barMin.x + barWidth, topLeft.y + height);
    drawList->AddRectFilled(barMin, barMax, kHealthBarBackgroundColor, 3.0f);

    const float clampedHealth = fminf(fmaxf(healthRatio, 0.0f), 1.0f);
    const float filledTop = barMax.y - (height * clampedHealth);
    const ImVec2 fillMin(barMin.x + 1.0f, filledTop);
    const ImVec2 fillMax(barMax.x - 1.0f, barMax.y - 1.0f);
    const ImU32 fillColor = IM_COL32(
        (int)((1.0f - clampedHealth) * kMaxColorValue),
        (int)(clampedHealth * kMaxColorValue),
        kHealthBarFillBlue,
        kHealthBarFillAlpha
    );

    drawList->AddRectFilled(fillMin, fillMax, fillColor, 2.0f);
    drawList->AddRect(barMin, barMax, IM_COL32(255, 255, 255, 80), 3.0f, 0, 1.0f);
}

void DrawOverlayStatus(ImDrawList *drawList, const ImVec2& displaySize, int trackedCount) {
    char trackedLabel[40];
    snprintf(trackedLabel, sizeof(trackedLabel), "%d MOCK TARGETS TRACKED", trackedCount);

    drawList->AddText(ImVec2(kOverlayHeaderX, kOverlayHeaderY),
                      IM_COL32(255, 255, 255, 235), "ESP OVERLAY");
    drawList->AddText(ImVec2(kOverlayHeaderX, kOverlaySubheaderY),
                      IM_COL32(120, 255, 180, 225), trackedLabel);
    drawList->AddText(ImVec2(displaySize.x - kOverlayStatusRightInset, kOverlayHeaderY),
                      IM_COL32(255, 210, 120, 225), "DEMO SIGNAL: STABLE");
}

void DrawEspEntity(ImDrawList *drawList,
                   const ImVec2& snaplineOrigin,
                   const MockEspEntity& entity,
                   const MockEspState& state) {
    if (KTempVars.ShowEspSnaplines) {
        drawList->AddLine(snaplineOrigin,
                          ImVec2(state.head.x, state.boxMax.y),
                          entity.color,
                          kSnaplineThickness);
    }

    if (KTempVars.ShowEspMarkers) {
        drawList->AddCircleFilled(state.head, kMarkerInnerRadius, entity.color);
        drawList->AddCircle(state.head,
                            state.markerOuterRadius,
                            entity.color,
                            kMarkerSegments,
                            kMarkerOutlineThickness);
    }

    if (KTempVars.ShowEspBoxes) {
        drawList->AddRect(state.boxMin, state.boxMax, entity.color, 5.0f, 0, 2.0f);
        drawList->AddRect(ImVec2(state.boxMin.x - 2.0f, state.boxMin.y - 2.0f),
                          ImVec2(state.boxMax.x + 2.0f, state.boxMax.y + 2.0f),
                          IM_COL32(255, 255, 255, 45),
                          6.0f,
                          0,
                          1.0f);
    }

    if (KTempVars.ShowEspHealthBars) {
        DrawHealthBar(drawList, state.boxMin, state.boxHeight, state.healthRatio);
    }

    if (KTempVars.ShowEspLabels) {
        char infoLabel[96];
        snprintf(infoLabel, sizeof(infoLabel), "%s  %.0fm", entity.name, state.distanceMeters);
        drawList->AddText(ImVec2(state.boxMin.x, state.boxMin.y - 18.0f),
                          IM_COL32(255, 255, 255, 235), infoLabel);

        char healthLabel[48];
        snprintf(healthLabel, sizeof(healthLabel), "HP %d%%", (int)(state.healthRatio * 100.0f));
        drawList->AddText(ImVec2(state.boxMin.x, state.boxMax.y + 8.0f),
                          IM_COL32(190, 255, 200, 225), healthLabel);
    }
}
} // namespace

void UserMenu::Draw(bool menuVisible) {
    if (menuVisible) {
        DrawMainMenu();
    }

    DrawOverlay();
}

void UserMenu::DrawMainMenu() {
    const ImVec2 displaySize = ImGui::GetIO().DisplaySize;
    const ImVec2 windowSize(kMenuWindowWidth, kMenuWindowHeight);
    const ImVec2 windowPosition(
        (displaySize.x - windowSize.x) * 0.5f,
        (displaySize.y - windowSize.y) * 0.5f
    );

    ImGui::SetNextWindowSize(windowSize, ImGuiCond_Once);
    ImGui::SetNextWindowPos(windowPosition, ImGuiCond_Once);

    ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse;
    if (!KTempVars.MoveMenu) {
        flags |= ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
    }

    if (ImGui::Begin("KomaruTemp", nullptr, flags)) {
        KTempVars.MenuSize = ImGui::GetWindowSize();
        KTempVars.MenuOrigin = ImGui::GetWindowPos();

        ImGui::SliderFloat("FOV Changer", &KTempVars.CameraFOV, 60.0f, 160.0f);

        ImGui::Checkbox("Move Menu", &KTempVars.MoveMenu);
        ImGui::SameLine();

        if (ImGui::Checkbox("Streamer Mode", &KTempVars.StreamerMode)) {
            [MenuLoad applyStreamerMode:KTempVars.StreamerMode];
        }

        ImGui::Separator();
        ImGui::TextUnformatted("ESP Overlay");
        ImGui::Checkbox("Enable Overlay", &KTempVars.ShowEspOverlay);
        ImGui::Checkbox("Snaplines", &KTempVars.ShowEspSnaplines);
        ImGui::SameLine();
        ImGui::Checkbox("Markers", &KTempVars.ShowEspMarkers);
        ImGui::Checkbox("Boxes", &KTempVars.ShowEspBoxes);
        ImGui::SameLine();
        ImGui::Checkbox("Labels", &KTempVars.ShowEspLabels);
        ImGui::Checkbox("Health Bars", &KTempVars.ShowEspHealthBars);
    }

    ImGui::End();
}

void UserMenu::DrawOverlay() {
    if (!KTempVars.ShowEspOverlay) return;

    ImDrawList *drawList = ImGui::GetBackgroundDrawList();
    const ImVec2 displaySize = ImGui::GetIO().DisplaySize;
    const ImVec2 snaplineOrigin(displaySize.x * 0.5f, displaySize.y * 0.15f);
    const float time = (float)ImGui::GetTime();

    const MockEspEntity entities[] = {
        { "SCOUT-01", 0.0f, 0.27f, 0.18f, 122.0f, 0.42f, IM_COL32(90, 220, 255, 255), 0.15f },
        { "HEAVY-02", 1.8f, 0.18f, 0.25f, 148.0f, 0.46f, IM_COL32(255, 110, 110, 255), 0.45f },
        { "DRONE-03", 3.5f, 0.31f, 0.13f, 96.0f, 0.55f, IM_COL32(255, 215, 90, 255), 0.72f },
    };

    DrawOverlayStatus(drawList, displaySize, IM_ARRAYSIZE(entities));

    for (const MockEspEntity& entity : entities) {
        const float oscillation = time + entity.phaseOffset;
        const float normalizedX = 0.5f + cosf(oscillation * 0.8f) * entity.orbitScaleX;
        const float normalizedY = 0.52f + sinf(oscillation * 1.15f) * entity.orbitScaleY;
        const ImVec2 head(displaySize.x * normalizedX, displaySize.y * normalizedY);

        const float boxHeight = entity.heightScale + sinf(oscillation * 1.6f) * 8.0f;
        const float boxWidth = boxHeight * entity.widthScale;
        const ImVec2 boxMin(head.x - boxWidth * 0.5f, head.y - boxHeight * 0.3f);
        const ImVec2 boxMax(head.x + boxWidth * 0.5f, boxMin.y + boxHeight);

        const MockEspState state = {
            head,
            boxMin,
            boxMax,
            boxHeight,
            0.35f + fabsf(sinf(time * 0.75f + entity.healthOffset)) * 0.6f,
            18.0f + fabsf(cosf(time * 0.55f + entity.phaseOffset)) * 42.0f,
            kMarkerOuterBaseRadius + sinf(oscillation * 2.0f) * kMarkerPulseAmplitude,
        };

        DrawEspEntity(drawList, snaplineOrigin, entity, state);
    }
}

void UserMenu::DrawMenu() {
    DrawMainMenu();
}

void UserMenu::RenderingMenu() {
    DrawOverlay();
}

void UserMenu::Initialize() {
    Draw(true);
}
