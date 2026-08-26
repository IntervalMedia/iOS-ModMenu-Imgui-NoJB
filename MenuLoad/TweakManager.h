#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Single bootstrap/coordinator for the tweak runtime.
@interface TweakManager : NSObject

+ (instancetype)sharedManager;
- (void)start;

@end

NS_ASSUME_NONNULL_END
