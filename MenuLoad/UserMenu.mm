/*
IOS Theos Template Komaru
Jailed (NoJB) Mod Menu Template for iOS Games
By aq9
https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB
*/


#include "UserMenu.h"
#include "Includes.h"

namespace {
struct MockEspEntity {
    const char* Name;
    float PhaseOffset;
    float OrbitScaleX;
    float OrbitScaleY;
    float HeightScale;
    float WidthScale;
    ImU32 Color;
    float HealthOffset;
};

void DrawHealthBar(ImDrawList* drawList, const ImVec2& topLeft, float height, float healthRatio) {
    const float barWidth = 6.0f;
    const float barPadding = 8.0f;
    ImVec2 barMin = ImVec2(topLeft.x - barPadding - barWidth, topLeft.y);
    ImVec2 barMax = ImVec2(barMin.x + barWidth, topLeft.y + height);
    drawList->AddRectFilled(barMin, barMax, IM_COL32(18, 24, 30, 180), 3.0f);

    float clampedHealth = fminf(fmaxf(healthRatio, 0.0f), 1.0f);
    float filledTop = barMax.y - (height * clampedHealth);
    ImVec2 fillMin = ImVec2(barMin.x + 1.0f, filledTop);
    ImVec2 fillMax = ImVec2(barMax.x - 1.0f, barMax.y - 1.0f);
    ImU32 fillColor = IM_COL32((int)((1.0f - clampedHealth) * 255.0f), (int)(clampedHealth * 230.0f), 90, 230);
    drawList->AddRectFilled(fillMin, fillMax, fillColor, 2.0f);
    drawList->AddRect(barMin, barMax, IM_COL32(255, 255, 255, 80), 3.0f, 0, 1.0f);
}
}

void UserMenu::DrawMenu()
{


    //ImVec2 menuPos = ImGui::GetWindowPos();
	//ImVec2 windowsize = ImGui::GetWindowSize();

    ImVec2 WindowSize = ImVec2(275, 200);
    ImGui::SetNextWindowSize(WindowSize, ImGuiCond_Once);

    ImVec2 WindowPosition = ImVec2((SCREEN_WIDTH - WindowSize.x) / 2, (SCREEN_HEIGHT - WindowSize.y) / 2);
    ImGui::SetNextWindowPos(WindowPosition, ImGuiCond_Once);

    ImGuiWindowFlags WindowFlags = KTempVars.MoveMenu ? ImGuiWindowFlags_NoCollapse : ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;

    if (ImGui::Begin("KomaruTemp", NULL, WindowFlags))
    {
        ImGuiWindow* CurrentWindow = ImGui::GetCurrentWindow();
        KTempVars.MenuSize   = CurrentWindow->Size;
        KTempVars.MenuOrigin = CurrentWindow->Pos;

        ImGui::SliderFloat("FOV Changer", &KTempVars.CameraFOV, 60.0f, 160.0f);

        //misc menu options
        ImGui::Checkbox("Move Menu", &KTempVars.MoveMenu);
        ImGui::SameLine();
        ImGui::Checkbox("Streamer Mode", &KTempVars.StreamerMode);

    }
    ImGui::End();
}


void UserMenu::RenderingMenu()
{
    ImGui::SetNextWindowPos(ImVec2(0.0f, 0.0f), ImGuiCond_Always);
    ImGui::SetNextWindowSize(ImVec2(SCREEN_WIDTH, SCREEN_HEIGHT), ImGuiCond_Always);
    ImGui::Begin("RenderMenu", nullptr,
        ImGuiWindowFlags_NoTitleBar |
        ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoBackground |
        ImGuiWindowFlags_NoScrollbar |
        ImGuiWindowFlags_NoSavedSettings |
        ImGuiWindowFlags_NoInputs);

    ImDrawList* drawList = ImGui::GetBackgroundDrawList();
    const ImVec2 displaySize = ImGui::GetIO().DisplaySize;
    const ImVec2 screenCenter = ImVec2(displaySize.x * 0.5f, displaySize.y * 0.15f);
    const float time = (float)ImGui::GetTime();

    drawList->AddText(ImVec2(18.0f, 18.0f), IM_COL32(255, 255, 255, 235), "ESP OVERLAY");
    drawList->AddText(ImVec2(18.0f, 38.0f), IM_COL32(120, 255, 180, 225), "3 MOCK TARGETS TRACKED");
    drawList->AddText(ImVec2(displaySize.x - 210.0f, 18.0f), IM_COL32(255, 210, 120, 225), "DEMO SIGNAL: STABLE");

    const MockEspEntity entities[] = {
        { "SCOUT-01", 0.0f, 0.27f, 0.18f, 122.0f, 0.42f, IM_COL32(90, 220, 255, 255), 0.15f },
        { "HEAVY-02", 1.8f, 0.18f, 0.25f, 148.0f, 0.46f, IM_COL32(255, 110, 110, 255), 0.45f },
        { "DRONE-03", 3.5f, 0.31f, 0.13f, 96.0f, 0.55f, IM_COL32(255, 215, 90, 255), 0.72f },
    };

    for (const MockEspEntity& entity : entities) {
        float oscillation = time + entity.PhaseOffset;
        float normalizedX = 0.5f + cosf(oscillation * 0.8f) * entity.OrbitScaleX;
        float normalizedY = 0.52f + sinf(oscillation * 1.15f) * entity.OrbitScaleY;
        ImVec2 head = ImVec2(displaySize.x * normalizedX, displaySize.y * normalizedY);

        float boxHeight = entity.HeightScale + sinf(oscillation * 1.6f) * 8.0f;
        float boxWidth = boxHeight * entity.WidthScale;
        ImVec2 boxMin = ImVec2(head.x - (boxWidth * 0.5f), head.y - (boxHeight * 0.3f));
        ImVec2 boxMax = ImVec2(head.x + (boxWidth * 0.5f), boxMin.y + boxHeight);
        float healthRatio = 0.35f + fabsf(sinf(time * 0.75f + entity.HealthOffset)) * 0.6f;
        float distanceMeters = 18.0f + fabsf(cosf(time * 0.55f + entity.PhaseOffset)) * 42.0f;

        drawList->AddLine(screenCenter, ImVec2(head.x, boxMax.y), entity.Color, 1.8f);
        drawList->AddCircleFilled(head, 4.0f, entity.Color);
        drawList->AddCircle(head, 9.0f + sinf(oscillation * 2.0f) * 1.5f, entity.Color, 24, 1.2f);
        drawList->AddRect(boxMin, boxMax, entity.Color, 5.0f, 0, 2.0f);
        drawList->AddRect(ImVec2(boxMin.x - 2.0f, boxMin.y - 2.0f), ImVec2(boxMax.x + 2.0f, boxMax.y + 2.0f), IM_COL32(255, 255, 255, 45), 6.0f, 0, 1.0f);

        DrawHealthBar(drawList, boxMin, boxHeight, healthRatio);

        char infoLabel[96];
        snprintf(infoLabel, sizeof(infoLabel), "%s  %.0fm", entity.Name, distanceMeters);
        drawList->AddText(ImVec2(boxMin.x, boxMin.y - 18.0f), IM_COL32(255, 255, 255, 235), infoLabel);

        char healthLabel[48];
        snprintf(healthLabel, sizeof(healthLabel), "HP %d%%", (int)(healthRatio * 100.0f));
        drawList->AddText(ImVec2(boxMin.x, boxMax.y + 8.0f), IM_COL32(190, 255, 200, 225), healthLabel);
    }

    ImGui::End();
}


void UserMenu::Initialize()
{
    DrawMenu();
    RenderingMenu();
}
