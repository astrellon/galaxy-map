shader_type canvas_item;

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.00001;
const float NONE = 0.0;
const float PLANET = 1.0;
const float CLOUD = 2.0;
const float RING = 3.0;
const float STAR = 4.0;
const float METAL = 5.0;
const float BLACK_HOLE_CENTER = 6.0;
const float BLACK_HOLE_RING = 7.0;

uniform sampler2D uNoiseTexture: repeat_enable, filter_linear;
uniform sampler2D uPlanetTexture: repeat_disable, filter_nearest;
uniform mat3 uCameraMatrix;
uniform vec3 uCameraPosition = vec3(0.0, 0.0, 5.0);
uniform float uCameraFov = 50.0;
uniform float uReveal = 2.0;

uniform vec4 uPlanetNoiseScale = vec4(1.0);
uniform vec4 uPlanetNoiseOffset = vec4(0.0);
uniform vec4 uRingParams = vec4(1.1, 0.75, 0.015, 0.0);
uniform int uScene = 0;

varying mat3 cloudRotation;


#define saturate(x) clamp(x, 0.0, 1.0)

// Taken from: https://github.com/dmnsgn/glsl-rotate/blob/main/rotation-3d.glsl
mat3 rotation3d(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(
        vec3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s),
        vec3(oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s),
        vec3(oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c)
    );
}
mat3 rotation3dY(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat3(
    vec3(c, 0.0, -s),
    vec3(0.0, 1.0, 0.0),
    vec3(s, 0.0, c)
  );
}

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

float opUnion(float d1, float d2)
{
	return min(d1, d2);
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

float sdfDisk(vec3 samplePoint, float height, float thickness, float radius)
{
	return max(abs(samplePoint.y) / height - thickness, length(samplePoint.xz) - radius);
}

float sdfCappedCylinder(vec3 point, float height, float radius)
{
    vec2 d = abs(vec2(length(point.xz), point.y)) - vec2(radius, height);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Taken from https://github.com/fogleman/sdf/blob/d58a6fc63b75fc1cf1ebb71e0b42bf552319c8f1/sdf/d3.py#L314
float sdfIcosahedron(vec3 point, float radius)
{
    vec3 xyz = normalize(vec3((sqrt(5.0) + 3.0) / 2.0, 1.0, 0.0));
    const vec3 w = vec3(sqrt(3.0) / 3.0);

    radius *= 0.8506507174597755;

    point = abs(point / radius);
    float a = dot(point, xyz.xyz);
    float b = dot(point, xyz.zxy);
    float c = dot(point, xyz.yzx);
    float d = dot(point, w) - xyz.x;

    return max(max(max(a, b), c) - xyz.x, d) * radius;
}

float sdfTorus(vec3 point, float radius, float ringRadius)
{
	vec2 distToRingCenter = vec2(length(point.xz) - radius, point.y);
	return length(distToRingCenter) - ringRadius;
}

float cloudScene(vec3 samplePoint)
{
	samplePoint = cloudRotation * samplePoint;
    if (uScene == 0 || uScene == 5 || uScene == 6)
    {
        float outerSphere = sdfSphere(samplePoint, 0.5 + uRingParams.x);
        float innerSphere = sdfSphere(samplePoint, 0.5 + uRingParams.y);
        float cloudDist = outerSphere + (perlinNoise3D(samplePoint * 0.0175 + vec3(0.12)) - 0.85) * uRingParams.z;

        return opSubtraction(cloudDist, innerSphere);
    }
	if (uScene == 7)
	{
		float outerTorus = sdfTorus(samplePoint, uRingParams.x, uRingParams.y + uRingParams.z);
		float innerTorus = sdfTorus(samplePoint, uRingParams.x, uRingParams.y + uRingParams.w);
		float cloudDist = outerTorus + (perlinNoise3D(samplePoint * 0.0175 + vec3(1.12)) - 0.85) * 0.35;
		
		return opSubtraction(cloudDist, innerTorus);
	}

    return 100.0;
}

vec2 planetScene(vec3 samplePoint)
{
    if (uScene == 0 || uScene == 1 || uScene == 5 || uScene == 6)
    {
        return vec2(sdfSphere(samplePoint, 0.5), PLANET);
    }
	if (uScene == 2)
	{
		return vec2(sdfSphere(samplePoint, 0.25), STAR);
	}
	if (uScene == 7)
	{
		return vec2(sdfTorus(samplePoint, uRingParams.x, uRingParams.y), PLANET);
	}

    return vec2(100.0, CLOUD);
}

vec2 ringScene(vec3 samplePoint)
{
    if (uScene == 1)
    {
        return vec2(opSubtraction(
            sdfCappedCylinder(samplePoint, uRingParams.z + 1.0, uRingParams.y),
            sdfCappedCylinder(samplePoint, uRingParams.z, uRingParams.x)), RING);
    }
	if (uScene == 2 || uScene == 3)
	{
		float innerSphere = sdfSphere(samplePoint, 0.715);
		float platforms1 = opSubtraction(innerSphere, sdfIcosahedron(samplePoint, 0.82));

		return vec2(platforms1, METAL);
	}

    return vec2(100.0, RING);
}

vec2 objMin(vec2 d1, vec2 d2)
{
    return d1.x < d2.x ? d1 : d2;
}

float starScene(vec3 samplePoint)
{
	return 100.0;
}

vec2 sceneSDF(vec3 samplePoint, bool shadow)
{
	vec2 sphereDist = planetScene(samplePoint);
	vec2 cloudDist = vec2(cloudScene(samplePoint), CLOUD);
	vec2 ringDist = ringScene(samplePoint);
	vec2 starDist = shadow ? vec2(100.0, STAR) : vec2(starScene(samplePoint), STAR);

	return objMin(objMin(sphereDist, objMin(cloudDist, ringDist)), starDist);
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
        planetScene(point + eps_zero.xyy).x - planetScene(point - eps_zero.xyy).x,
        planetScene(point + eps_zero.yxy).x - planetScene(point - eps_zero.yxy).x,
        planetScene(point + eps_zero.yyx).x - planetScene(point - eps_zero.yyx).x
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
        ringScene(point + eps_zero.xyy).x - ringScene(point - eps_zero.xyy).x,
        ringScene(point + eps_zero.yxy).x - ringScene(point - eps_zero.yxy).x,
        ringScene(point + eps_zero.yyx).x - ringScene(point - eps_zero.yyx).x
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

    if (dotLN < 0.0)
	{
        // Light not visible from this point on the surface
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
        float dist = sceneSDF(rayOrigin + depth * rayDirection, true).x;
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

const vec3 defaultLightPos = vec3(-4.0, 1.5, 4.0);
float phongIllumination(float currentDepth, float alpha, vec3 point, vec3 eye, vec3 normal, float minDepth, vec3 lightPos, bool shadows)
{
	vec3 toLight = normalize(lightPos - point);

	float shadow = shadows ? softShadow(point, toLight, minDepth * currentDepth, 100.0) : 1.0;
    return phongContribForLight(alpha, point, eye, normal, lightPos) * shadow;
}

vec3 rayMarch(vec3 rayOrigin, vec3 rayDirection, float near, float far)
{
    float depth = near;
	int i = 0;
    for (; i < MAX_MARCHING_STEPS; i++)
    {
        vec2 dist = sceneSDF(rayOrigin + depth * rayDirection, false);
        if (dist.x < EPSILON)
        {
            return vec3(depth, dist.y, float(i));
        }

        depth += dist.x * 0.5;
        if (depth >= far)
        {
            return vec3(far, 0.0, float(i));
        }
    }

    return vec3(far, 0.0, float(i));
}

vec3 rayMarchPlanet(vec3 rayOrigin, vec3 rayDirection, float near, float far)
{
    float depth = near;
	int i = 0;
    for (; i < MAX_MARCHING_STEPS; i++)
    {
        float dist = planetScene(rayOrigin + depth * rayDirection).x;
        if (dist < EPSILON)
        {
            return vec3(depth, STAR, float(i));
        }

        depth += dist * 0.5;
        if (depth >= far)
        {
            return vec3(far, 0.0, float(i));
        }
    }

    return vec3(far, 0.0, float(i));
}

bool approxEquals(float x, float y)
{
	return abs(x - y) < EPSILON;
}


// Taken from Shader Toy https://www.shadertoy.com/view/NdV3Rd
// -------
vec2 blackHoleScene(vec3 p)
{
    vec2 acc = vec2(1000., -1.);

	acc = objMin(acc, vec2(sdfSphere(p, 0.2), BLACK_HOLE_CENTER));

	float plane = sdfDisk(p, 0.3, 0.001, 0.9);
    acc = objMin(acc, vec2(plane, BLACK_HOLE_RING));

    return acc;
}

vec3 gradient(float f)
{
	return texture(uPlanetTexture, vec2(f, 0.5)).xyz;
}

mat3 blackHoleRayMarch(vec3 rayOrigin, vec3 rayDir, int steps)
{
    vec3 accCol = vec3(0.0);
    vec3 finalPos = rayOrigin;
    vec3 pos = rayOrigin;
    for (int i = 0; i < steps; ++i)
    {
        vec2 res = blackHoleScene(pos);
        if (res.x < 0.01)
        {
            if (approxEquals(res.y, BLACK_HOLE_CENTER))
			{
                accCol *= 0.5;
			}
            return mat3(vec3(res.x, distance(pos, rayOrigin), res.y), finalPos, accCol);
        }
		
        rayDir = normalize(rayDir - normalize(pos) * 0.01 * pow(1.0 - saturate(length(pos) - 1.5), 1.5));
		accCol += 0.01 * gradient(length(pos * 3.0) - 1.6) * (1.0 - saturate(res.x / 0.5));
        pos += rayDir * res.x * 0.15;
        finalPos = pos;
    }
	
    return mat3(vec3(-1.0), finalPos, accCol);
}

vec4 getBlackHoleColour(vec3 rayOrigin, vec3 rayDir)
{
    vec3 col = vec3(0.078, 0.043, 0.157) * 0.35;
    
	mat3 traced = blackHoleRayMarch(rayOrigin, rayDir, 512);
	vec3 res = traced[0];
	vec3 finalPos = cloudRotation * traced[1];
	vec3 accCol = traced[2];
	
	float alpha = res.y >= 0.0 ? 1.0 : 0.0;
    if (res.y > 0.0)
    {
        vec3 p = rayOrigin + rayDir * res.x;
        float idx = floor(length(finalPos) * 7.0);
        if (res.z == BLACK_HOLE_RING)
		{
            col += gradient(length(finalPos * 3.0 + noise3D(finalPos * 0.1 + uPlanetNoiseOffset.xyz)) - 1.6) * 
				mix(0.7, 1.0, 
					saturate(length(finalPos) - 1.5) * 
						saturate(400.0 * sin(0.25 * pow(idx, 0.75) + 5.0 * atan(finalPos.z, finalPos.x)))
				);
		}
        else
        {
            col = vec3(0.0);
        }
    }
	
    col += accCol;
    return vec4(col, alpha);
}
// -------

void vertex() {
	cloudRotation = rotation3dY(TIME * 0.2);
}

void fragment()
{
	vec2 oPosition = UV * 2.0 - 1.0;
	oPosition.y = -oPosition.y;
	
	float noise = perlinNoise3D(vec3(oPosition, 1.0) * 0.0075 * uPlanetNoiseScale.xyz + uPlanetNoiseOffset.xyz) - 0.6;
	if (noise > uReveal)
	{
		discard;
	}

    vec3 rayDir = uCameraMatrix * rayDirection(uCameraFov, oPosition);
    vec3 rayOrigin = uCameraPosition;
	vec4 extraColour = vec4(0.0);
	
	COLOR = vec4(0.0);
	
	if (uScene == 4)
	{
		COLOR = getBlackHoleColour(rayOrigin, rayDir);
	}
	else
	{
	    vec3 dist = rayMarch(rayOrigin, rayDir, MIN_DIST, MAX_DIST);

		float numSteps = dist.z;
		vec3 starDist = rayMarchPlanet(rayOrigin, rayDir, MIN_DIST, MAX_DIST);
		if (starDist.x < dist.x + 0.1 || dist.x > 5.0)
		{
			numSteps += starDist.z * 6.0;
			
			float colour = 0.0;
			if (uScene == 2)
			{
				colour = pow(numSteps / 250.0, 3.5);
			}
			extraColour = vec4(colour);
		}
		
	    if (dist.x > MAX_DIST - EPSILON)
	    {
			if (extraColour.x <= 0.0)
			{
				discard;
			}
	    }
	    else
	    {
	        // The closest point on the surface to the eyepoint along the view ray
	        vec3 p = rayOrigin + dist.x * rayDir;

			float noise = perlinNoise3D(p * 0.0075 * uPlanetNoiseScale.xyz + uPlanetNoiseOffset.xyz + uPlanetNoiseOffset.w);
			if (noise - 0.6 > uReveal && extraColour.x <= 0.0)
			{
				discard;
			}

			if (approxEquals(dist.y, PLANET))
			{
				vec3 normal = estimateNormalPlanet(p, dist.x);
	        	float lighting = saturate(phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.001, defaultLightPos, true));
				float fresnel = dot(normal, rayDir);
				fresnel = saturate(fresnel + 1.0);

				fresnel = pow(fresnel, 2.5);
				fresnel = round(fresnel * 2.0);
				lighting = max(lighting, fresnel * 0.5);

				vec3 planetColour = texture(uPlanetTexture, vec2(noise * uPlanetNoiseScale.w, 1.2 - lighting)).rgb;

		        COLOR = vec4(planetColour, 1.0);
			}
			else if (approxEquals(dist.y, CLOUD))
			{
				vec3 normal = estimateNormalCloud(p, dist.x);
	        	float lighting = phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.001, defaultLightPos, true) * 0.5 + 0.5;
				COLOR = vec4(vec3(lighting), 1.0);
			}
			else if (approxEquals(dist.y, RING))
			{
				vec3 normal = estimateNormalRing(p, dist.x);
				normal.y = abs(normal.y);
	        	float lighting = phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.1, defaultLightPos, true) / 2.0;
				float dist = sin(length(p) * 50.0) * 0.2 + 1.0;
				COLOR = vec4(vec3(dist * lighting * vec3(0.75, 0.5, 0.4)), 1.0);
			}
	        else if (approxEquals(dist.y, METAL))
			{
				vec3 normal = estimateNormalPlanet(p, dist.x);

	        	float lighting = phongIllumination(dist.x, 5.0, p, rayOrigin, normal, 0.001, vec3(0.0), false) * 0.5 + 0.5;
				vec3 planetColour = texture(uPlanetTexture, vec2(noise, 1.2 - lighting)).rgb;
				COLOR = vec4(planetColour, 1.0);
			}
			else if (approxEquals(dist.y, STAR))
			{
				COLOR = vec4(1.0);
			}
	    }
		COLOR += extraColour;
	}
}
