shader_type canvas_item;
render_mode unshaded;

void fragment() {
	float fade = clamp(round(((TIME - 2.0) / 3.0) * 3.0) / 3.0, 0.0, 1.0);
	vec4 colour = texture(TEXTURE, UV);
	colour.rgb = colour.rgb * fade;
	COLOR = colour;
}