#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>

@interface Scene : NSObject

- (void)render;
- (void)advanceTimeBy:(GLfloat)seconds;

@end
