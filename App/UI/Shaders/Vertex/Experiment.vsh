#version 150

uniform vec2 p;

in vec4 position;
in vec4 color;

out vec4 v_color;
out vec2 v_texCoord2D;
out vec3 v_texCoord3D;

void main (void) {
    v_color = color + vec4(p, p.yx);
	v_texCoord2D = position.xy; //for 2d noise functions
	v_texCoord3D = vec3(position.yx * p, position.z);
//    gl_Position = vec4(p.x, p.y * 0.5, 0.0, 0.0) + position;
	gl_Position = position;
}
