#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImGuiDrawView : UIViewController

+ (void)setMenuVisible:(BOOL)visible;
+ (BOOL)isMenuShowing;

// Legacy name kept so existing template code continues to compile.
+ (void)showChange:(BOOL)open;

// MenuInteraction forwards UIKit touch events through this single entry point.
- (void)updateIOWithTouchEvent:(UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
