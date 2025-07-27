shader_type canvas_item;

uniform sampler2D uTexture : repeat_enable, filter_nearest;
uniform vec2 uAlphaRange = vec2(0.05, 1.0);

void fragment() {
	vec4 base_colour = texture(TEXTURE, UV);
	float texture_u = SCREEN_UV.x * (455.0 / 256.0) + SCREEN_UV.y;
	vec2 texture_uv = vec2(texture_u + TIME * 0.1);
	vec4 texture_colour = texture(uTexture, texture_uv);
	//if (texture_colour.x < 0.01)
	//{
		//discard;
	//}
	
	COLOR = vec4(texture_colour.rgb, max(uAlphaRange.x, base_colour.a * texture_colour.a * uAlphaRange.y));
	//COLOR = vec4(vec3(1), uAlphaRange.x);
	// Called for every pixel the material is visible on.
}
