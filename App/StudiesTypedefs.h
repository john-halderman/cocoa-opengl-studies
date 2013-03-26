#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>

#define kFailedToInitialiseGLException @"Failed to initialise OpenGL"

typedef struct {
    GLfloat x,y;
} Vector2;

typedef struct {
    GLfloat x,y,z,w;
} Vector4;

typedef struct {
    GLfloat r,g,b,a;
} Color;

typedef struct {
    Vector4 position;
    Color color;
} Vertex;

/*
 GL_INVALID_ENUM
 An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.

 GL_INVALID_VALUE
 A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.

 GL_INVALID_OPERATION
 The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.

 GL_INVALID_FRAMEBUFFER_OPERATION
 The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.

 GL_OUT_OF_MEMORY
 There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.

 GL_STACK_UNDERFLOW
 An attempt has been made to perform an operation that would cause an internal stack to underflow.

 GL_STACK_OVERFLOW
 An attempt has been made to perform an operation that would cause an internal stack to overflow.
 */
void printGlErrors(NSString *locationIndicator) {
	GLenum glError = 0;
	while ((glError = glGetError()) != GL_NO_ERROR) {
		switch (glError) {
			case GL_INVALID_ENUM:
				NSLog(@"================> %@:%@", locationIndicator, @"An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.");
				break;
			case GL_INVALID_VALUE:
				NSLog(@"================> %@:%@", locationIndicator, @"A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag.");
				break;
			case GL_INVALID_OPERATION:
				NSLog(@"================> %@:%@", locationIndicator, @"The specified operation is not allowed in the current state. The offending command is ignored and has no other side effect than to set the error flag.");
				break;
			case GL_INVALID_FRAMEBUFFER_OPERATION:
				NSLog(@"================> %@:%@", locationIndicator, @"The framebuffer object is not complete. The offending command is ignored and has no other side effect than to set the error flag.");
				break;
			case GL_OUT_OF_MEMORY:
				NSLog(@"================> %@:%@", locationIndicator, @"There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded.");
				break;
			case GL_STACK_UNDERFLOW:
				NSLog(@"================> %@:%@", locationIndicator, @"An attempt has been made to perform an operation that would cause an internal stack to underflow.");
				break;
			case GL_STACK_OVERFLOW:
				NSLog(@"================> %@:%@", locationIndicator, @"An attempt has been made to perform an operation that would cause an internal stack to overflow.");
				break;
			default:
				break;
		}
	}
}
