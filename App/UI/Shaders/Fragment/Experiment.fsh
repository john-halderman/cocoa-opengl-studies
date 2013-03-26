#version 150

in vec4 v_color;
in vec2 v_texCoord2D;
in vec3 v_texCoord3D;

out vec4 fragColor;

#import "Noise.glsl"
//declares time

void main(void) {
	/* These lines test, in order, 2D classic noise, 2D simplex noise,
	 * 3D classic noise, 3D simplex noise, 4D classic noise, and finally
	 * 4D simplex noise.
	 * Everything but the 4D simpex noise will make some uniform
	 * variables remain unused and be optimized away by the compiler,
	 * so OpenGL will fail to bind them. It's safe to ignore these
	 * warnings from the C program. The program is designed to work anyway.
	 */
	v_texCoord2D;

	//float n = noise(v_texCoord2D * 32.0 + 240.0);
	//float n = snoise(v_texCoord2D * 16.0);
	//float n = noise(vec3(4.0 * v_texCoord3D.xyz * (2.0 + sin(0.5 * time))));
	//float n = snoise(vec3(2.0 * v_texCoord3D.xyz * (2.0 + sin(0.5 * time))));
	//float n = noise(vec4(8.0 * v_texCoord3D.xyz, 0.5 * time));
	float n = snoise(vec4(snoise(vec4(sin(18.0 * v_texCoord3D.x + time), cos(18.0 * v_texCoord3D.y + time), cos(18.0 * v_texCoord3D.z + time), 0.5 * time))));

	fragColor = v_color * vec4(0.5 + 0.5 * vec3(0.99 * sin(n + time), 0.99 * sin(n - time), 0.99 * clamp(sin(n), 0.f, 1.f)), n);
}
