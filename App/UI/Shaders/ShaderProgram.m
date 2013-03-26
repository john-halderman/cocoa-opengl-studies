#import "ShaderProgram.h"
#import "Study.h"
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <OpenGL/glu.h>

@interface ShaderProgram ()

@property (assign, nonatomic) GLuint shaderProgram;
@property (assign, nonatomic) GLint positionUniform;
@property (assign, nonatomic, readwrite) GLint colorAttribute;
@property (assign, nonatomic, readwrite) GLint positionAttribute;

@property (assign, nonatomic) int *perm, (*grad3)[16][3], (*grad4)[32][4];
@property (assign, nonatomic) unsigned char (*simplex4)[][4];

@property (assign, nonatomic) GLuint permTextureID;
@property (assign, nonatomic) GLuint simplexTextureID;
@property (assign, nonatomic) GLuint gradTextureID;

@property (assign, nonatomic) GLint permTexture;
@property (assign, nonatomic) GLint simplexTexture;
@property (assign, nonatomic) GLint gradTexture;
@property (assign, nonatomic) GLint noiseTime;

@end

@implementation ShaderProgram

- (void)dealloc {
	glDeleteProgram(self.shaderProgram);
    printGlErrors(@"delete program");

	[super dealloc];
}

- (id)init {
	if (self = [super init]) {
		int perm[256] = {
			151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,
			142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,
			203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,
			175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,
			230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,
			209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,
			198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,
			212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,
			2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,
			79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,
			12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,
			106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,
			114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
		};

		self.perm = perm;

		/* These are Ken Perlin's proposed gradients for 3D noise. I kept them for
		 better consistency with the reference implementation, but there is really
		 no need to pad this to 16 gradients for this particular implementation.
		 If only the "proper" first 12 gradients are used, they can be extracted
		 from the grad4[][] array: grad3[i][j] == grad4[i*2][j], 0<=i<=11, j=0,1,2
		 */
		int grad3[16][3] = {
			{0,1,1},{0,1,-1},{0,-1,1},{0,-1,-1},
			{1,0,1},{1,0,-1},{-1,0,1},{-1,0,-1},
			{1,1,0},{1,-1,0},{-1,1,0},{-1,-1,0}, // 12 cube edges
			{1,0,-1},{-1,0,-1},{0,-1,1},{0,1,1}  // 4 more to make 16
		};

		self.grad3 = &grad3;

		/* These are my own proposed gradients for 4D noise. They are the coordinates
		 of the midpoints of each of the 32 edges of a tesseract, just like the 3D
		 noise gradients are the midpoints of the 12 edges of a cube.
		 */
		int grad4[32][4] = {
			{0,1,1,1}, {0,1,1,-1}, {0,1,-1,1}, {0,1,-1,-1}, // 32 tesseract edges
			{0,-1,1,1}, {0,-1,1,-1}, {0,-1,-1,1}, {0,-1,-1,-1},
			{1,0,1,1}, {1,0,1,-1}, {1,0,-1,1}, {1,0,-1,-1},
			{-1,0,1,1}, {-1,0,1,-1}, {-1,0,-1,1}, {-1,0,-1,-1},
			{1,1,0,1}, {1,1,0,-1}, {1,-1,0,1}, {1,-1,0,-1},
			{-1,1,0,1}, {-1,1,0,-1}, {-1,-1,0,1}, {-1,-1,0,-1},
			{1,1,1,0}, {1,1,-1,0}, {1,-1,1,0}, {1,-1,-1,0},
			{-1,1,1,0}, {-1,1,-1,0}, {-1,-1,1,0}, {-1,-1,-1,0}
		};

		self.grad4 = &grad4;

		/* This is a look-up table to speed up the decision on which simplex we
		 are in inside a cube or hypercube "cell" for 3D and 4D simplex noise.
		 It is used to avoid complicated nested conditionals in the GLSL code.
		 The table is indexed in GLSL with the results of six pair-wise
		 comparisons beween the components of the P=(x,y,z,w) coordinates
		 within a hypercube cell.
		 c1 = x>=y ? 32 : 0;
		 c2 = x>=z ? 16 : 0;
		 c3 = y>=z ? 8 : 0;
		 c4 = x>=w ? 4 : 0;
		 c5 = y>=w ? 2 : 0;
		 c6 = z>=w ? 1 : 0;
		 offsets = simplex[c1+c2+c3+c4+c5+c6];
		 o1 = step(160,offsets);
		 o2 = step(96,offsets);
		 o3 = step(32,offsets);
		 (For the 3D case, c4, c5, c6 and o3 are not needed.)
		 */
		unsigned char simplex4[][4] = {
			{0,64,128,192},{0,64,192,128},{0,0,0,0},{0,128,192,64},
			{0,0,0,0},{0,0,0,0},{0,0,0,0},{64,128,192,0},
			{0,128,64,192},{0,0,0,0},{0,192,64,128},{0,192,128,64},
			{0,0,0,0},{0,0,0,0},{0,0,0,0},{64,192,128,0},
			{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
			{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
			{64,128,0,192},{0,0,0,0},{64,192,0,128},{0,0,0,0},
			{0,0,0,0},{0,0,0,0},{128,192,0,64},{128,192,64,0},
			{64,0,128,192},{64,0,192,128},{0,0,0,0},{0,0,0,0},
			{0,0,0,0},{128,0,192,64},{0,0,0,0},{128,64,192,0},
			{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
			{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
			{128,0,64,192},{0,0,0,0},{0,0,0,0},{0,0,0,0},
			{192,0,64,128},{192,0,128,64},{0,0,0,0},{192,64,128,0},
			{128,64,0,192},{0,0,0,0},{0,0,0,0},{0,0,0,0},
			{192,64,0,128},{0,0,0,0},{192,128,0,64},{192,128,64,0}
		};

		self.simplex4 = &simplex4;

		[self initTexturesForNoise];
		[self loadShader];
	}
	return self;
}

- (void)initTexturesForNoise {
	[self initPermTexture:&_permTextureID];
	[self initSimplexTexture:&_simplexTextureID];
	[self initGradTexture:&_gradTextureID];
}

- (void)bindShaderForTime:(GLfloat)time {
	glUseProgram(self.shaderProgram);
	printGlErrors(@"glUseProgram");

	Vector2 p = { .x = 0.5f * sinf(time), .y = 0.5f * cosf(time) };
	//	NSLog(@"================> %.5f, %.5f", p.x, p.y);
	glUniform2fv(self.positionUniform, 1, (const GLfloat *)&p);
	printGlErrors(@"glUniform2fv(positionUniform)");

	if(self.noiseTime > 0 ) {
		glUniform1f( self.noiseTime, time );
		printGlErrors(@"glUniform1f(noiseTime)");
	}

	if( self.permTexture > 0 ) {
  		glUniform1i( self.permTexture, self.permTextureID ); // Texture unit 0
		printGlErrors(@"glUniform1i(permTexture)");
	}

	if( self.simplexTexture > 0 ) {
  		glUniform1i( self.simplexTexture, self.simplexTextureID ); // Texture unit 1
		printGlErrors(@"glUniform1i(simplexTexture)");
	}

	if( self.gradTexture > 0 ) {
  		glUniform1i( self.gradTexture, self.gradTextureID ); // Texture unit 2
		printGlErrors(@"glUniform1i(gradTexture)");
	}
}

//- (void)bindSize:(GLfloat)size {
//	GLint sizeUniform = glGetUniformLocation(self.shaderProgram, "size");
//	printGlErrors(@"glGetUniformLocation(size)");
//
//	if (sizeUniform < 0) {
//		[NSException raise:kFailedToInitialiseGLException format:@"Shader did not contain the 'size' uniform."];
//	}
//}

- (void)loadShader {
    GLuint vertexShader = 0;
    GLuint fragmentShader = 0;

    vertexShader   = [self compileShaderOfType:GL_VERTEX_SHADER   file:[[NSBundle mainBundle] pathForResource:@"Experiment" ofType:@"vsh"]];
    fragmentShader = [self compileShaderOfType:GL_FRAGMENT_SHADER file:[[NSBundle mainBundle] pathForResource:@"Experiment" ofType:@"fsh"]];

    if (0 != vertexShader && 0 != fragmentShader) {
        self.shaderProgram = glCreateProgram();
        printGlErrors(@"glCreateProgram");

        glAttachShader(self.shaderProgram, vertexShader  );
        printGlErrors(@"glAttachShader(vertexShader)");

        glAttachShader(self.shaderProgram, fragmentShader);
        printGlErrors(@"glAttachShader(fragmentShader)");

        glBindFragDataLocation(self.shaderProgram, 0, "fragColor");

        [self linkProgram:self.shaderProgram];

        self.positionUniform = glGetUniformLocation(self.shaderProgram, "p");
		printGlErrors(@"glGetUniformLocation(p)");

        if (self.positionUniform < 0) {
            [NSException raise:kFailedToInitialiseGLException format:@"Shader did not contain the 'p' uniform."];
        }

        self.colorAttribute = glGetAttribLocation(self.shaderProgram, "color");
        printGlErrors(@"glGetAttribLocation(color)");

        if (self.colorAttribute < 0) {
            [NSException raise:kFailedToInitialiseGLException format:@"Shader did not contain the 'color' attribute."];
        }

        self.positionAttribute = glGetAttribLocation(self.shaderProgram, "position");
        printGlErrors(@"glGetAttribLocation(position)");

        if (self.positionAttribute < 0) {
            [NSException raise:kFailedToInitialiseGLException format:@"Shader did not contain the 'position' attribute."];
        }

		// Locate the uniform shader variables so we can set them later:
		// a texture ID ("permTexture") and a float ("time").
		self.permTexture = glGetUniformLocation(self.shaderProgram, "permTexture");
		printGlErrors(@"glGetUniformLocation(permTexture)");
		//		if(self.permTexture < 0) {
		//			printError("Binding error","Failed to locate uniform variable 'permTexture'.");
		//		}

		self.simplexTexture = glGetUniformLocation(self.shaderProgram, "simplexTexture");
		printGlErrors(@"glGetUniformLocation(simpleTexture)");
		//		if(location_simplexTexture < 0) {
		//			printError("Binding error","Failed to locate uniform variable 'simplexTexture'.");
		//		}

		self.gradTexture = glGetUniformLocation( self.shaderProgram, "gradTexture");
		printGlErrors(@"glGetUniformLocation(gradTexture)");
		//		if(location_gradTexture < 0) {
		//			printError("Binding error","Failed to locate uniform variable 'gradTexture'.");
		//		}

		self.noiseTime = glGetUniformLocation(self.shaderProgram, "time");
		printGlErrors(@"glGetUniformLocation(time)");
		//		if(self.noiseTime == -1) {
		//			printError("Binding error", "Failed to locate uniform variable 'time'.");
		//		}

        glDeleteShader(vertexShader);
        printGlErrors(@"glDeleteShader(vertexShader)");

        glDeleteShader(fragmentShader);
		printGlErrors(@"glDeleteShader(fragmentShader)");
    } else {
        [NSException raise:kFailedToInitialiseGLException format:@"Shader compilation failed."];
    }
}

- (NSArray *)preprocessShaderSource:(NSString *)sourceFile {
	NSMutableArray *preprocessedShaderArray = [NSMutableArray array];
	NSString *pattern = @"#import \"(.*)\"";
	NSRegularExpression *validator = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

	[[NSString stringWithContentsOfFile:sourceFile encoding:NSASCIIStringEncoding error:nil] enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		NSTextCheckingResult *match = [validator firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];

		if (match) {
			NSString *importSourceFileName = [line substringWithRange:[match rangeAtIndex:1]];
			NSString *importSourceFile = [[NSBundle mainBundle] pathForResource:[importSourceFileName stringByDeletingPathExtension] ofType:[importSourceFileName pathExtension]];
			[preprocessedShaderArray addObjectsFromArray:[self preprocessShaderSource:importSourceFile]];
		} else {
			[preprocessedShaderArray addObject:line];
		}
	}];

	return preprocessedShaderArray;
}

- (GLuint)compileShaderOfType:(GLenum)type file:(NSString *)file {
    GLuint shader = 0;

    const GLchar *source = (GLchar *)[[[self preprocessShaderSource:file] componentsJoinedByString:@"\n"] cStringUsingEncoding:NSASCIIStringEncoding];

	//	NSLog(@"================> %s", source);

    if (nil == source) {
        [NSException raise:kFailedToInitialiseGLException format:@"Failed to read shader file %@", file];
    }

    shader = glCreateShader(type);
	//	NSLog(@"================> %d", shader);
    printGlErrors([NSString stringWithFormat:@"glCreateShader(%d)", type]);

    glShaderSource(shader, 1, &source, NULL);
	printGlErrors([NSString stringWithFormat:@"glShaderSource(%@)", file]);

    glCompileShader(shader);
    printGlErrors([NSString stringWithFormat:@"glCompileShader(%@)", file]);

#if defined(DEBUG)
    GLint logLength = 0;

    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    printGlErrors([NSString stringWithFormat:@"glGetShaderiv(%@)", file]);

    if (logLength > 0) {
        GLchar *log = malloc((size_t)logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        printGlErrors([NSString stringWithFormat:@"glShaderInfoLog(%@)", file]);

        NSLog(@"Shader compilation failed with error:\n%s", log);
		NSLog(@"================> %d", logLength);
        free(log);
    }
#endif

    GLint status = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    printGlErrors([NSString stringWithFormat:@"glGetShaderiv(%@)", file]);

    if (GL_FALSE == status) {
		NSLog(@"================> %d", status);

        glDeleteShader(shader);
        printGlErrors([NSString stringWithFormat:@"glDeleteShader(%@)", file]);

        [NSException raise:kFailedToInitialiseGLException format:@"Shader compilation failed for file %@", file];
    }

    return shader;
}

- (void)linkProgram:(GLuint)program
{
    glLinkProgram(program);
    printGlErrors([NSString stringWithFormat:@"glLinkProgram(%d)", program]);

#if defined(DEBUG)
    GLint logLength;

    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    printGlErrors([NSString stringWithFormat:@"glGetProgramiv(%d)", program]);

    if (logLength > 0) {
        GLchar *log = malloc((size_t)logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        printGlErrors([NSString stringWithFormat:@"glGetProgramInfoLog(%d)", program]);

        NSLog(@"Shader program linking failed with error:\n%s", log);
        free(log);
    }
#endif

    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
	printGlErrors([NSString stringWithFormat:@"glGetProgramiv(%d)", program]);

    if (0 == status) {
        [NSException raise:kFailedToInitialiseGLException format:@"Failed to link shader program"];
    }
}

- (void)validateProgram:(GLuint)program {
    GLint logLength;

    glValidateProgram(program);
    printGlErrors([NSString stringWithFormat:@"glValidateProgram(%d)", program]);

    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    printGlErrors([NSString stringWithFormat:@"glGetProgramiv(%d)", program]);

    if (logLength > 0) {
        GLchar *log = malloc((size_t)logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        printGlErrors([NSString stringWithFormat:@"glGetProgramInfoLog(%d)", program]);

        NSLog(@"Program validation produced errors:\n%s", log);
        free(log);
    }

    GLint status;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    printGlErrors([NSString stringWithFormat:@"glGetProgramiv(%d)", program]);

    if (0 == status) {
        [NSException raise:kFailedToInitialiseGLException format:@"Failed to link shader program"];
    }
}

/*
 * initPermTexture(GLuint *texID) - create and load a 2D texture for
 * a combined index permutation and gradient lookup table.
 * This texture is used for 2D and 3D noise, both classic and simplex.
 */
- (void)initPermTexture:(GLuint *)textureID {
	char *pixels;
	int i,j;

	glGenTextures(1, textureID); // Generate a unique texture ID
	glBindTexture(GL_TEXTURE_2D, *textureID); // Bind the texture to texture unit 0

	pixels = (char*)malloc( 256 * 256 * 4 );
	for(i = 0; i<256; i++)
		for(j = 0; j<256; j++) {
			int offset = (i * 256 + j) * 4;

			char value = self.perm[(j+self.perm[i]) & 0xFF];
			pixels[offset] = (*_grad3)[value & 0x0F][0] * 64 + 64;   // Gradient x
			pixels[offset+1] = (*_grad3)[value & 0x0F][1] * 64 + 64; // Gradient y
			pixels[offset+2] = (*_grad3)[value & 0x0F][2] * 64 + 64; // Gradient z
			pixels[offset+3] = value;                     // Permuted index
		}

	// GLFW texture loading functions won't work here - we need GL_NEAREST lookup.
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
}

/*
 * initSimplexTexture(GLuint *texID) - create and load a 1D texture for a
 * simplex traversal order lookup table. This is used for simplex noise only,
 * and only for 3D and 4D noise where there are more than 2 simplices.
 * (3D simplex noise has 6 cases to sort out, 4D simplex noise has 24 cases.)
 */
- (void)initSimplexTexture:(GLuint *)textureID {
	glActiveTexture(GL_TEXTURE1); // Activate a different texture unit (unit 1)

	glGenTextures(1, textureID); // Generate a unique texture ID
	glBindTexture(GL_TEXTURE_1D, *textureID); // Bind the texture to texture unit 1

	// GLFW texture loading functions won't work here - we need GL_NEAREST lookup.
	glTexImage1D( GL_TEXTURE_1D, 0, GL_RGBA, 64, 0, GL_RGBA, GL_UNSIGNED_BYTE, self.simplex4);
	glTexParameteri( GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );

	glActiveTexture(GL_TEXTURE0); // Switch active texture unit back to 0 again
}

/*
 * initGradTexture(GLuint *texID) - create and load a 2D texture
 * for a 4D gradient lookup table. This is used for 4D noise only.
 */
- (void)initGradTexture:(GLuint *)textureID {
	char *pixels;
	int i,j;

	glActiveTexture(GL_TEXTURE2); // Activate a different texture unit (unit 2)

	glGenTextures(1, textureID); // Generate a unique texture ID
	glBindTexture(GL_TEXTURE_2D, *textureID); // Bind the texture to texture unit 2

	pixels = (char*)malloc( 256*256*4 );
	for(i = 0; i<256; i++)
		for(j = 0; j<256; j++) {
			int offset = (i*256+j)*4;
			char value = self.perm[(j+self.perm[i]) & 0xFF];
			pixels[offset] = (*_grad4)[value & 0x1F][0] * 64 + 64;   // Gradient x
			pixels[offset+1] = (*_grad4)[value & 0x1F][1] * 64 + 64; // Gradient y
			pixels[offset+2] = (*_grad4)[value & 0x1F][2] * 64 + 64; // Gradient z
			pixels[offset+3] = (*_grad4)[value & 0x1F][3] * 64 + 64; // Gradient z
		}

	// GLFW texture loading functions won't work here - we need GL_NEAREST lookup.
	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );

	glActiveTexture(GL_TEXTURE0); // Switch active texture unit back to 0 again
}

@end
