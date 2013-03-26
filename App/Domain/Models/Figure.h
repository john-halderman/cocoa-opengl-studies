#import <Foundation/Foundation.h>

@interface Figure : NSObject

@property (assign, nonatomic, readonly) CGRect rect;

- (id)initWithRect:(CGRect)rect
			offset:(size_t)offset
		drawOffset:(GLsizei)drawOffset
	  vertexBuffer:(GLuint)vertexBuffer
 positionAttribute:(GLint)positionAttribute
	colorAttribute:(GLint)colorAttribute;

- (void)draw;
- (void)loadBufferData;
- (size_t)bufferSize;
- (GLsizei)vertexCount;

@end
