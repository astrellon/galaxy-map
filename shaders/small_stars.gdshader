shader_type canvas_item;

uniform sampler2D uTexture;
uniform float uIndexTime = 0.5;
uniform float uTimeOffset = -3.0;
varying vec4 vertex_colour;
varying float instance_id;

void vertex() {
	vertex_colour = COLOR;
	instance_id = float(INSTANCE_ID);
}

void fragment() {
	float t = mod(TIME, 30.0);
	int unclamped_index = int((t + uTimeOffset - instance_id * 0.05) / uIndexTime);
	
	int min_index = TIME > 29.0 ? 1 : 0;
	int index = clamp(unclamped_index, min_index, 11);
	
	vec2 uv = (vec2(float(index), 0.0) + UV) * vec2(1.0 / 12.0, 1.0);
	vec4 colour = texture(uTexture, uv);
	COLOR = colour * vertex_colour;
}
