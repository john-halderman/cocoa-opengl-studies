#import <Foundation/Foundation.h>

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

static const GLuint kPositionSize = 4;
static const GLuint kColorSize = 4;

typedef struct {
    Vector4 position;
    Color color;
} Vertex;

void printGlErrors(NSString *locationIndicator);

@interface Study : NSObject

@end
