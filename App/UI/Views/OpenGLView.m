#import "OpenGLView.h"
#include <OpenGL/gl.h>

@implementation OpenGLView

- (void)dealloc {
	[self.openGLContext clearDrawable];
	[self clearGLContext];
	[NSOpenGLContext clearCurrentContext];

	[super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format {
	if (self = [super initWithFrame:frameRect pixelFormat:format]) {
		[self setWantsBestResolutionOpenGLSurface:YES];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[self.openGLContext clearDrawable];
	[self.openGLContext setView:self];
	[self.openGLContext makeCurrentContext];

	// Get view dimensions in pixels
    NSRect backingBounds = [self convertRectToBacking:[self bounds]];

    GLsizei backingPixelWidth  = (GLsizei)(backingBounds.size.width),
	backingPixelHeight = (GLsizei)(backingBounds.size.height);

    // Set viewport
    glViewport(0, 0, backingPixelWidth, backingPixelHeight);

	glClearColor(0.f, 0.f, 0.f, 0.f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	drawAnObject();
//	glFlush();

	[self.openGLContext flushBuffer];
	[NSOpenGLContext clearCurrentContext];
}

static void drawAnObject () {
	glColor3f(1.0f, 0.85f, 0.35f);
	glBegin(GL_TRIANGLES);
	{
		glVertex3f(0.f, 0.6f, 0.f);
		glVertex3f(-0.2f, -0.3f, 0.f);
		glVertex3f(0.2f, -0.3f, 0.f);
	}
	glEnd();
}

@end
