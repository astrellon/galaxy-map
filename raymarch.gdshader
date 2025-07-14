shader_type canvas_item;

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

uniform sampler2D uNoiseTexture: repeat_enable, filter_linear;
uniform mat3 uCameraMatrix;
uniform vec3 uCameraPosition;
uniform float uCameraFov;
uniform float uReveal = 1.0;

float noise3D(vec3 p)
{
    p.z = fract(p.z)*256.0;
    float iz = floor(p.z);
    float fz = fract(p.z);
    vec2 a_off = vec2(23.0, 29.0)*(iz)/256.0;
    vec2 b_off = vec2(23.0, 29.0)*(iz+1.0)/256.0;
    float a = texture(uNoiseTexture, p.xy + a_off, -999.0).r;
    float b = texture(uNoiseTexture, p.xy + b_off, -999.0).r;
    return mix(a, b, fz);
}
float perlinNoise3D(vec3 p)
{
    float x = 0.0;
    for (float i = 0.0; i < 6.0; i += 1.0)
        x += noise3D(p * pow(2.0, i)) * pow(0.5, i);
    return x;
}


float sphereSDF(vec3 samplePoint)
{
    return length(samplePoint) - 1.0;
}

float sceneSDF(vec3 samplePoint)
{
    return sphereSDF(samplePoint);
}

vec3 rayDirection(float fieldOfView, vec2 fragCoord)
{
    vec2 xy = fragCoord / 2.0;
    float z = 2.0 / tan(radians(fieldOfView));
    return normalize(vec3(xy, -z));
}

vec3 estimateNormal(vec3 p)
{
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

/**
 * Lighting contribution of a single point light source via Phong illumination.
 *
 * The vec3 returned is the RGB color of the light's contribution.
 *
 * k_a: Ambient color
 * k_d: Diffuse color
 * k_s: Specular color
 * alpha: Shininess coefficient
 * p: position of point being lit
 * eye: the position of the camera
 * lightPos: the position of the light
 * lightIntensity: color/intensity of the light
 *
 * See https://en.wikipedia.org/wiki/Phong_reflection_model#Description
 */
float quadraticOut(float t) {
	return -t * (t - 2.0);
}
float quadraticIn(float t) {
	return t * t;
}
float cubicIn(float t) {
	return t * t * t;
}
vec3 phongContribForLight(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye, vec3 normal, vec3 lightPos, vec3 lightIntensity)
{
    vec3 L = normalize(lightPos - p);
    vec3 V = normalize(eye - p);
    vec3 R = normalize(reflect(-L, normal));

    float dotLN = dot(L, normal);
    float dotRV = dot(R, V);
	
	dotLN = round(dotLN * 3.0) / 3.0;
	dotRV = round(cubicIn(dotRV) * 0.6);

    if (dotLN < 0.0) {
        // Light not visible from this point on the surface
        return vec3(0.0, 0.0, 0.0);
    }
	
    if (dotRV < 0.0) {
        // Light reflection in opposite direction as viewer, apply only diffuse component
        return lightIntensity * (k_d * dotLN);
    }
    return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
}

/**
 * Lighting via Phong illumination.
 *
 * The vec3 returned is the RGB color of that point after lighting is applied.
 * k_a: Ambient color
 * k_d: Diffuse color
 * k_s: Specular color
 * alpha: Shininess coefficient
 * p: position of point being lit
 * eye: the position of the camera
 *
 * See https://en.wikipedia.org/wiki/Phong_reflection_model#Description
 */
vec3 phongIllumination(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye, vec3 normal)
{
    const vec3 ambientLight = 0.25 * vec3(1.0, 1.0, 1.0);
    vec3 color = ambientLight * k_a;

    vec3 light1Pos = vec3(4.0, 2.0, 4.0);
    vec3 light1Intensity = vec3(0.4, 0.4, 0.4);

    color += phongContribForLight(k_d, k_s, alpha, p, eye, normal, light1Pos, light1Intensity);

    return color;
}

float rayMarch(vec3 rayOrigin, vec3 rayDirection, float near, float far)
{
    float depth = near;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++)
    {
        float dist = sceneSDF(rayOrigin + depth * rayDirection);
        if (dist < EPSILON)
        {
            return depth;
        }

        depth += dist;
        if (depth >= far)
        {
            return far;
        }
    }

    return far;
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment()
{
	vec2 oPosition = UV * 2.0 - 1.0;
	oPosition.y = -oPosition.y;
	
    vec3 rayDir = uCameraMatrix * rayDirection(uCameraFov, oPosition);
    vec3 rayOrigin = uCameraPosition;
	
    float dist = rayMarch(rayOrigin, rayDir, MIN_DIST, MAX_DIST);
    if (dist > MAX_DIST - EPSILON)
    {
        //COLOR = vec4(0, 0, 0, 0);
		discard;
    }
    else
    {
        // The closest point on the surface to the eyepoint along the view ray
        vec3 p = rayOrigin + dist * rayDir;

		float noise = perlinNoise3D(p * 0.0075);
		if (noise > uReveal) {
			discard;
		}
		vec3 K_a = vec3(0.1, 0.1, 0.15);
		vec3 K_d = vec3(0.1, 0.3, 0.95);
		float shininess = 5.0;
		if (noise < 0.95) {
			K_a = vec3(0.1, 0.15, 0.1);
			K_d = vec3(0.3, 0.9, 0.2);
			shininess = 10.0;
		}
        vec3 K_s = vec3(1.0, 1.0, 1.0);

		vec3 normal = estimateNormal(p);
        vec3 litColour = phongIllumination(K_a, K_d, K_s, shininess, p, rayOrigin, normal);
		
		float fresnel = dot(normal, rayDir);
		fresnel = clamp(fresnel + 1.0, 0.0, 1.0);
		
		fresnel = pow(fresnel, 2.5);
		fresnel = round(fresnel * 2.0) / 32.0;
		litColour += fresnel * K_d;

        COLOR = vec4(litColour, 1.0);
		//ALBEDO = litColour;
    }
}

void vertex() {
	// Called for every vertex the material is visible on.
}