#pragma once

class UserMenu {
public:
    UserMenu(const UserMenu&) = delete;
    UserMenu& operator=(const UserMenu&) = delete;

    static UserMenu& GetInstance() {
        static UserMenu instance;
        return instance;
    }

    // Main entry point used by the renderer.
    void Draw(bool menuVisible);

    // Compatibility helpers retained for existing template code.
    void DrawMenu();
    void RenderingMenu();
    void Initialize();

private:
    UserMenu() = default;

    void DrawMainMenu();
    void DrawOverlay();
};

static UserMenu& Menu = UserMenu::GetInstance();
