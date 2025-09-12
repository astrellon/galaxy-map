shader_type canvas_item;
render_mode unshaded;

uniform sampler2D uTexture : repeat_enable, filter_nearest;
uniform vec2 uAlphaRange = vec2(0.05, 1.0);
uniform float uTimeOffset = -3.0;

void fragment() {
	if (TIME < uTimeOffset) {
		discard;
	}
	
	float fade = clamp(TIME - uTimeOffset, 0.0, 1.0);
	vec4 base_colour = texture(TEXTURE, UV);
	float texture_u = SCREEN_UV.x * (455.0 / 256.0) + SCREEN_UV.y;
	vec2 texture_uv = vec2(texture_u + TIME * 0.1);
	vec4 texture_colour = texture(uTexture, texture_uv);
	
	COLOR = vec4(texture_colour.rgb, max(uAlphaRange.x, base_colour.a * texture_colour.a * uAlphaRange.y) * fade);
}
