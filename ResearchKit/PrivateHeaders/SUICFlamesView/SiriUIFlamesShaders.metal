/*
  See LICENSE folder for this sample’s licensing information.

  Abstract:
  Metal shaders used for this sample
*/

#include <metal_stdlib>
#include <simd/simd.h>

#import "SUICFlamesShaderTypes.h"

using namespace metal;

// Vertex shader outputs and fragment shader inputs
typedef struct
{
    // The [[position]] attribute of this member indicates that this value is the clip space
    // position of the vertex when this structure is returned from the vertex function
    float4 clipSpacePosition [[position]];

    float4 height_center_alpha_unitSize;
    float3 channelCoord;
    float3 colorNoise;
    float3 alpha3f;
    float alpha1f;
    float boundsX;
    float centerY;
    float viewportZ;
} RasterizerData;

float3
mod289(float3 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4
mod289(float4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4
permute(float4 x)
{
    return mod289(((x * 34.0) + 1.0) * x);
}

float4
taylorInvSqrt(float4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float
snoise(float3 v)
{
    const float2  C = float2(1.0/6.0, 1.0/3.0) ;
    const float4  D = float4(0.0, 0.5, 1.0, 2.0);

    // First corner
    float3 i  = floor(v + dot(v, C.yyy) );
    float3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min( g.xyz, l.zxy );
    float3 i2 = max( g.xyz, l.zxy );

    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

    // Permutations
    i = mod289(i);
    float4 p = permute(permute(permute(i.z + float4(0.0, i1.z, i2.z, 1.0 )) +
                               i.y + float4(0.0, i1.y, i2.y, 1.0 )) +
                       i.x + float4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    float3  ns = n_ * D.wyz - D.xzx;

    float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    float4 x = x_ *ns.x + ns.yyyy;
    float4 y = y_ *ns.x + ns.yyyy;
    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = float4( x.xy, y.xy );
    float4 b1 = float4( x.zw, y.zw );

    //float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
    //float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
    float4 s0 = floor(b0)*2.0 + 1.0;
    float4 s1 = floor(b1)*2.0 + 1.0;
    float4 sh = -step(h, float4(0.0));

    float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    float3 p0 = float3(a0.xy,h.x);
    float3 p1 = float3(a0.zw,h.y);
    float3 p2 = float3(a1.xy,h.z);
    float3 p3 = float3(a1.zw,h.w);

    //Normalise gradients
    float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1),
                                    dot(p2,x2), dot(p3,x3) ) );
}

constant float pi = 3.1415926535;
constant float kThinkingHeightMax = 0.2; // kThinkingHeightMax: max peak of thinking waves 0 <-> 1
constant float kFastTimeMultiplier = 4.4; // fast sine time for speed of thinking waves

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float FastSin(float rad)
{
    float x = mod(rad, 2.0 * pi) - pi;
    return (-4.0/(pi*pi)) * x * (pi - abs(x));
}

float FastCos(float rad)
{
    return FastSin(rad + pi * 0.5);
}

vertex RasterizerData
siriFlameVertexShader(uint vertexID [[ vertex_id ]],
                      const device Vertex *vertices [[ buffer(SiriFlames_VertexInput_Polar) ]],
                      constant vector_float4 *in_ViewportDim_ScreenScale_UnitLength  [[ buffer(SiriFlames_VertexInput_Viewport) ]],
                      constant vector_float4 *in_FittedBounds  [[ buffer(SiriFlames_VertexInput_Bounds) ]],
                      constant vector_float4 *flamesData  [[ buffer(SiriFlames_VertexInput_Time_Ztime_Height_Alpha) ]],
                      constant vector_float4 *in_States  [[ buffer(SiriFlames_VertexInput_States) ]])
{
    // ATTRIBUTES
    float time =   flamesData->x;
    float zTime =  flamesData->y;
    float height = flamesData->z;  // 0 <-> 1
    float globalAlpha = flamesData->w;
    float4 in_Polar = vertices[vertexID].vertexLocation;
    float r_orig = in_Polar.x;
    float q_orig = in_Polar.y;
    float q_noise = in_Polar.w;

    // UNITS
    float2 scale = in_FittedBounds->zw / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z);
    float2 center = (in_FittedBounds->xy + (in_FittedBounds->zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z) * 2.0 - 1.0;
    center.y = -center.y;
    float2 device_pixel = 2.0 / in_ViewportDim_ScreenScale_UnitLength->xy;

    // RATIOS
    float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;
    float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;

    float sin_q = FastSin(q_orig);
    float cos_q = FastCos(q_orig);

    // STATES
    float state_0 = smoothstep(0.0, 1.0, in_States->x);
    float state_1 = smoothstep(0.0, 1.0, in_States->y);
    float state_2 = smoothstep(0.0, 1.0, in_States->z);

    // state_3 uses 3 smoothed values to order aspects of the transition that may need to happen sooner than something else.
    float state_3a = smoothstep(0.0, 0.25, in_States->w);
    float state_3b = smoothstep(0.0, 0.5, in_States->w);
    float state_3c = smoothstep(0.0, 1.0, in_States->w);
    float state_3d = smoothstep(0.75, 1.0, in_States->w);

    // COORDINATES
    float2 theta_geom = mix(float2(abs_q_orig_ndc, sign(sin_q)), float2(cos_q, sin_q), state_3c);
    float2 theta_noise = mix(float2(abs_q_noise_ndc, sign(sin_q)), float2(cos_q, sin_q), state_3c);
    float2 cartesian_orig = theta_geom * r_orig;
    float2 r_geom = mix(float2(r_orig * (1.0 - state_0), 0.0) * scale, float2(r_orig * distance(center, float2(1.0))), state_3b); // r for noise and geometry

    // wave's geometric falloff
    float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_orig.x) - smoothstep(0.5, 1.0, cartesian_orig.x)) * (1.0 - in_States->x * in_States->x * in_States->x);

    // aura's geometric falloff
    float aura_point_dist = length(cartesian_orig);

    // falloff_aura: formula is for the outer edge. transitions to softness quickly and then back to hard after transition is complete.
    float falloff_aura = mix(1.0, smoothstep(1.0, 0.9, aura_point_dist), state_3a);
    falloff_aura = mix(falloff_aura, 1.0, state_3d);

    // waitingMap
    float map_x = abs(theta_geom.x * r_geom.x);
    float waitingMap = clamp(FastSin((map_x + in_States->x * 1.5 - 1.0) * pi), 0.0, 1.0);
    waitingMap *= 1.0 - 0.6 * state_0 * state_0;

    // listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
    float listeningMap = smoothstep(-0.75, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.75, cartesian_orig.x);
    
    // apply height to listening map.
    listeningMap *= height;
    listeningMap *= (state_1 + state_0);
    
    // thinkingMap: Curved ping-pong
    float pingPong = FastSin(time * kFastTimeMultiplier) * 0.9;
    float leftScale = max(0.0, FastSin(time * kFastTimeMultiplier + 0.4 * pi));
    leftScale = (leftScale * leftScale * 0.9 + 0.1) * 0.9;
    float rightScale = max(0.0, FastSin(time * kFastTimeMultiplier - 0.6 * pi));
    rightScale = (rightScale * rightScale * 0.9 + 0.1) * 0.9;
    float thinkingMap = smoothstep(pingPong - leftScale, pingPong, abs_q_orig_ndc) * smoothstep(pingPong + rightScale, pingPong, abs_q_orig_ndc) * kThinkingHeightMax;
    thinkingMap *= state_2;

    // mirroredSine for thinking map
    float mirroredSineMap = clamp(FastSin((map_x + (1.0 - in_States->z) * 2.0 - 1.0) * pi), 0.0, 1.0);
    mirroredSineMap *= 0.3;
    thinkingMap += mirroredSineMap;

    // mapSum (sum of all maps)
    float mapSum = mix(waitingMap + listeningMap + thinkingMap, 1.0, state_3a);

    // noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
    float2 cartesian_noise = theta_noise * r_geom;
    float noiseFrequency = ((0.00267 + height * 0.004) * (state_0 + state_1) + 0.001333 * state_2) * min(500.0 , max(in_FittedBounds->z, 200.0)) + state_3a * 0.4;
    float noise0 = snoise(float3(cartesian_noise * noiseFrequency, zTime));
    float noise1 = snoise(float3(cartesian_noise * noiseFrequency, zTime + 1.0));
    float noise2 = snoise(float3(cartesian_noise * noiseFrequency, zTime + 2.0));

    // clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
    float abs_noise0 = abs(noise0);
    float abs_noise1 = abs(noise1);
    float abs_noise2 = abs(noise2);
    float abs_noise = max(max(abs_noise0, abs_noise1), abs_noise2);

    // noise and mapSum applied to r. re-application of scale. Multiplying device_pixel by 2.0 to gain two aa-shaded pixels (after fragment's smoothstep).
    r_geom.y = mix(max(mapSum * abs_noise * scale.y, device_pixel.y * 2.0 * state_1), r_geom.y, state_3b);

    // Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
    float2 cartesian_geom = theta_geom * r_geom + center;
    float3 wave_alpha = (1.0 - mapSum * float3(abs_noise0, abs_noise1, abs_noise2) * 0.95);
    wave_alpha *= wave_alpha;

    // output.
    RasterizerData out;
    out.clipSpacePosition = float4(cartesian_geom, 0.0, 1.0);
    out.channelCoord = max(mapSum * float3(abs_noise0, abs_noise1, abs_noise2) * (in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z, 2.0 * state_1);
    out.colorNoise = 1.0 - (1.0 - float3(1.0, 0.176, 0.333) * noise0) * (1.0 - float3(0.251, 1.0, 0.639) * noise1) * (1.0 - float3(0.0, 0.478, 1.0) * noise2); // screen
    out.alpha3f = wave_alpha * wave_falloff * globalAlpha;
    out.alpha1f = max(out.colorNoise.x, max(out.colorNoise.y, out.colorNoise.z)) * 0.4 * falloff_aura * globalAlpha;
    out.centerY = (in_FittedBounds->y + in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z;

    return out;
}

vertex RasterizerData
siriFlameAccessibilityVertexShader(uint vertexID [[ vertex_id ]],
                                   const device Vertex *vertices [[ buffer(SiriFlames_VertexInput_Polar) ]],
                                   constant vector_float4 *in_ViewportDim_ScreenScale_UnitLength  [[ buffer(SiriFlames_VertexInput_Viewport) ]],
                                   constant vector_float4 *in_FittedBounds  [[ buffer(SiriFlames_VertexInput_Bounds) ]],
                                   constant vector_float4 *flamesData  [[ buffer(SiriFlames_VertexInput_Time_Ztime_Height_Alpha) ]],
                                   constant vector_float4 *in_States  [[ buffer(SiriFlames_VertexInput_States) ]])
{
    // ATTRIBUTES
    float time =   flamesData->x;
    float zTime =  flamesData->y;
    float height = flamesData->z;  // 0 <-> 1
    float globalAlpha = flamesData->w;
    float4 in_Polar = vertices[vertexID].vertexLocation;
    float r_orig = in_Polar.x;
    float q_orig = in_Polar.y;
    float q_noise = in_Polar.w;

    // UNITS
    float2 scale = in_FittedBounds->zw / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z);
    float2 center = (in_FittedBounds->xy + (in_FittedBounds->zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z) * 2.0 - 1.0;
    center.y = -center.y;
    float2 device_pixel = 2.0 / in_ViewportDim_ScreenScale_UnitLength->xy;

    // RATIOS
    float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;
    float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;

    float sin_q = FastSin(q_orig);
    float cos_q = FastCos(q_orig);

    // STATES
    float state_0 = smoothstep(0.0, 1.0, in_States->x);
    float state_1 = smoothstep(0.0, 1.0, in_States->y);
    float state_2 = smoothstep(0.0, 1.0, in_States->z);

    // state_3 uses 3 smoothed values to order aspects of the transition that may need to happen sooner than something else.
    float state_3_fadeOut = smoothstep(0.00, 0.25, in_States->w);
    float state_3_change  = smoothstep(0.25, 0.50, in_States->w);
    float state_3_fadeIn  = smoothstep(0.50, 1.00, in_States->w);

    // COORDINATES
    float2 theta_geom = mix(float2(abs_q_orig_ndc, sign(sin_q)), float2(cos_q, sin_q), state_3_change);
    float2 theta_noise = mix(float2(abs_q_noise_ndc, sign(sin_q)), float2(cos_q, sin_q), state_3_change);
    float2 cartesian_orig = theta_geom * r_orig;
    float2 r_geom = mix(float2(r_orig * (1.0 - state_0), 0.0) * scale, float2(r_orig * distance(center, float2(1.0))), state_3_change); // r for noise and geometry

    // wave's geometric falloff
    float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_orig.x) - smoothstep(0.5, 1.0, cartesian_orig.x)) * (1.0 - in_States->x * in_States->x * in_States->x);

    // aura's geometric falloff
    float aura_point_dist = length(cartesian_orig);

    // falloff_aura: formula is for the outer edge. transitions to softness quickly and then back to hard after transition is complete.
    float falloff_aura = mix(1.0, smoothstep(1.0, 0.9, aura_point_dist), state_3_change);
    falloff_aura = mix(falloff_aura, 1.0, state_3_change);

    // listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
    float listeningMap = smoothstep(-0.75, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.75, cartesian_orig.x);
    
    // apply height to listening map.
    listeningMap *= height;
    listeningMap *= (state_1 + state_0);
    
    // thinkingMap: Breathing
    float thinkingMap = smoothstep(-0.3, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.3, cartesian_orig.x);
    thinkingMap *= state_2 * ((FastSin(time * kFastTimeMultiplier) + 2.0) * 0.5 * kThinkingHeightMax);

    // mapSum (sum of all maps)
    float mapSum = mix(listeningMap + listeningMap + thinkingMap, 1.0, state_3_change);

    // noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
    float2 cartesian_noise = theta_noise * r_geom;
    float noiseFrequency = ((0.00267 + height * 0.004) * (state_0 + state_1) + 0.00267 * state_2) * min(500.0 , max(in_FittedBounds->z, 200.0)) + state_3_change * 0.4;
    float noise0 = snoise(float3(cartesian_noise * noiseFrequency, zTime));
    float noise1 = snoise(float3(cartesian_noise * noiseFrequency, zTime + 1.0));
    float noise2 = snoise(float3(cartesian_noise * noiseFrequency, zTime + 2.0));

    // clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
    float abs_noise0 = abs(noise0);
    float abs_noise1 = abs(noise1);
    float abs_noise2 = abs(noise2);
    float abs_noise = max(max(abs_noise0, abs_noise1), abs_noise2);

    // noise and mapSum applied to r. re-application of scale. Multiplying device_pixel by 2.0 to gain two aa-shaded pixels (after fragment's smoothstep).
    r_geom.y = mix(max(mapSum * abs_noise * scale.y, device_pixel.y * 2.0 * (state_1 + state_2)), r_geom.y, state_3_change);

    // Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
    float2 cartesian_geom = theta_geom * r_geom + center;
    float3 wave_alpha = (1.0 - mapSum * float3(abs_noise0, abs_noise1, abs_noise2) * 0.95);
    wave_alpha *= wave_alpha;

    // output.
    RasterizerData out;
    out.clipSpacePosition = float4(cartesian_geom, 0.0, 1.0);
    out.channelCoord = max(mapSum * float3(abs_noise0, abs_noise1, abs_noise2) * (in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z, 2.0 * (state_1 + state_2));
    out.colorNoise = 1.0 - (1.0 - float3(1.0, 0.176, 0.333) * noise0) * (1.0 - float3(0.251, 1.0, 0.639) * noise1) * (1.0 - float3(0.0, 0.478, 1.0) * noise2); // screen
    out.alpha3f = wave_alpha * wave_falloff * globalAlpha * (1.0 - state_3_fadeOut);
    out.alpha1f = max(out.colorNoise.x, max(out.colorNoise.y, out.colorNoise.z)) * 0.4 * falloff_aura * (globalAlpha * state_3_fadeIn);
    out.centerY = (in_FittedBounds->y + in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z;

    return out;
}

fragment float4
siriFlameFragmentShader(RasterizerData in [[stage_in]])
{
    // intentionally passing outside geometry (for outermost coord) to allow msaa to do its job.
    // not passing outside the geometry. if msaa is off.
    float p = abs(in.clipSpacePosition.y - in.centerY);
    float3 wave_channel = smoothstep(in.channelCoord, in.channelCoord - 2.0, float3(p));

    // final 3 wave colors
    float4 xColor = float4(1.000, 0.176, 0.333, in.alpha3f.x) * wave_channel.x;
    float4 yColor = float4(0.251, 1.000, 0.639, in.alpha3f.y) * wave_channel.y;
    float4 zColor = float4(0.000, 0.478, 1.000, in.alpha3f.z) * wave_channel.z;
    
    return 1.0 - (1.0 - xColor) * (1.0 - yColor) * (1.0 - zColor);
}

fragment float4
siriAuraFragmentShader(RasterizerData in [[stage_in]])
{
    return float4(in.colorNoise, in.alpha1f);
}

vertex RasterizerData
siriTrainingVertexShader(uint vertexID [[ vertex_id ]],
                         const device Vertex *vertices [[ buffer(SiriFlames_VertexInput_Polar) ]],
                         constant vector_float4 *in_ViewportDim_ScreenScale_UnitLength  [[ buffer(SiriFlames_VertexInput_Viewport) ]],
                         constant vector_float4 *in_FittedBounds  [[ buffer(SiriFlames_VertexInput_Bounds) ]],
                         constant vector_float4 *flamesData  [[ buffer(SiriFlames_VertexInput_Time_Ztime_Height_Alpha) ]],
                         constant vector_float4 *in_States  [[ buffer(SiriFlames_VertexInput_States) ]])
{
    // ATTRIBUTES
    float time =   flamesData->x;
    float zTime =  flamesData->y;
    float height = flamesData->z;  // 0 <-> 1
    float globalAlpha = flamesData->w;
    float4 in_Polar = vertices[vertexID].vertexLocation;
    float r_orig = in_Polar.x;
    float q_orig = in_Polar.y;
    float q_noise = in_Polar.w;

    // UNITS
    float2 scale = in_FittedBounds->zw / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z);
    float2 center = (in_FittedBounds->xy + (in_FittedBounds->zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z) * 2.0 - 1.0;
    center.y = -center.y;
    float2 device_pixel = 2.0 / in_ViewportDim_ScreenScale_UnitLength->xy;

    // RATIOS
    float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;
    float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;

    float sin_q = FastSin(q_orig);

    // STATES
    float state_0 = smoothstep(0.0, 1.0, in_States->x);
    float state_1 = smoothstep(0.0, 1.0, in_States->y);
    float state_2 = smoothstep(0.0, 1.0, in_States->z);

    // state_3 will not be used for this particular pipeline

    // COORDINATES
    float2 theta_geom = float2(abs_q_orig_ndc, sign(sin_q));
    float2 theta_noise = float2(abs_q_noise_ndc, sign(sin_q));
    float2 cartesian_orig = theta_geom * r_orig;
    float2 r_geom = float2(r_orig * (1.0 - state_0), 0.0) * scale;

    // wave's geometric falloff
    float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_orig.x) - smoothstep(0.5, 1.0, cartesian_orig.x)) * (1.0 - in_States->x * in_States->x * in_States->x);

    // waitingMap
    float map_x = abs(theta_geom.x * r_geom.x);
    float waitingMap = clamp(FastSin((map_x + in_States->x * 1.5 - 1.0) * pi), 0.0, 1.0);
    waitingMap *= 1.0 - 0.6 * state_0 * state_0;

    // listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
    float listeningMap = smoothstep(-0.75, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.75, cartesian_orig.x);
    
    // apply height to listening map.
    listeningMap *= height;
    listeningMap *= (state_1 + state_0);
    
    // thinkingMap: Curved ping-pong
    float pingPong = FastSin(time * kFastTimeMultiplier) * 0.9;
    float leftScale = max(0.0, FastSin(time * kFastTimeMultiplier + 0.4 * pi));
    leftScale = (leftScale * leftScale * 0.9 + 0.1) * 0.9;
    float rightScale = max(0.0, FastSin(time * kFastTimeMultiplier - 0.6 * pi));
    rightScale = (rightScale * rightScale * 0.9 + 0.1) * 0.9;
    float thinkingMap = smoothstep(pingPong - leftScale, pingPong, abs_q_orig_ndc) * smoothstep(pingPong + rightScale, pingPong, abs_q_orig_ndc) * kThinkingHeightMax;
    thinkingMap *= state_2;

    // mirroredSine for thinking map
    float mirroredSineMap = clamp(FastSin((map_x + (1.0 - in_States->z) * 2.0 - 1.0) * pi), 0.0, 1.0);
    mirroredSineMap *= 0.5;
    thinkingMap += mirroredSineMap;

    // mapSum (sum of all maps)
    float mapSum = waitingMap + listeningMap + thinkingMap;

    // noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
    float2 cartesian_noise = theta_noise * r_geom;
    float noiseFrequency = ((0.00267 + height * 0.004) * (state_0 + state_1) + 0.001333 * state_2) * min(500.0 , max(in_FittedBounds->z, 200.0));
    float noise0 = snoise(float3(cartesian_noise * noiseFrequency, zTime));
    float noise1 = snoise(float3(cartesian_noise * noiseFrequency, zTime + 1.0));
    float noise2 = snoise(float3(cartesian_noise * noiseFrequency, zTime + 2.0));

    // clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
    float abs_noise0 = abs(noise0);
    float abs_noise1 = abs(noise1);
    float abs_noise2 = abs(noise2);
    float abs_noise = max(max(abs_noise0, abs_noise1), abs_noise2);

    // noise and mapSum applied to r. re-application of scale. Multiplying device_pixel by 2.0 to gain two aa-shaded pixels (after fragment's smoothstep).
    r_geom.y = max(mapSum * abs_noise * scale.y, device_pixel.y * 2.0 * state_1);

    // Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
    float2 cartesian_geom = theta_geom * r_geom + center;
    float3 wave_alpha = (1.0 - mapSum * float3(abs_noise0, abs_noise1, abs_noise2) * 0.95);
    wave_alpha *= wave_alpha;

    // output.
    RasterizerData out;
    out.clipSpacePosition = float4(cartesian_geom, 0.0, 1.0);
    out.channelCoord = max(mapSum * float3(abs_noise0, abs_noise1, abs_noise2) * (in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z, 2.0 * state_1);
    out.alpha3f = wave_alpha * globalAlpha;
    out.alpha1f = wave_falloff * globalAlpha;
    out.centerY = (in_FittedBounds->y + in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z;

    return out;
}

fragment float4
siriTrainingFragmentShader(RasterizerData in [[stage_in]])
{
    // intentionally passing outside geometry (for outermost coord) to allow msaa to do its job.
    // not passing outside the geometry. if msaa is off.
    float p = abs(in.clipSpacePosition.y - in.centerY);
    float3 wave_channel = smoothstep(in.channelCoord, in.channelCoord - 2.0, float3(p));
    float4 colorModifier = float4(0.3,0.3,0.3,0.0);

    float4 xColor = (float4(1.0, 0.286, 0.333, in.alpha1f) + colorModifier * (1.0 - in.alpha3f.x)) * wave_channel.x;
    float4 yColor = (float4(0.298, 0.85, 0.39, in.alpha1f) + colorModifier * (1.0 - in.alpha3f.y)) * wave_channel.y;
    float4 zColor = (float4(0.0, 0.478, 1.0, in.alpha1f) + colorModifier * (1.0 - in.alpha3f.z)) * wave_channel.z;

    return 1.0 - (1.0 - xColor) * (1.0 - yColor) * (1.0 - zColor);
}

vertex RasterizerData
siriDictationVertexShader(uint vertexID [[ vertex_id ]],
                          const device Vertex *vertices [[ buffer(SiriFlames_VertexInput_Polar) ]],
                          constant vector_float4 *in_ViewportDim_ScreenScale_UnitLength  [[ buffer(SiriFlames_VertexInput_Viewport) ]],
                          constant vector_float4 *in_FittedBounds  [[ buffer(SiriFlames_VertexInput_Bounds) ]],
                          constant vector_float4 *flamesData  [[ buffer(SiriFlames_VertexInput_Time_Ztime_Height_Alpha) ]],
                          constant vector_float4 *in_States  [[ buffer(SiriFlames_VertexInput_States) ]])
{
    // ATTRIBUTES
//    float time =   flamesData->x;
    float zTime =  flamesData->y;
    float height = flamesData->z;  // 0 <-> 1
    float globalAlpha = flamesData->w;
    float4 in_Polar = vertices[vertexID].vertexLocation;
    float r_orig = in_Polar.x;
    float q_orig = in_Polar.y;
    float q_noise = in_Polar.w;

    // UNITS
    float2 scale = in_FittedBounds->zw / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z);
    float2 center = (in_FittedBounds->xy + (in_FittedBounds->zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z) * 2.0 - 1.0;
    center.y = -center.y;
    float2 logical_pixel = 2.0 / (in_ViewportDim_ScreenScale_UnitLength->xy / in_ViewportDim_ScreenScale_UnitLength->z);

    // RATIOS
    float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;
    float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;

    float sin_q = FastSin(q_orig);
//    float cos_q = FastCos(q_orig);

    // STATES
    float state_0 = smoothstep(0.0, 1.0, in_States->x);
    float state_1 = smoothstep(0.0, 1.0, in_States->y);

    // COORDINATES
    float2 theta_geom = float2(abs_q_orig_ndc, sign(sin_q));
    float2 theta_noise = float2(abs_q_noise_ndc, sign(sin_q));
//    float2 cartesian_orig = theta_geom * r_orig;
    float2 r_geom = float2(r_orig * (1.0 - state_0), 0.0) * scale;
    float2 cartesian_noise = theta_noise * r_geom;

    // waitingMap
    float map_x = abs(theta_geom.x * r_geom.x);
    float waitingMap = clamp(FastSin((map_x + in_States->x * 1.5 - 1.0) * pi), 0.0, 1.0);
    waitingMap *= 1.0 - 0.6 * state_0 * state_0;

    // listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
    float listeningMap = smoothstep(-1.0, -0.25, cartesian_noise.x) - smoothstep(0.25, 1.0, cartesian_noise.x);
    
    // apply height to listening map.
    listeningMap *= height;
    listeningMap *= (state_1 + state_0);
    
    // mapSum (sum of all maps)
    float mapSum = waitingMap + listeningMap;

    // noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
    float noiseFrequency = (0.01 + height * 0.02) * (state_0 + state_1) * max(in_FittedBounds->z, 250.0);
    float noise = snoise(float3(cartesian_noise * noiseFrequency, zTime));

    // clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
    float abs_noise = abs(noise);

    // noise and mapSum applied to r. re-application of scale.
    r_geom.y = max(mapSum * abs_noise * scale.y, logical_pixel.y);

    // Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
    float2 cartesian_geom = theta_geom * r_geom + center;

    // output.
    RasterizerData out;
    float y_center_window = (in_FittedBounds->y + (in_FittedBounds->w * 0.5)) * in_ViewportDim_ScreenScale_UnitLength->z;
    float r_window = max(mapSum * abs_noise * (in_FittedBounds->w * 0.5) * in_ViewportDim_ScreenScale_UnitLength->z, 2.0);
    out.clipSpacePosition = float4(cartesian_geom, 0.0, 1.0);
    out.height_center_alpha_unitSize = float4(r_window, y_center_window, globalAlpha, in_ViewportDim_ScreenScale_UnitLength->w);
    out.viewportZ = in_ViewportDim_ScreenScale_UnitLength->z;
    out.boundsX = in_FittedBounds->x;
    out.colorNoise = float3(vertices[vertexID].color.x, vertices[vertexID].color.y, vertices[vertexID].color.z);

    return out;
}

fragment float4
siriDictationFragmentShader(RasterizerData in [[stage_in]])
{
    float unitSize = in.height_center_alpha_unitSize.w;
    float halfUnitSize = unitSize * 0.5;
    float halfLineSize = 2.0;
    float halfLineSize_sq = halfLineSize * halfLineSize;
    float2 p = float2(mod(in.clipSpacePosition.x - (in.boundsX * in.viewportZ) + halfUnitSize, unitSize) - halfUnitSize, abs(in.clipSpacePosition.y - in.height_center_alpha_unitSize.y) - (in.height_center_alpha_unitSize.x - halfLineSize));
    float px_sq = p.x*p.x;
    float d = smoothstep(0.25, 0.75, 1.0 - (px_sq + p.y*p.y) / (halfLineSize_sq * 2.0));
    float x = smoothstep(halfLineSize_sq + 0.5, halfLineSize_sq - 0.5, px_sq) * step(p.y, 0.0);
    
    return float4(in.colorNoise.x, in.colorNoise.y, in.colorNoise.z, (x + d) * in.height_center_alpha_unitSize.z);
}
