shader_type canvas_item;

uniform int pattern : hint_range(0, 3) = 0; // diamond, circle, square
uniform float threshold : hint_range(0.0, 1.0) = 0.8;
uniform bool inside = false;
uniform float outline_speed = 8.0;
uniform float outline_gap = 24.0;
uniform vec4 outline_colour : source_color = vec4(1.0);
uniform vec4 colour: source_color = vec4(1.0);
uniform float cutoff = 50.0;
uniform float shine_cutoff = 10.0;
uniform float fade = 1.0;

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D source)
{
	float center_alpha = texture(source, uv).a;
	for (float i = -1.0; i <= 1.0; i++)
	{
		float x = abs(i) > 1.0 ? 1.0 * sign(i) : i;
		float offset;

		if (pattern == 0 || pattern == 3)
		{
			offset = 1.0 - abs(x);
		}
		else if (pattern == 1)
		{
			offset = floor(sqrt(pow(1.0 + 0.5, 2) - x * x));
		}
		else if (pattern == 2)
		{
			offset = 1.0;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++)
		{
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			float alpha = texture(source, xy).a;
			if (pattern == 3 && alpha <= threshold && center_alpha > threshold)
			{
				return true;
			}
			else if (pattern != 3 && (xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(source, xy).a <= 0.0) == inside)
			{
				return true;
			}
		}
	}

	return false;
}

void fragment() {
	float t = TIME;

	float pos = (FRAGCOORD.x + FRAGCOORD.y) / outline_gap;

	if (t * outline_speed + pos < cutoff || fade <= 0.0) {
		discard;
	}

	float stepped = sin((t * outline_speed + pos) * 0.125) > 0.0 ? 1.0 : 0.0;

	vec2 shadow_uv = UV + vec2(-1.0) * TEXTURE_PIXEL_SIZE;
	vec4 base = texture(TEXTURE, UV);
	vec4 base_colour = vec4(colour.rgb * base.a, base.a);
	vec4 shadow = texture(TEXTURE, shadow_uv);
	vec4 shadow_colour = vec4(0.0, 0.0, 0.0, shadow.a > 0.5 ? 1.0 : 0.0);
	COLOR = clamp(base_colour + shadow_colour, vec4(0.0), vec4(1.0));

	if (outline_colour.a > 0.0 && t < shine_cutoff && base_colour.a < 0.5 && hasContraryNeighbour(UV, TEXTURE_PIXEL_SIZE, TEXTURE))
	{
		float outline = 1.0 - step(clamp(sin(t * outline_speed + pos), 0.0, 1.0) * stepped, 0.0);
		COLOR = clamp(COLOR + outline * outline_colour, vec4(0.0), vec4(1.0));
	}

	COLOR.a *= fade;
}
