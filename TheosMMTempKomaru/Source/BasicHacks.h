/*
IOS Theos Template Komaru
Jailed (NoJB) Mod Menu Template for iOS Games
By aq9
https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB

#pragma once

class BasicHacks {
public:
    BasicHacks(const BasicHacks&) = delete;

    static BasicHacks& GetInstance() {
        static BasicHacks Instance;
        return Instance;
    }

    static bool IsValidPointer(long Offset);
    static void HacksThread();

    void Initialize();

private:
    BasicHacks() { }
};

static BasicHacks& BasicCheats = BasicHacks::GetInstance();

// BasicHacks.h
#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include "KomaruPatch.h" // Include KomaruPatch header
#include "../MenuLoad/Includes.h"
*/
// Define uintptr_t if not already defined
#pragma once

#ifndef uintptr_t
#include <cstdint>
using uintptr_t = std::uintptr_t;
#endif


namespace offsets {
    extern constexpr uintptr_t OFFSET_GWorld;
    extern constexpr uintptr_t OFFSET_OwningGameInstance;
    extern constexpr uintptr_t OFFSET_LocalPlayers;
    extern constexpr uintptr_t OFFSET_LocalPlayerController;
    extern constexpr uintptr_t OFFSET_PlayerCameraManager;
}

class BasicHacks {
public:
    BasicHacks(const BasicHacks&) = delete;

    static BasicHacks& GetInstance() {
        static BasicHacks Instance;
        return Instance;
    }

    static bool IsValidPointer(long Offset);
    static void HacksThread();
    
    void Initialize();

private:
    BasicHacks() { }
};

static BasicHacks& BasicCheats = BasicHacks::GetInstance();

@interface GameLoop : NSObject

- (void)start;
- (void)stop;

@end

