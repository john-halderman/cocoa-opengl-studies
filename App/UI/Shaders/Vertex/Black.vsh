#version 150

uniform mat4 projection_matrix, modelview_matrix;

in vec3 vertex;

void main() {
    gl_Position = projection_matrix * modelview_matrix * vec4(vertex, 1.0);
}