shader_type canvas_item;
render_mode unshaded;

uniform float glow = 1.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb *= glow;
}
