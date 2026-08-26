#import "TweakManager.h"
#import "MenuLoad.h"
#import "../Source/BasicHacks.h"

@implementation TweakManager {
    BOOL _started;
}

+ (instancetype)sharedManager {
    static TweakManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TweakManager alloc] init];
    });
    return manager;
}

+ (void)load {
    // Preserve the original delayed startup while keeping bootstrap logic in one place.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        [[TweakManager sharedManager] start];
    });
}

- (void)start {
    if (_started) return;
    _started = YES;

    BasicCheats.Initialize();
    [[MenuLoad sharedManager] start];
}

@end
