#import "MenuLoad.h"
#import "ImGuiDrawView.h"

#include "AppState.h"

#import <QuartzCore/QuartzCore.h>

namespace {
constexpr CGFloat kLauncherSize = 50.0f;
constexpr NSTimeInterval kWindowRetryDelay = 0.5;

UIWindow *ActiveWindow() {
    UIApplication *application = UIApplication.sharedApplication;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in application.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            if (scene.activationState != UISceneActivationStateForegroundActive &&
                scene.activationState != UISceneActivationStateForegroundInactive) continue;

            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) return window;
            }

            if (windowScene.windows.firstObject) {
                return windowScene.windows.firstObject;
            }
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return application.keyWindow ?: application.windows.firstObject;
#pragma clang diagnostic pop
}
} // namespace

@interface MenuInteraction : UIView
@property (nonatomic, weak) ImGuiDrawView *targetView;
@end

@implementation MenuInteraction

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (![ImGuiDrawView isMenuShowing]) return NO;

    CGRect menuFrame = CGRectMake(
        KTempVars.MenuOrigin.x,
        KTempVars.MenuOrigin.y,
        KTempVars.MenuSize.x,
        KTempVars.MenuSize.y
    );

    return !CGRectIsEmpty(menuFrame) && CGRectContainsPoint(menuFrame, point);
}

- (void)forwardTouchEvent:(UIEvent *)event {
    [self.targetView updateIOWithTouchEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self forwardTouchEvent:event];
}

@end

@interface MenuLoad ()
@property (nonatomic, assign) BOOL started;
@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, strong) UIView *captureWrapper;
@property (nonatomic, strong) UIView *overlayHostView;
@property (nonatomic, strong) UITextField *captureTextField;
@property (nonatomic, strong) ImGuiDrawView *imguiView;
@property (nonatomic, strong) MenuInteraction *touchView;
@property (nonatomic, strong) UIButton *launcherInputButton;
@property (nonatomic, strong) UIButton *launcherVisualButton;
@end

@implementation MenuLoad

+ (instancetype)sharedManager {
    static MenuLoad *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MenuLoad alloc] init];
    });
    return manager;
}

- (void)start {
    if (self.started) return;

    UIWindow *window = ActiveWindow();
    UIView *rootView = window.rootViewController.view;
    if (!window || !rootView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(kWindowRetryDelay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self start];
        });
        return;
    }

    self.started = YES;
    self.rootView = rootView;

    [self installCaptureHostInWindow:window];
    [self installRenderer];
    [self installTouchRouter];
    [self installLauncher];

    [ImGuiDrawView setMenuVisible:NO];
    self.touchView.userInteractionEnabled = NO;
    [MenuLoad applyStreamerMode:KTempVars.StreamerMode];
}

- (void)installCaptureHostInWindow:(UIWindow *)window {
    UIView *wrapper = [[UIView alloc] initWithFrame:window.bounds];
    wrapper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    wrapper.backgroundColor = UIColor.clearColor;
    wrapper.userInteractionEnabled = NO;

    UITextField *textField = [[UITextField alloc] initWithFrame:wrapper.bounds];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textField.backgroundColor = UIColor.clearColor;
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = UIColor.clearColor;
    textField.userInteractionEnabled = NO;
    textField.secureTextEntry = YES;

    [wrapper addSubview:textField];
    [window addSubview:wrapper];

    UIView *secureContentView = nil;
    id delegate = textField.layer.sublayers.firstObject.delegate;
    if ([delegate isKindOfClass:UIView.class]) {
        secureContentView = (UIView *)delegate;
    }

    self.captureWrapper = wrapper;
    self.captureTextField = textField;
    self.overlayHostView = secureContentView ?: wrapper;
    self.overlayHostView.userInteractionEnabled = NO;
}

- (void)installRenderer {
    self.imguiView = [[ImGuiDrawView alloc] init];
    self.imguiView.view.frame = self.overlayHostView.bounds;
    self.imguiView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imguiView.view.backgroundColor = UIColor.clearColor;

    [self.overlayHostView addSubview:self.imguiView.view];
}

- (void)installTouchRouter {
    MenuInteraction *touchView = [[MenuInteraction alloc] initWithFrame:self.rootView.bounds];
    touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    touchView.backgroundColor = UIColor.clearColor;
    touchView.targetView = self.imguiView;

    [self.rootView addSubview:touchView];
    self.touchView = touchView;
}

- (void)installLauncher {
    CGRect bounds = self.rootView.bounds;
    CGPoint initialCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGRect frame = CGRectMake(0.0f, 0.0f, kLauncherSize, kLauncherSize);

    UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inputButton.frame = frame;
    inputButton.center = initialCenter;
    inputButton.backgroundColor = UIColor.clearColor;
    inputButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleRightMargin |
                                   UIViewAutoresizingFlexibleTopMargin |
                                   UIViewAutoresizingFlexibleBottomMargin;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(toggleMenu:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(moveLauncher:)];
    [inputButton addGestureRecognizer:tap];
    [inputButton addGestureRecognizer:pan];

    [self.rootView addSubview:inputButton];
    self.launcherInputButton = inputButton;

    UIButton *visualButton = [UIButton buttonWithType:UIButtonTypeCustom];
    visualButton.frame = frame;
    visualButton.center = initialCenter;
    visualButton.userInteractionEnabled = NO;
    visualButton.backgroundColor = [UIColor colorWithWhite:0.08f alpha:0.78f];
    visualButton.tintColor = UIColor.whiteColor;
    visualButton.layer.cornerRadius = kLauncherSize * 0.5f;
    visualButton.clipsToBounds = YES;

    UIImage *icon = [UIImage systemImageNamed:@"circle.grid.2x2.fill"];
    [visualButton setImage:icon forState:UIControlStateNormal];

    [self.overlayHostView addSubview:visualButton];
    self.launcherVisualButton = visualButton;
}

- (void)toggleMenu:(UITapGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) return;

    BOOL visible = ![ImGuiDrawView isMenuShowing];
    [ImGuiDrawView setMenuVisible:visible];
    self.touchView.userInteractionEnabled = visible;

    if (!visible) {
        // Ensure ImGui does not retain a pressed pointer when the menu closes mid-touch.
        UIEvent *event = gesture.view.window ? nil : nil;
        (void)event;
    }
}

- (void)moveLauncher:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.rootView];
    CGPoint center = self.launcherInputButton.center;
    center.x += translation.x;
    center.y += translation.y;

    [self setLauncherCenter:center];
    [gesture setTranslation:CGPointZero inView:self.rootView];
}

- (void)setLauncherCenter:(CGPoint)center {
    CGRect bounds = self.rootView.bounds;
    CGFloat radius = kLauncherSize * 0.5f;

    center.x = MAX(radius, MIN(center.x, CGRectGetWidth(bounds) - radius));
    center.y = MAX(radius, MIN(center.y, CGRectGetHeight(bounds) - radius));

    self.launcherInputButton.center = center;
    self.launcherVisualButton.center = center;
}

+ (void)applyStreamerMode:(BOOL)enabled {
    dispatch_async(dispatch_get_main_queue(), ^{
        MenuLoad *manager = [MenuLoad sharedManager];
        manager.captureTextField.secureTextEntry = enabled;
    });
}

@end
