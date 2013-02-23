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
	NSWindow *fullScreenWindow = [[[NSWindow alloc] initWithContentRect: mainDisplayRect
															 styleMask:NSBorderlessWindowMask
															   backing:NSBackingStoreBuffered
																 defer:YES] autorelease];
	[fullScreenWindow setLevel:NSMainMenuWindowLevel+1];
	[fullScreenWindow setOpaque:YES];
	[fullScreenWindow setHidesOnDeactivate:YES];

	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFADoubleBuffer,
		0
	};

	NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];

	NSRect viewRect = NSMakeRect(0.f, 0.f, mainDisplayRect.size.width, mainDisplayRect.size.height);

	OpenGLView *fullScreenView = [[[OpenGLView alloc] initWithFrame:viewRect pixelFormat:pixelFormat] autorelease];

	[fullScreenWindow setContentView:fullScreenView];

	[fullScreenWindow makeKeyAndOrderFront:self];

	self.studyController = [[[StudyController alloc] initWithWindow:fullScreenWindow] autorelease];
}

@end
