#import <Foundation/Foundation.h>

@interface ShaderProgram : NSObject

@property (assign, nonatomic, readonly) GLint colorAttribute;
@property (assign, nonatomic, readonly) GLint positionAttribute;

- (void)bindShaderForTime:(GLfloat)time;
//- (void)bindSize:(GLfloat)size;

@end
