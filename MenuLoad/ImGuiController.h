#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

// Owns the Dear ImGui lifecycle for the Metal renderer.
// ImGuiDrawView only drives this controller once per MTKView frame.
@interface ImGuiController : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)beginFrameWithView:(MTKView *)view
      renderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor;

- (void)renderWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
                  renderEncoder:(id<MTLRenderCommandEncoder>)renderEncoder;

- (void)updateInputWithTouchEvent:(UIEvent *)event inView:(UIView *)view;
- (void)shutdown;

@end

NS_ASSUME_NONNULL_END
