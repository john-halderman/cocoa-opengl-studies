#import "Figure.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <OpenGL/glu.h>
#import "Study.h"

static GLsizei const kVertexCount = 4;

@interface Figure ()

@property (assign, nonatomic) GLuint vertexArrayObject;
@property (assign, nonatomic) GLuint vertexBuffer;
@property (assign, nonatomic, readwrite) CGRect rect;
@property (assign, nonatomic) size_t offset;
@property (assign, nonatomic) GLsizei drawOffset;
@property (assign, nonatomic) GLint colorAttribute;
@property (assign, nonatomic) GLint positionAttribute;

@end

@implementation Figure

- (void)dealloc {
	glDeleteBuffers(1, &_vertexBuffer);
	printGlErrors(@"delete buffers");
	[super dealloc];
}

- (id)initWithRect:(CGRect)rect
			offset:(size_t)offset
		drawOffset:(GLsizei)drawOffset
	  vertexBuffer:(GLuint)vertexBuffer
 positionAttribute:(GLint)positionAttribute
	colorAttribute:(GLint)colorAttribute {

	if (self = [super init]) {
		self.rect = rect;
		self.offset = offset;
		self.drawOffset = drawOffset;
		self.vertexBuffer = vertexBuffer;
		self.positionAttribute = positionAttribute;
		self.colorAttribute = colorAttribute;
	}
	return self;
}

- (void)draw {
    glBindVertexArray(self.vertexArrayObject);
	NSLog(@"================> glBindVertexArray(%d)", self.vertexArrayObject);
    printGlErrors([NSString stringWithFormat:@"glBindVertexArray(%d)", self.vertexArrayObject]);

	glDrawArrays(GL_TRIANGLE_FAN, self.drawOffset, kVertexCount);
	printGlErrors(@"glDrawArrays(TRIANGLE_FAN)");
}

- (size_t)bufferSize {
	return kVertexCount * sizeof(Vertex);
}

- (GLsizei)vertexCount {
	return kVertexCount;
}

- (void)loadBufferData {
	GLfloat x  = self.rect.origin.x - self.rect.size.width  / 2.0;
	GLfloat xp = self.rect.origin.x + self.rect.size.width  / 2.0;
	GLfloat y  = self.rect.origin.y - self.rect.size.height / 2.0;
	GLfloat yp = self.rect.origin.y + self.rect.size.height / 2.0;

    Vertex vertexData[kVertexCount] = {
        { .position = { .x=x , .y=y , .z=0.0, .w=1.0 }, .color = { .r=1.0, .g=0.0, .b=0.0, .a=1.0 } },
        { .position = { .x=x , .y=yp, .z=0.0, .w=1.0 }, .color = { .r=0.0, .g=1.0, .b=0.0, .a=1.0 } },
        { .position = { .x=xp, .y=yp, .z=0.0, .w=1.0 }, .color = { .r=0.0, .g=0.0, .b=1.0, .a=1.0 } },
        { .position = { .x=xp, .y=y , .z=0.0, .w=1.0 }, .color = { .r=1.0, .g=1.0, .b=1.0, .a=1.0 } }
    };

    glGenVertexArrays(1, &_vertexArrayObject);
    printGlErrors(@"glGenVertexArrays()");

    glBindVertexArray(self.vertexArrayObject);
	NSLog(@"================> glBindVertexArray(%d)", self.vertexArrayObject);
    printGlErrors([NSString stringWithFormat:@"glBindVertexArray(%d)", self.vertexArrayObject]);

	glBufferSubData(GL_ARRAY_BUFFER, self.offset, [self bufferSize], vertexData);
	printGlErrors([NSString stringWithFormat:@"glBufferSubData(%ld)", self.offset]);

	[self enableVertexArray];

	[self setupVertexAttributePointers];
}

#pragma mark -- private

- (void)enableVertexArray {
	glEnableVertexAttribArray((GLuint)self.positionAttribute);
	printGlErrors(@"glEnableVerexAttribArray(positionAttribute)");

	glEnableVertexAttribArray((GLuint)self.colorAttribute);
	printGlErrors(@"glEnableVerexAttribArray(colorAttribute)");
}

- (void)setupVertexAttributePointers {
	size_t positionOffset = self.offset + offsetof(Vertex, position);
	size_t colorOffset = self.offset + offsetof(Vertex, color);

	glVertexAttribPointer((GLuint)self.positionAttribute, kPositionSize, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)positionOffset);
	printGlErrors(@"glEnableVerexAttribPointer(positionAttribute)");

	glVertexAttribPointer((GLuint)self.colorAttribute, kColorSize, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)colorOffset);
	printGlErrors(@"glEnableVerexAttribPointer(colorAttribute)");
}

@end
