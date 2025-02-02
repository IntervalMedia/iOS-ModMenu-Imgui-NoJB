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

#import <Foundation/Foundation.h>
#include <cstdint>

@interface GameLoop : NSObject

- (void)start;
- (void)stop;

@end


namespace offsets {
    extern uintptr_t OFFSET_GWorld;
    extern uintptr_t OFFSET_OwningGameInstance;
    extern uintptr_t OFFSET_LocalPlayers;
    extern uintptr_t OFFSET_LocalPlayerController;
    extern uintptr_t OFFSET_PlayerCameraManager;
};

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
