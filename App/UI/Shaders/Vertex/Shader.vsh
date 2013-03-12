#version 150

uniform vec2 p;

in vec4 position;
in vec4 color;

out vec4 v_color;

void main (void) {
    v_color = color;
    gl_Position = vec4(p, 0.0, 0.0) + position;
}
