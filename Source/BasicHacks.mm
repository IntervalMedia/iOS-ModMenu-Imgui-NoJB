
// BasicHacks.mm 
// by silentNinjaBee - using GCD for timing and thread management
#import "BasicHacks.h"
#include "../MenuLoad/Includes.h"
#include <chrono>
#include <thread>

namespace offsets {
    constexpr uintptr_t OFFSET_GWorld                   = 0x04d5b510;
    constexpr uintptr_t OFFSET_OwningGameInstance       = 0x320;
    constexpr uintptr_t OFFSET_LocalPlayers             = 0x38;
    constexpr uintptr_t OFFSET_LocalPlayerController    = 0x30;
    constexpr uintptr_t OFFSET_PlayerCameraManager      = 0x480;
}

void BasicHacks::HacksThread() {
    using namespace offsets;

    static uintptr_t BaseAddr = (uintptr_t)_dyld_get_image_header(0);
    static uintptr_t GWorld = 0;

    if (GWorld == 0) {
        GWorld = KomaruPatch::ReadMem(BaseAddr + OFFSET_GWorld);
    }
    if(!GWorld) return;

    uintptr_t OwningGameInstance = KomaruPatch::ReadMem(GWorld + OFFSET_OwningGameInstance);
    if(!OwningGameInstance) return;

    uintptr_t LocalPlayers = KomaruPatch::ReadMem(OwningGameInstance + OFFSET_LocalPlayers);
    if(!LocalPlayers) return;

    uintptr_t LocalPlayer = KomaruPatch::ReadMem(LocalPlayers);
    if(!LocalPlayer) return;

    uintptr_t LocalPlayerController = KomaruPatch::ReadMem(LocalPlayer + OFFSET_LocalPlayerController);
    if(!LocalPlayerController) return;

    uintptr_t PlayerCameraManager = KomaruPatch::ReadMem(LocalPlayerController + OFFSET_PlayerCameraManager);
    if(!PlayerCameraManager) return;

    if(!KomaruPatch::WriteMem<float>(PlayerCameraManager + 0x33c0, KTempVars.CameraFOV)){
        return;
    }
}

@implementation GameLoop {
    dispatch_source_t _timer;
}

- (void)start {
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);

    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    if (_timer) {
        NSTimeInterval interval = 1.0 / 30.0;
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), (uint64_t)(interval * NSEC_PER_SEC), 0);

        dispatch_source_set_event_handler(_timer, ^{
            BasicHacks::HacksThread();
        });

        dispatch_resume(_timer);
    } else {
        NSLog(@"Failed to create timer");
    }
}

- (void)stop {
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_source_set_cancel_handler(_timer, ^{
            _timer = nil;
        });
    }
}

@end

void BasicHacks::Initialize(){
    static GameLoop *gameLoop = [[GameLoop alloc] init];
    [gameLoop start];
}

