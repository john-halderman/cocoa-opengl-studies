#import "Scene.h"
#import "ShaderProgram.h"
#import "Study.h"
#import "Figure.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <OpenGL/glu.h>


@interface Scene ()

@property (retain, nonatomic) ShaderProgram *program;
@property (assign, nonatomic) GLfloat time;
@property (retain, nonatomic) NSMutableArray *geometry;
@property (assign, nonatomic) GLuint vertexBuffer;

@end

@implementation Scene

- (void)dealloc {
	self.program = nil;
	self.geometry = nil;
	glDeleteBuffers(1, &_vertexBuffer);
	printGlErrors(@"delete buffers");
	[super dealloc];
}

- (id)init {
	if (self = [super init]) {
		self.program = [[[ShaderProgram alloc] init] autorelease];

/* 

 Buffer Data needs to be loaded all at once, or a sufficiently large buffer needs to be allocated at first and then the individual arrays need to be loaded in.

*/
		self.geometry = [NSMutableArray array];
		[self.geometry addObject:[[[Figure alloc] initWithRect:CGRectMake(-0.55f, 0.f, 0.55f, 0.55f)
														offset:0
													drawOffset:0
												  vertexBuffer:self.vertexBuffer
											 positionAttribute:self.program.positionAttribute
												colorAttribute:self.program.colorAttribute] autorelease]];

		[self.geometry addObject:[[[Figure alloc] initWithRect:CGRectMake(0.55f, 0.f, 0.55f, 0.55f)
														offset:[self.geometry[0] bufferSize]
													drawOffset:[self.geometry[0] vertexCount]
												  vertexBuffer:self.vertexBuffer
											 positionAttribute:self.program.positionAttribute
												colorAttribute:self.program.colorAttribute] autorelease]];

		glGenBuffers(1, &_vertexBuffer);
		printGlErrors(@"glGenBuffers()");

		glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
		printGlErrors(@"glBindBuffers()");

		size_t bufferSize = 0;
		for (Figure *figure in self.geometry) {
			bufferSize += [figure bufferSize];
		}

		glBufferData(GL_ARRAY_BUFFER, bufferSize, NULL, GL_STATIC_DRAW);
		printGlErrors(@"glBufferData()");

		for (Figure *figure in self.geometry) {
			[figure loadBufferData];
		}

		self.time = 0.f;
	}
	return self;
}

- (void)render {
	glClearColor(0.0, 0.0, 0.0, 1.0);
	printGlErrors(@"glClearColor");

	glClear(GL_COLOR_BUFFER_BIT);
	printGlErrors(@"glClear");

	[self.program bindShaderForTime:self.time];

	for (Figure *figure in self.geometry) {

//		[self.program bindSize:figure.size / 0.25];
		[figure draw];
	}
}

- (void)advanceTimeBy:(GLfloat)seconds {
	NSLog(@"================> Advancing time by %.4f, %.4f", self.time, seconds);
	self.time += seconds;
}


@end
