#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ImGuiDrawView;

// UIKit coordinator for the overlay host, touch routing, and floating launcher.
@interface MenuLoad : NSObject

+ (instancetype)sharedManager;
- (void)start;

// Called only when the menu setting changes; keeps capture behavior out of the render loop.
+ (void)applyStreamerMode:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
