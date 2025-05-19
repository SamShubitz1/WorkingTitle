shader_type canvas_item;

uniform vec2 viewport_size;
uniform float line_spacing = 5.0;
uniform float line_strength = 0.01;

void fragment() {
    float y = SCREEN_UV.y * viewport_size.y;
    float x = SCREEN_UV.x * viewport_size.x;

    // Horizontal line: every other line_spacing rows
    float horizontal_line = mod(floor(y / line_spacing), 2.0);

    // Vertical line: every other line_spacing columns
    float vertical_line = mod(floor(x / line_spacing), 1.0);

    // Combine horizontal and vertical lines (if either is 1, show line)
    float line = max(horizontal_line, vertical_line);

    COLOR = vec4(0.0, 0.0, 0.0, line * line_strength);
}