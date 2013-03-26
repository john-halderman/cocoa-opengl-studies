#import "OpenGLView.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <OpenGL/glu.h>
#import <CoreVideo/CVDisplayLink.h>
#import "Study.h"
#import "Scene.h"

@interface OpenGLView()

@property (retain, nonatomic) Scene *scene;

@property (assign, nonatomic) CVDisplayLinkRef displayLink;
@property (assign, nonatomic) GLfloat timeValue, lastTimeValue, averageDrawInterval;

@property (assign, nonatomic) long currentFrameCount, totalFrameCount;
@property (assign, nonatomic) CFTimeInterval lastTimeChecked, startDrawTime;

- (void)renderForTime:(CVTimeStamp)time;

@end

CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
    OpenGLView *view = (OpenGLView *)displayLinkContext;
    [view renderForTime:*inOutputTime];
    return kCVReturnSuccess;
}

@implementation OpenGLView

- (void)dealloc {
	[self.openGLContext clearDrawable];
	[self clearGLContext];
	[NSOpenGLContext clearCurrentContext];

	self.scene = nil;

    CVDisplayLinkStop(self.displayLink);
    CVDisplayLinkRelease(self.displayLink);

	[super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	if (self = [super initWithFrame:frameRect pixelFormat:format]) {
		[self setWantsBestResolutionOpenGLSurface:YES];
		[self.openGLContext makeCurrentContext];

		self.startDrawTime = CFAbsoluteTimeGetCurrent();
		self.timeValue = 0.f;
		self.lastTimeValue = 0.f;
		self.averageDrawInterval = 1.f / 60.f;
		self.currentFrameCount = 0;
		self.totalFrameCount = 0;

		self.scene = [[[Scene alloc] init] autorelease];

		[self createDisplayLink];

	}
	return self;
}

- (void)renderForTime:(CVTimeStamp)time {
	++ _currentFrameCount;
	++ _totalFrameCount;

	CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();

	[self logFramesPerSecond:currentTime];

//  self.timeValue = (GLfloat)(time.videoTime) / (GLfloat)(time.videoTimeScale);
//	self.lastDrawTime = self.timeValue;

	self.lastTimeValue = self.timeValue;
//	self.timeValue = currentTime - self.startDrawTime;

//	self.averageDrawInterval = (self.averageDrawInterval + ((currentTime - self.startDrawTime) - self.lastTimeValue)) / (GLfloat)self.totalFrameCount;
	self.timeValue += self.averageDrawInterval;

//	NSLog(@"================> %f, %ld, %ld", self.lastTimeValue, self.currentFrameCount, self.totalFrameCount);
//	NSLog(@"================> %f, %f, %f", self.timeValue, self.timeValue - self.lastTimeValue, self.averageDrawInterval);

	[self.scene advanceTimeBy:self.averageDrawInterval];

	CGLLockContext(self.openGLContext.CGLContextObj);
	[self.openGLContext makeCurrentContext];

	[self.scene render];

	[self.openGLContext flushBuffer];
	CGLUnlockContext(self.openGLContext.CGLContextObj);
}

- (void)logFramesPerSecond:(CFTimeInterval)currentTime {
	CFTimeInterval elapsedTime = currentTime - self.lastTimeChecked;
	if (elapsedTime > 1.f) {
//		NSLog(@"================> Frames per second: %.5f", self.currentFrameCount / elapsedTime);
		self.currentFrameCount = 0;
		self.lastTimeChecked = currentTime;
	}
}

- (void)drawRect:(NSRect)dirtyRect {
}

- (void)createDisplayLink {
//    CGDirectDisplayID displayID = CGMainDisplayID();

	CVReturn error = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);

    if (kCVReturnSuccess == error) {
        CVDisplayLinkSetOutputCallback(self.displayLink, displayCallback, self);

		//Set the display link for the current renderer
		CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
		CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
		CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(self.displayLink, cglContext, cglPixelFormat);

        CVDisplayLinkStart(self.displayLink);
    } else {
        NSLog(@"Display Link created with error: %d", error);
        self.displayLink = NULL;
    }
}

@end
