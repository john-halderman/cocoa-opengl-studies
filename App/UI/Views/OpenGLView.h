#import <Cocoa/Cocoa.h>

@interface OpenGLView : NSOpenGLView {

}

- (void)renderForTime:(CVTimeStamp)time;
- (void)drawRect:(NSRect)dirtyRect;

@end
