#import "ImGuiController.h"

#include "../ImGui/imgui.h"
#include "../ImGui/imgui_impl_metal.h"
#include "../Font.h"

@interface ImGuiController ()
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, assign) BOOL initialized;
@end

@implementation ImGuiController

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (!self) return nil;

    _device = device;
    [self initializeImGui];
    return self;
}

- (void)initializeImGui {
    if (self.initialized) return;

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();

    ImGuiIO& io = ImGui::GetIO();
    io.IniFilename = nullptr;
    io.Fonts->Clear();

    ImFontConfig fontConfig;
    fontConfig.FontDataOwnedByAtlas = false;
    io.FontDefault = io.Fonts->AddFontFromMemoryCompressedBase85TTF(
        CurvyBase85,
        16.0f,
        &fontConfig,
        io.Fonts->GetGlyphRangesChineseFull()
    );

    ImGui::StyleColorsClassic();
    ImGui_ImplMetal_Init(self.device);

    self.initialized = YES;
}

- (void)beginFrameWithView:(MTKView *)view
      renderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor {
    if (!self.initialized) return;

    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);

    CGFloat scale = view.window.screen.nativeScale;
    if (scale <= 0.0f) scale = UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(scale, scale);

    NSInteger framesPerSecond = view.preferredFramesPerSecond;
    io.DeltaTime = 1.0f / (float)(framesPerSecond > 0 ? framesPerSecond : 60);

    ImGui_ImplMetal_NewFrame(renderPassDescriptor);
    ImGui::NewFrame();
}

- (void)renderWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
                  renderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    if (!self.initialized) return;

    ImGui::Render();
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);
}

- (void)updateInputWithTouchEvent:(UIEvent *)event inView:(UIView *)view {
    if (!self.initialized) return;

    ImGuiIO& io = ImGui::GetIO();
    NSSet<UITouch *> *touches = event.allTouches;

    UITouch *activeTouch = nil;
    UITouch *lastTouch = nil;

    for (UITouch *touch in touches) {
        lastTouch = touch;
        if (touch.phase == UITouchPhaseBegan ||
            touch.phase == UITouchPhaseMoved ||
            touch.phase == UITouchPhaseStationary) {
            activeTouch = touch;
            break;
        }
    }

    UITouch *positionTouch = activeTouch ?: lastTouch;
    if (positionTouch) {
        CGPoint location = [positionTouch locationInView:view];
        io.MousePos = ImVec2(location.x, location.y);
    }

    io.MouseDown[0] = (activeTouch != nil);
}

- (void)shutdown {
    if (!self.initialized) return;

    ImGui_ImplMetal_Shutdown();
    ImGui::DestroyContext();
    self.initialized = NO;
}

- (void)dealloc {
    [self shutdown];
}

@end
