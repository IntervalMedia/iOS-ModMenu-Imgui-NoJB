#import "ImGuiDrawView.h"
#import "ImGuiController.h"

#include "UserMenu.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface ImGuiDrawView () <MTKViewDelegate>

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) ImGuiController *imguiController;

@end

@implementation ImGuiDrawView

static BOOL sMenuVisible = NO;

- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;

    _device = MTLCreateSystemDefaultDevice();
    if (!_device) return nil;

    _commandQueue = [_device newCommandQueue];
    _imguiController = [[ImGuiController alloc] initWithDevice:_device];

    return self;
}

+ (void)setMenuVisible:(BOOL)visible {
    sMenuVisible = visible;
}

+ (void)showChange:(BOOL)open {
    [self setMenuVisible:open];
}

+ (BOOL)isMenuShowing {
    return sMenuVisible;
}

- (MTKView *)mtkView {
    return (MTKView *)self.view;
}

- (void)loadView {
    MTKView *view = [[MTKView alloc] initWithFrame:UIScreen.mainScreen.bounds
                                           device:self.device];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MTKView *view = self.mtkView;
    view.delegate = self;
    view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0);
    view.backgroundColor = UIColor.clearColor;
    view.opaque = NO;
    view.clipsToBounds = YES;
    view.preferredFramesPerSecond = 60;

    // Touches are routed by MenuInteraction so the renderer itself never blocks the host app.
    view.userInteractionEnabled = NO;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    [self.imguiController updateInputWithTouchEvent:event inView:self.view];
}

- (void)drawInMTKView:(MTKView *)view {
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    id<CAMetalDrawable> drawable = view.currentDrawable;
    if (!renderPassDescriptor || !drawable) return;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if (!commandBuffer) return;

    id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    if (!renderEncoder) return;

    [renderEncoder pushDebugGroup:@"Dear ImGui Rendering"];

    [self.imguiController beginFrameWithView:view
                        renderPassDescriptor:renderPassDescriptor];

    UserMenu::GetInstance().Draw([ImGuiDrawView isMenuShowing]);

    [self.imguiController renderWithCommandBuffer:commandBuffer
                                    renderEncoder:renderEncoder];

    [renderEncoder popDebugGroup];
    [renderEncoder endEncoding];

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    // DisplaySize and framebuffer scale are refreshed in ImGuiController::beginFrame.
}

@end
