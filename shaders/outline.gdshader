shader_type canvas_item;

// Taken from https://godotshaders.com/shader/2d-outline-inline/
uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 3) = 0; // diamond, circle, square
uniform float threshold : hint_range(0.0, 1.0) = 0.8;
uniform bool inside = false;
uniform bool only_border = false;
uniform bool add_margins = true; // only useful when inside is false

void vertex() 
{
	if (add_margins) 
	{
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D source) 
{
	float center_alpha = texture(source, uv).a;
	for (float i = -ceil(width); i <= ceil(width); i++) 
	{
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		if (pattern == 0 || pattern == 3)
		{
			offset = width - abs(x);
		} 
		else if (pattern == 1) 
		{
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} 
		else if (pattern == 2) 
		{
			offset = width;
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

void fragment() 
{
	vec2 uv = UV;

	if (add_margins) 
	{
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));

		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) 
		{
			COLOR.a = 0.0;
		} 
		else if (!only_border)
		{
			COLOR = texture(TEXTURE, uv);
		}
	}
	else if (!only_border)
	{
		COLOR = texture(TEXTURE, uv);
	}

	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) 
	{
		if (only_border)
		{
			COLOR = color;
		}
		else
		{
			COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
			COLOR.a += (1.0 - COLOR.a) * color.a;
		}
	}
	else if (only_border)
	{
		discard;
	}
}