shader_type canvas_item;

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.00001;
const float PLANET = 1.0;
const float CLOUD = 2.0;
const float RING = 3.0;

uniform sampler2D uNoiseTexture: repeat_enable, filter_linear;
uniform sampler2D uPlanetTexture: repeat_disable, filter_nearest;
uniform mat3 uCameraMatrix;
uniform vec3 uCameraPosition;
uniform float uCameraFov;
uniform float uReveal = 1.0;

uniform vec3 uPlanetNoiseScale = vec3(1.0);
uniform vec3 uPlanetNoiseOffset = vec3(0.0);
uniform vec3 uRingParams = vec3(1.1, 0.75, 0.015);
uniform bvec4 uFlags = bvec4(false);

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
	{
		x += noise3D(p * pow(2.0, i)) * pow(0.5, i);
	}
    return x;
}

float opOnion(float sdf, float thickness)
{
	return abs(sdf) - thickness;
}

float opSubtraction(float d1, float d2)
{
	return max(-d1, d2);
}

float opIntersection(float d1, float d2)
{
	return max(d1, d2);
}

float sdfSphere(vec3 samplePoint, float radius)
{
    return length(samplePoint) - radius;
}

float sdfCappedCylinder(vec3 point, float height, float radius)
{
    vec2 d = abs(vec2(length(point.xz), point.y)) - vec2(radius, height);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdfCutHollowSphere(vec3 point, float radius, float cutoff, float thickness)
{
    vec2 q = vec2(length(point.xz), point.y);
    float w = sqrt(radius * radius - cutoff * cutoff);
    
    return ((cutoff * q.x < w * q.y) ? 
		length(q - vec2(w, cutoff)) : 
        abs(length(q) - radius)) - thickness;
}

float cloudScene(vec3 samplePoint)
{
	if (!uFlags.x)
	{
		return 100.0;
	}
	
	float outerSphere = sdfSphere(samplePoint, 0.7);
	float innerSphere = sdfSphere(samplePoint, 0.6);
	float cloudDist = outerSphere + (perlinNoise3D(samplePoint * 0.0175 + vec3(0.12)) - 0.85) * 0.3;
	
	return opSubtraction(cloudDist, innerSphere);
}

float planetScene(vec3 samplePoint)
{
	if (!uFlags.y)
	{
		return 100.0;
	}
	return sdfSphere(samplePoint, 0.5);
}

float ringScene(vec3 samplePoint)
{
	if (!uFlags.z)
	{
		return 100.0;
	}
	
	return opSubtraction(
		sdfCappedCylinder(samplePoint, uRingParams.z + 1.0, uRingParams.y),
		sdfCappedCylinder(samplePoint, uRingParams.z, uRingParams.x));
}

vec2 objMin(vec2 d1, vec2 d2)
{
	return d1.x < d2.x ? d1 : d2;
}

vec2 sceneSDF(vec3 samplePoint)
{
	vec2 sphereDist = vec2(planetScene(samplePoint), PLANET);
	vec2 cloudDist = vec2(cloudScene(samplePoint), CLOUD);
	vec2 ringDist = vec2(ringScene(samplePoint), RING);
	
	return objMin(sphereDist, objMin(cloudDist, ringDist));
}

vec3 rayDirection(float fieldOfView, vec2 fragCoord)
{
    vec2 xy = fragCoord / 2.0;
    float z = 2.0 / tan(radians(fieldOfView));
    return normalize(vec3(xy, -z));
}

vec3 estimateNormalPlanet(vec3 point, float currentDepth)
{
    vec2 eps_zero = vec2(currentDepth * 0.0015, 0.0);
    return normalize(vec3(
        planetScene(point + eps_zero.xyy) - planetScene(point - eps_zero.xyy),
        planetScene(point + eps_zero.yxy) - planetScene(point - eps_zero.yxy),
        planetScene(point + eps_zero.yyx) - planetScene(point - eps_zero.yyx)
    ));
}
vec3 estimateNormalCloud(vec3 point, float currentDepth)
{
    vec2 eps_zero = vec2(currentDepth * 0.0015, 0.0);
    return normalize(vec3(
        cloudScene(point + eps_zero.xyy) - cloudScene(point - eps_zero.xyy),
        cloudScene(point + eps_zero.yxy) - cloudScene(point - eps_zero.yxy),
        cloudScene(point + eps_zero.yyx) - cloudScene(point - eps_zero.yyx)
    ));
}
vec3 estimateNormalRing(vec3 point, float currentDepth)
{
    vec2 eps_zero = vec2(currentDepth * 0.0015, 0.0);
    return normalize(vec3(
        ringScene(point + eps_zero.xyy) - ringScene(point - eps_zero.xyy),
        ringScene(point + eps_zero.yxy) - ringScene(point - eps_zero.yxy),
        ringScene(point + eps_zero.yyx) - ringScene(point - eps_zero.yyx)
    ));
}

float quadraticOut(float t) {
	return -t * (t - 2.0);
}
float quadraticIn(float t) {
	return t * t;
}
float cubicIn(float t) {
	return t * t * t;
}
float phongContribForLight(float alpha, vec3 point, vec3 eye, vec3 normal, vec3 lightPos)
{
    vec3 L = normalize(lightPos - point);
    vec3 V = normalize(eye - point);
    vec3 R = normalize(reflect(-L, normal));

    float dotLN = dot(L, normal);
    float dotRV = dot(R, V);
	
	//dotLN = round(dotLN * 3.0) / 3.0;
	//dotLN = round(dotLN);
	//dotRV = round(cubicIn(dotRV) * 0.6);

    if (dotLN < 0.0) 
	{
        // Light not visible from this point on the surface
        //return vec3(0.0, 0.0, 0.0);
		return 0.0;
    }
	
    if (dotRV < 0.0)
	{
        // Light reflection in opposite direction as viewer, apply only diffuse component
        return dotLN;
    }
    return dotLN + pow(dotRV, alpha);
}

const float shadowSharpness = 128.0;
float softShadow(vec3 rayOrigin, vec3 rayDirection, float near, float far)
{
    float depth = near;
    float result = 1.0;
    int i = 0;

    for (; i < MAX_MARCHING_STEPS; i++)
    {
        float dist = sceneSDF(rayOrigin + depth * rayDirection).x;
        if (dist < EPSILON)
        {
            return 0.0;
        }

        result = min(result, shadowSharpness * dist / depth);
        depth += dist;
        if (depth >= far)
        {
            return result;
        }
    }

    return result;
}

float phongIllumination(float currentDepth, float alpha, vec3 point, vec3 eye, vec3 normal, float minDepth)
{
    const vec3 lightPos = vec3(-4.0, 1.5, 4.0);
	vec3 toLight = normalize(lightPos - point);
	
	float shadow = softShadow(point, toLight, minDepth * currentDepth, 100.0);
    return phongContribForLight(alpha, point, eye, normal, lightPos) * shadow;
}

vec2 rayMarch(vec3 rayOrigin, vec3 rayDirection, float near, float far)
{
    float depth = near;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++)
    {
        vec2 dist = sceneSDF(rayOrigin + depth * rayDirection);
        if (dist.x < EPSILON)
        {
            return vec2(depth, dist.y);
        }

        depth += dist.x * 0.5;
        if (depth >= far)
        {
            return vec2(far, 0.0);
        }
    }

    return vec2(far, 0.0);
}

bool approxEquals(float x, float y)
{
	return abs(x - y) < EPSILON;
}

void fragment()
{
	vec2 oPosition = UV * 2.0 - 1.0;
	oPosition.y = -oPosition.y;
	
    vec3 rayDir = uCameraMatrix * rayDirection(uCameraFov, oPosition);
    vec3 rayOrigin = uCameraPosition;
	
    vec2 dist = rayMarch(rayOrigin, rayDir, MIN_DIST, MAX_DIST);
    if (dist.x > MAX_DIST - EPSILON)
    {
		discard;
    }
    else
    {
        // The closest point on the surface to the eyepoint along the view ray
        vec3 p = rayOrigin + dist.x * rayDir;
		
		float noise = perlinNoise3D(p * 0.0075 * uPlanetNoiseScale + uPlanetNoiseOffset) - 0.6;
		if (noise > uReveal) 
		{
			discard;
		}
		
		if (approxEquals(dist.y, PLANET))
		{
			vec3 normal = estimateNormalPlanet(p, dist.x);
        	float lighting = clamp(phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.001), 0.0, 1.0);
			float fresnel = dot(normal, rayDir);
			fresnel = clamp(fresnel + 1.0, 0.0, 1.0);
			
			fresnel = pow(fresnel, 2.5);
			fresnel = round(fresnel * 2.0);
			lighting = max(lighting, fresnel * 0.5);
			
			vec3 planetColour = texture(uPlanetTexture, vec2(noise, 1.2 - lighting)).rgb;
			
	        COLOR = vec4(planetColour, 1.0);
		}
		else if (approxEquals(dist.y, CLOUD))
		{
			vec3 normal = estimateNormalCloud(p, dist.x);
        	float lighting = phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.001) * 0.5 + 0.5;
			COLOR = vec4(vec3(lighting), 1.0);
		}
		else if (approxEquals(dist.y, RING))
		{
			vec3 normal = estimateNormalRing(p, dist.x);
			normal.y = abs(normal.y);
        	float lighting = phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.1) / 2.0;
			float dist = sin(length(p) * 50.0) * 0.2 + 0.7;
			COLOR = vec4(vec3(dist * lighting * vec3(0.7, 0.3, 0.2)), 1.0);
		}
    }
}
