/*
IOS Theos Template Komaru
Jailed (NoJB) Mod Menu Template for iOS Games
By aq9
https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB
*/



#pragma once

class UserMenu {
public:
    UserMenu(const UserMenu&) = delete;

    static UserMenu& GetInstance() {
        static UserMenu Instance;
        return Instance;
    }

    void DrawMenu();
    void RenderingMenu();
    void Initialize();

private:
    UserMenu() { }
};

static UserMenu& Menu = UserMenu::GetInstance();