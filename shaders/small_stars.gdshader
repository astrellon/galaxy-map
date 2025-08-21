shader_type canvas_item;

uniform sampler2D uTexture;
uniform float uIndexTime = 0.5;
uniform float uTimeOffset = -3.0;
uniform float uLoopTime = 30.0;
uniform float uTimeBetweenInstances = 0.05;
varying vec4 vertex_colour;
varying float instance_id;

void vertex() {
	vertex_colour = COLOR;
	instance_id = float(INSTANCE_ID);
}

void fragment() {
	float t = TIME;
	if (uLoopTime > 0.0) {
		t = mod(TIME, uLoopTime);
	}
	else {
		t = clamp(TIME, 0.0, 30.0);
	}
	int unclamped_index = int((t + uTimeOffset - instance_id * uTimeBetweenInstances) / uIndexTime);

	int min_index = TIME > 29.0 ? 1 : 0;
	int index = clamp(unclamped_index, min_index, 11);

	vec2 uv = (vec2(float(index), 0.0) + UV) * vec2(1.0 / 12.0, 1.0);
	vec4 colour = texture(uTexture, uv);
	COLOR = colour * vertex_colour;
}
