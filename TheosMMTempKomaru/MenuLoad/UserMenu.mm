#include "UserMenu.h"
#include "Includes.h"

void UserMenu::DrawMenu()
{


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

        ImGui::SliderFloat("ExampleSlider", &KTempVars.FloatModExample, 0.0f, 100.0f);

        //misc menu options
        ImGui::Checkbox("Move Menu", &KTempVars.MoveMenu);
        ImGui::SameLine();
        ImGui::Checkbox("Streamer Mode", &KTempVars.StreamerMode);

        ImGui::End();
    }
}


void UserMenu::RenderingMenu()
{
    ImGui::Begin("RenderMenu", nullptr,
        ImGuiWindowFlags_NoTitleBar |
        ImGuiWindowFlags_NoResize |
        ImGuiWindowFlags_NoMove |
        ImGuiWindowFlags_NoBackground |
        ImGuiWindowFlags_NoInputs);

    ImDrawList* drawList = ImGui::GetBackgroundDrawList();

    // Render drawings here

    ImGui::End();
}


void UserMenu::Initialize()
{
    DrawMenu();
    RenderingMenu();
}
