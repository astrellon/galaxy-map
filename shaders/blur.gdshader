shader_type canvas_item;
// Taken from: https://godotshaders.com/shader/gaussian-blur-2/

uniform float alpha_bump: hint_range(0.0, 5.0) = 1.0;
uniform float sigma: hint_range(0.1, 20.0) = 3.3; // Limited to 20 because of performance, if you want feel free to break it.

float gaussianDistribution(float x, float STD){ // STD stands for standard deviation
	return exp(-(x*x)/(2.*STD*STD))/(sqrt(2.*PI)*STD);
}

vec4 gaussianblur(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigmaUsed, int radius){
    vec4 blurredPixel = vec4(0.0);
    float total_weight = 0.0;
	// Loop over the radius (tecnically its a square)
    for(int i = -radius ; i <= radius; i++){
        for(int j = -radius; j <= radius; j++){
			// Calculate the offset from the current pixel
			vec2 offset = vec2(float(i), float(j))*pixel_size;
			vec2 changedPos = pos + offset;

			// Calculate the weight based on the Gaussian distribution multiplying both dimentions (how far are X and Y form the center (pos))
			float weight = gaussianDistribution(float(i), sigmaUsed)*gaussianDistribution(float(j), sigmaUsed);
			// Add the weighted color value to the blurred pixel
			blurredPixel += texture(sampler, changedPos) * weight;
			total_weight += weight;
        }
    }
	// Normalize the blurred pixel color by the total weight
	blurredPixel/=total_weight;
    return blurredPixel;
}
void fragment() {
	vec4 base = texture(TEXTURE, UV);
    vec4 PixelBlurred = gaussianblur(TEXTURE, UV, TEXTURE_PIXEL_SIZE, sigma, int(round(3.0 * sigma)));
	PixelBlurred.a *= alpha_bump;
    // The radius is 3*Sigma because it is the point where the Gaussian weight is near zero.
    COLOR = PixelBlurred + base;
}