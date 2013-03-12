#import "StudyAppDelegate.h"
#import "StudyController.h"
#import "OpenGLView.h"

@interface StudyAppDelegate ()

@property (retain, nonatomic) StudyController *studyController;

@end

@implementation StudyAppDelegate

- (void)dealloc {
	self.studyController = nil;

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	NSRect mainDisplayRect = [[NSScreen mainScreen] frame];

	NSRect viewRect = NSMakeRect(0.f, 0.f, mainDisplayRect.size.width, mainDisplayRect.size.height);

	NSWindow *fullScreenWindow = [[[NSWindow alloc] initWithContentRect:mainDisplayRect
															  styleMask:NSBorderlessWindowMask
																backing:NSBackingStoreBuffered
																  defer:YES] autorelease];

	[fullScreenWindow setLevel:NSMainMenuWindowLevel+1];
	[fullScreenWindow setOpaque:YES];
	[fullScreenWindow setHidesOnDeactivate:YES];

	[fullScreenWindow setContentView:[self fullScreenOpenGLViewWithViewRect:viewRect]];

	[((OpenGLView *)fullScreenWindow.contentView).openGLContext makeCurrentContext];

	self.studyController = [[[StudyController alloc] initWithWindow:fullScreenWindow] autorelease];

	[fullScreenWindow makeKeyAndOrderFront:self];

}

#pragma mark - private

- (NSOpenGLView *)fullScreenOpenGLViewWithViewRect:(CGRect)viewRect {

	NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 24                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        0
	};

	NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];

//	CGLPixelFormatAttribute attributes[] = {
//		kCGLPFADisplayMask, (CGLPixelFormatAttribute)0,
//		kCGLPFANoRecovery,
//		kCGLPFAOpenGLProfile, (CGLPixelFormatAttribute)kCGLOGLPVersion_3_2_Core,
//		kCGLPFAColorSize,     (CGLPixelFormatAttribute)24,
//		kCGLPFAAlphaSize,     (CGLPixelFormatAttribute)8,
//		kCGLPFAAccelerated,
//		kCGLPFADoubleBuffer,
//		kCGLPFASampleBuffers, (CGLPixelFormatAttribute)1,
//		kCGLPFASamples,       (CGLPixelFormatAttribute)4,
//		(CGLPixelFormatAttribute)0
//	};
//
//	CGLPixelFormatObj cglPixelFormat = NULL;
//	GLint virtualScreenCount = 0;
//	CGDirectDisplayID display = CGMainDisplayID();
//	attributes[1] = CGDisplayIDToOpenGLDisplayMask(display);
//	CGLError error = CGLChoosePixelFormat(attributes, &cglPixelFormat, &virtualScreenCount);
//	const char *pixelFormatErrorChars = CGLErrorString(error);
//
//	NSLog(@"================> %@", [NSString stringWithCString:pixelFormatErrorChars encoding:NSUTF8StringEncoding]);
//
//	NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithCGLPixelFormatObj:cglPixelFormat] autorelease];

	OpenGLView *fullScreenView = [[[OpenGLView alloc] initWithFrame:viewRect pixelFormat:pixelFormat] autorelease];

	GLint swapInt = 1;
    [[fullScreenView openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

	return fullScreenView;
}

@end
