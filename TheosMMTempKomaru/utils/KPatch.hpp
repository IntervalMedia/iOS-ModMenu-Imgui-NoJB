/*
IOS Theos Template Komaru
Jailed (NoJB) Mod Menu Template for iOS Games
By aq9
https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB
*/


#pragma once

#include <iostream>

class KomaruPatch {
public:

    static uintptr_t ReadMem(uintptr_t address) {
        return *reinterpret_cast<uintptr_t*>(address);
    }

    template <typename T>
    static void WriteMem(uintptr_t address, const T& value) {
        *reinterpret_cast<T*>(address) = value;
    }

};
