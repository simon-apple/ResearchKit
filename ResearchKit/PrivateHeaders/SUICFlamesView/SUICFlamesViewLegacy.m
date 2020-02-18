//
//  SUICFlamesViewLegacy.m
//
//  Created by Brandon Newendorp on 3/5/13.
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//
#import "SUICAudioLevelSmoother.h"
#import "SUICFlameGroup.h"
#import "SUICFlamesViewLegacy.h"
#import "SUICIndexCacheEntry.h"
//#import <AssistantServices/AFLogging.h>
//#import <MobileGestalt.h>
//#import <OpenGLES/EAGLPrivate.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/CADisplayLink.h>
#import <QuartzCore/CAEAGLLayer.h>
#include <simd/simd.h>
#if !TARGET_OS_SIMULATOR
//#include <libproc_internal.h>
#endif

#pragma mark - Macros
#define GLSL_IN_POLARVERTEX2_POLAROFFSET2       0
#define GLSL_VIEWPORTDIM_SCREENSCALE_UNITLENGTH 1
#define GLSL_IN_FITTED_BOUNDS                   2
#define GLSL_IN_TIME_ZTIME_HEIGHT_ALPHA         3
#define GLSL_STATES                             4
#define GLSL_FRAGMENT_COLOR                     5
#define USE_SIRI_GL_MULTISAMPLE  0 // number of samples -- SGX supports 0 or 4
#define USE_SIRI_GL_MSAA_FORMAT  GL_RGB5_A1
//#define USE_SIRI_GL_MSAA_FORMAT  GL_RGBA8_OES

#pragma mark - Shaders for SUICWaveViewMode 0
#import <OpenGLES/ES2/gl.h>
@interface SUICGLIndexCacheEntry : NSObject
@property (nonatomic, assign) GLuint numAuraIndices;
@property (nonatomic, assign) GLuint numAuraIndicesCulled;
@property (nonatomic, assign) GLuint numWaveIndices;
// This is expected to be a manually memory managed pointer.
// free will be called on this pointer when the cache entry is dealloc'd.
@property (nonatomic, assign) GLuint *gl_indices;
@end
@implementation SUICGLIndexCacheEntry
- (void)dealloc {
    free(_gl_indices);
}
@end
static const GLchar*  siriFlameVertexShader =
"#version 100\n"
"#extension GL_EXT_separate_shader_objects : enable\n"
"\n"
"layout(location = 0) attribute vec4 in_Polar;\n"
"layout(location = 1) attribute vec4 in_ViewportDim_ScreenScale_UnitLength;\n"
"layout(location = 2) attribute vec4 in_FittedBounds;\n"
"layout(location = 3) attribute vec4 in_Time_ZTime_Height_Alpha;\n"
"layout(location = 4) attribute vec4 in_States;\n" // idle:x,listening:y,thinking:z,aura:w
"\n"
"varying mediump vec3 out_ChannelCoord;\n"
"varying mediump vec3 out_ColorNoise;\n"
"varying mediump vec3 out_Alpha3f;\n"
"varying mediump float out_Alpha1f;\n"
"varying mediump float out_CenterY;\n"
"\n"
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//
"vec3 mod289(vec3 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 mod289(vec4 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 permute(vec4 x) {\n"
"return mod289(((x*34.0)+1.0)*x);\n"
"}\n"
"vec4 taylorInvSqrt(vec4 r)\n"
"{\n"
"return 1.79284291400159 - 0.85373472095314 * r;\n"
"}\n"
"float snoise(vec3 v)\n"
"{\n"
"const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;\n"
"const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);\n"
// First corner
"vec3 i  = floor(v + dot(v, C.yyy) );\n"
"vec3 x0 =   v - i + dot(i, C.xxx) ;\n"
// Other corners
"vec3 g = step(x0.yzx, x0.xyz);\n"
"vec3 l = 1.0 - g;\n"
"vec3 i1 = min( g.xyz, l.zxy );\n"
"vec3 i2 = max( g.xyz, l.zxy );\n"
//   x0 = x0 - 0.0 + 0.0 * C.xxx;
//   x1 = x0 - i1  + 1.0 * C.xxx;
//   x2 = x0 - i2  + 2.0 * C.xxx;
//   x3 = x0 - 1.0 + 3.0 * C.xxx;
"vec3 x1 = x0 - i1 + C.xxx;\n"
"vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y\n"
"vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y\n"
// Permutations
"i = mod289(i);\n"
"vec4 p = permute( permute( permute(\n"
"i.z + vec4(0.0, i1.z, i2.z, 1.0 ))\n"
"+ i.y + vec4(0.0, i1.y, i2.y, 1.0 ))\n"
"+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));\n"
// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
"float n_ = 0.142857142857; // 1.0/7.0\n"
"vec3  ns = n_ * D.wyz - D.xzx;\n"
"vec4 j = p - 49.0 * floor(p * ns.z * ns.z);\n"  //  mod(p,7*7)
"vec4 x_ = floor(j * ns.z);\n"
"vec4 y_ = floor(j - 7.0 * x_ );\n"    // mod(j,N)
"vec4 x = x_ *ns.x + ns.yyyy;\n"
"vec4 y = y_ *ns.x + ns.yyyy;\n"
"vec4 h = 1.0 - abs(x) - abs(y);\n"
"vec4 b0 = vec4( x.xy, y.xy );\n"
"vec4 b1 = vec4( x.zw, y.zw );\n"
//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
"vec4 s0 = floor(b0)*2.0 + 1.0;\n"
"vec4 s1 = floor(b1)*2.0 + 1.0;\n"
"vec4 sh = -step(h, vec4(0.0));\n"
"vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;\n"
"vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;\n"
"vec3 p0 = vec3(a0.xy,h.x);\n"
"vec3 p1 = vec3(a0.zw,h.y);\n"
"vec3 p2 = vec3(a1.xy,h.z);\n"
"vec3 p3 = vec3(a1.zw,h.w);\n"
//Normalise gradients
"vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));\n"
"p0 *= norm.x;\n"
"p1 *= norm.y;\n"
"p2 *= norm.z;\n"
"p3 *= norm.w;\n"
// Mix final noise value
"vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);\n"
"m = m * m;\n"
"return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),\n"
"dot(p2,x2), dot(p3,x3) ) );\n"
"}\n"
"const float kThinkingHeightMax = 0.2;\n" // kThinkingHeightMax: max peak of thinking waves 0 <-> 1
"const float kFastTimeMultiplier = 4.4;\n" // fast sine time for speed of thinking waves
"const float pi = 3.1415926535;\n"
"float FastSin( float rad )\n"
"{\n"
"   float x = mod(rad, 2.0 * pi) - pi;\n"
"   return (-4.0/(pi*pi)) * x * (pi - abs(x));\n"
"}\n"
"float FastCos( float rad )\n"
"{\n"
"   return FastSin(rad + pi * 0.5);\n"
"}\n"
"\n"
"void main(void)\n"
"{\n"
"\n"
// ATTRIBUTES
"float time =   in_Time_ZTime_Height_Alpha.x;\n"
"float zTime =  in_Time_ZTime_Height_Alpha.y;\n"
"float height = in_Time_ZTime_Height_Alpha.z;\n"  // 0 <-> 1
"float globalAlpha = in_Time_ZTime_Height_Alpha.w;\n"
"float r_orig = in_Polar.x;\n"
"float q_orig = in_Polar.y;\n"
//"float r_noise = in_Polar.z;\n" // not in use
"float q_noise = in_Polar.w;\n"
// UNITS
"vec2 scale = in_FittedBounds.zw / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z);\n"
"vec2 center = (in_FittedBounds.xy + (in_FittedBounds.zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z) * 2.0 - 1.0;\n"
"center.y = -center.y;\n" // flip y
"vec2 device_pixel = 2.0 / in_ViewportDim_ScreenScale_UnitLength.xy;\n"
// RATIOS
"float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;\n"
"float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;\n"
"float sin_q = FastSin(q_orig);\n"
"float cos_q = FastCos(q_orig);\n"
// STATES
"float state_0 = smoothstep(0.0, 1.0, in_States.x);\n"
"float state_1 = smoothstep(0.0, 1.0, in_States.y);\n"
"float state_2 = smoothstep(0.0, 1.0, in_States.z);\n"
// state_3 uses 3 smoothed values to order aspects of the transition that may need to happen sooner than something else.
"float state_3a = smoothstep(0.0, 0.25, in_States.w);\n"
"float state_3b = smoothstep(0.0, 0.5, in_States.w);\n"
"float state_3c = smoothstep(0.0, 1.0, in_States.w);\n"
"float state_3d = smoothstep(0.75, 1.0, in_States.w);\n"
// COORDINATES
"vec2 theta_geom = mix(vec2(abs_q_orig_ndc, sign(sin_q)), vec2(cos_q, sin_q), state_3c);\n"
"vec2 theta_noise = mix(vec2(abs_q_noise_ndc, sign(sin_q)), vec2(cos_q, sin_q), state_3c);\n"
"vec2 cartesian_orig = theta_geom * r_orig;\n"
"vec2 r_geom = mix(vec2(r_orig * (1.0 - state_0), 0.0) * scale, vec2(r_orig * distance(center, vec2(1.0))), state_3b);\n" // r for noise and geometry
// wave's geometric falloff
"float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_orig.x) - smoothstep(0.5, 1.0, cartesian_orig.x)) * (1.0 - in_States.x * in_States.x * in_States.x);\n"
// aura's geometric falloff
"float aura_point_dist = length(cartesian_orig);\n"
// falloff_aura: formula is for the outer edge. transitions to softness quickly and then back to hard after transition is complete.
"float falloff_aura = mix(1.0, smoothstep(1.0, 0.9, aura_point_dist), state_3a);\n"
"falloff_aura = mix(falloff_aura, 1.0, state_3d);\n"
// waitingMap
"float map_x = abs(theta_geom.x * r_geom.x);\n"
"float waitingMap = clamp(FastSin((map_x + in_States.x * 1.5 - 1.0) * pi), 0.0, 1.0);\n"
"waitingMap *= 1.0 - 0.6 * state_0 * state_0;\n"
// listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
"float listeningMap = smoothstep(-0.75, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.75, cartesian_orig.x);\n"
// apply height to listening map.
"listeningMap *= height;\n"
"listeningMap *= (state_1 + state_0);\n"
// thinkingMap: Curved ping-pong
"float pingPong = FastSin(time * kFastTimeMultiplier) * 0.9;\n"
"float leftScale = max(0.0, FastSin(time * kFastTimeMultiplier + 0.4 * pi));\n"
"leftScale = (leftScale * leftScale * 0.9 + 0.1) * 0.9;\n"
"float rightScale = max(0.0, FastSin(time * kFastTimeMultiplier - 0.6 * pi));\n"
"rightScale = (rightScale * rightScale * 0.9 + 0.1) * 0.9;\n"
"float thinkingMap = smoothstep(pingPong - leftScale, pingPong, abs_q_orig_ndc) * smoothstep(pingPong + rightScale, pingPong, abs_q_orig_ndc) * kThinkingHeightMax;\n"
"thinkingMap *= state_2;\n"
// mirroredSine for thinking map
"float mirroredSineMap = clamp(FastSin((map_x + (1.0 - in_States.z) * 2.0 - 1.0) * pi), 0.0, 1.0);\n"
"mirroredSineMap *= 0.3;\n"
"thinkingMap += mirroredSineMap;\n"
// mapSum (sum of all maps)
"float mapSum = mix(waitingMap + listeningMap + thinkingMap, 1.0, state_3a);\n"
// noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
"vec2 cartesian_noise = theta_noise * r_geom;\n"
"float noiseFrequency = ((0.00267 + height * 0.004) * (state_0 + state_1) + 0.001333 * state_2) * min(500.0 , max(in_FittedBounds.z, 200.0)) + state_3a * 0.4;\n"
"float noise0 = snoise(vec3(cartesian_noise * noiseFrequency, zTime));\n"
"float noise1 = snoise(vec3(cartesian_noise * noiseFrequency, zTime + 1.0));\n"
"float noise2 = snoise(vec3(cartesian_noise * noiseFrequency, zTime + 2.0));\n"
// clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
"float abs_noise0 = abs(noise0);\n"
"float abs_noise1 = abs(noise1);\n"
"float abs_noise2 = abs(noise2);\n"
"float abs_noise = max(max(abs_noise0, abs_noise1), abs_noise2);\n"
// noise and mapSum applied to r. re-application of scale. Multiplying device_pixel by 2.0 to gain two "aa-shaded" pixels (after fragment's smoothstep).
"r_geom.y = mix(max(mapSum * abs_noise * scale.y, device_pixel.y * 2.0 * state_1), r_geom.y, state_3b);\n"
// Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
"vec2 cartesian_geom = theta_geom * r_geom + center;\n"
"vec3 wave_alpha = (1.0 - mapSum * vec3(abs_noise0, abs_noise1, abs_noise2) * 0.95);\n"
"wave_alpha *= wave_alpha;\n"
// output.
"gl_Position = vec4(cartesian_geom, 0.0, 1.0);\n"
"out_ChannelCoord = max(mapSum * vec3(abs_noise0, abs_noise1, abs_noise2) * (in_FittedBounds.w * 0.5) * in_ViewportDim_ScreenScale_UnitLength.z, 2.0 * state_1);\n"
"out_ColorNoise = 1.0 - (1.0 - vec3(1.0, 0.176, 0.333) * noise0) * (1.0 - vec3(0.251, 1.0, 0.639) * noise1) * (1.0 - vec3(0.0, 0.478, 1.0) * noise2);\n" // screen
"out_Alpha3f = wave_alpha * wave_falloff * globalAlpha;\n"
"out_Alpha1f = max(out_ColorNoise.x, max(out_ColorNoise.y, out_ColorNoise.z)) * 0.4 * falloff_aura * globalAlpha;\n"
"out_CenterY = (in_ViewportDim_ScreenScale_UnitLength.y - (in_FittedBounds.y + (in_FittedBounds.w * 0.5)) * in_ViewportDim_ScreenScale_UnitLength.z);\n"
//"gl_Position = vec4(cartesian.x, cartesian.y * abs_noise * tail, 0.0, 1.0);\n" // thinking test
//"gl_Position = vec4(abs_q_orig_ndc, step(-1.0, abs_q_orig_ndc) * step(abs_q_orig_ndc, -0.75) * step(0.0, sin_q) * 0.5 * state_0 +" // state test
//"                           step(-0.75, abs_q_orig_ndc) * step(abs_q_orig_ndc, -0.5) * step(0.0, sin_q) * 0.5 * state_1 +" // state test
//"                           step(-0.5, abs_q_orig_ndc) * step(abs_q_orig_ndc, -0.25) * step(0.0, sin_q) * 0.5 * state_2 +" // state test
//"                           step(-0.25, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.0) * step(0.0, sin_q) * 0.5 * state_3a +" // state test
//"                           step(0.0, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.25) * step(0.0, sin_q) * 0.5 * state_3b +"  // state test
//"                           step(0.25, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.5) * step(0.0, sin_q) * 0.5 * state_3c +"  // state test
//"                           step(0.5, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.75) * step(0.0, sin_q) * 0.5 * state_3d +"  // state test
//"                           step(0.75, abs_q_orig_ndc) * step(abs_q_orig_ndc, 1.0) * step(0.0, sin_q) * 0.5 * 0.0,"        // state test
//"                           0.0, 1.0);\n"                                                             // state test
//"gl_Position = vec4(vec2(cos(in_Polar.y), sin(in_Polar.y)), 0.0, 1.0);\n" // pure geometry test
"}\n"
"";
static const GLchar*  siriFlameAccessibilityVertexShader =
"#version 100\n"
"#extension GL_EXT_separate_shader_objects : enable\n"
"\n"
"layout(location = 0) attribute vec4 in_Polar;\n"
"layout(location = 1) attribute vec4 in_ViewportDim_ScreenScale_UnitLength;\n"
"layout(location = 2) attribute vec4 in_FittedBounds;\n"
"layout(location = 3) attribute vec4 in_Time_ZTime_Height_Alpha;\n"
"layout(location = 4) attribute vec4 in_States;\n" // idle:x,listening:y,thinking:z,aura:w
"\n"
"varying mediump vec3 out_ChannelCoord;\n"
"varying mediump vec3 out_ColorNoise;\n"
"varying mediump vec3 out_Alpha3f;\n"
"varying mediump float out_Alpha1f;\n"
"varying mediump float out_CenterY;\n"
"\n"
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//
"vec3 mod289(vec3 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 mod289(vec4 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 permute(vec4 x) {\n"
"return mod289(((x*34.0)+1.0)*x);\n"
"}\n"
"vec4 taylorInvSqrt(vec4 r)\n"
"{\n"
"return 1.79284291400159 - 0.85373472095314 * r;\n"
"}\n"
"float snoise(vec3 v)\n"
"{\n"
"const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;\n"
"const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);\n"
// First corner
"vec3 i  = floor(v + dot(v, C.yyy) );\n"
"vec3 x0 =   v - i + dot(i, C.xxx) ;\n"
// Other corners
"vec3 g = step(x0.yzx, x0.xyz);\n"
"vec3 l = 1.0 - g;\n"
"vec3 i1 = min( g.xyz, l.zxy );\n"
"vec3 i2 = max( g.xyz, l.zxy );\n"
//   x0 = x0 - 0.0 + 0.0 * C.xxx;
//   x1 = x0 - i1  + 1.0 * C.xxx;
//   x2 = x0 - i2  + 2.0 * C.xxx;
//   x3 = x0 - 1.0 + 3.0 * C.xxx;
"vec3 x1 = x0 - i1 + C.xxx;\n"
"vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y\n"
"vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y\n"
// Permutations
"i = mod289(i);\n"
"vec4 p = permute( permute( permute(\n"
"i.z + vec4(0.0, i1.z, i2.z, 1.0 ))\n"
"+ i.y + vec4(0.0, i1.y, i2.y, 1.0 ))\n"
"+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));\n"
// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
"float n_ = 0.142857142857; // 1.0/7.0\n"
"vec3  ns = n_ * D.wyz - D.xzx;\n"
"vec4 j = p - 49.0 * floor(p * ns.z * ns.z);\n"  //  mod(p,7*7)
"vec4 x_ = floor(j * ns.z);\n"
"vec4 y_ = floor(j - 7.0 * x_ );\n"    // mod(j,N)
"vec4 x = x_ *ns.x + ns.yyyy;\n"
"vec4 y = y_ *ns.x + ns.yyyy;\n"
"vec4 h = 1.0 - abs(x) - abs(y);\n"
"vec4 b0 = vec4( x.xy, y.xy );\n"
"vec4 b1 = vec4( x.zw, y.zw );\n"
//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
"vec4 s0 = floor(b0)*2.0 + 1.0;\n"
"vec4 s1 = floor(b1)*2.0 + 1.0;\n"
"vec4 sh = -step(h, vec4(0.0));\n"
"vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;\n"
"vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;\n"
"vec3 p0 = vec3(a0.xy,h.x);\n"
"vec3 p1 = vec3(a0.zw,h.y);\n"
"vec3 p2 = vec3(a1.xy,h.z);\n"
"vec3 p3 = vec3(a1.zw,h.w);\n"
//Normalise gradients
"vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));\n"
"p0 *= norm.x;\n"
"p1 *= norm.y;\n"
"p2 *= norm.z;\n"
"p3 *= norm.w;\n"
// Mix final noise value
"vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);\n"
"m = m * m;\n"
"return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),\n"
"dot(p2,x2), dot(p3,x3) ) );\n"
"}\n"
"const float kThinkingHeightMax = 0.45;\n" // kThinkingHeightMax: max peak of thinking waves 0 <-> 1
"const float kFastTimeMultiplier = 4.4;\n" // fast sine time for speed of thinking waves
"const float pi = 3.1415926535;\n"
"float FastSin( float rad )\n"
"{\n"
"   float x = mod(rad, 2.0 * pi) - pi;\n"
"   return (-4.0/(pi*pi)) * x * (pi - abs(x));\n"
"}\n"
"float FastCos( float rad )\n"
"{\n"
"   return FastSin(rad + pi * 0.5);\n"
"}\n"
"\n"
"void main(void)\n"
"{\n"
"\n"
// ATTRIBUTES
"float time =   in_Time_ZTime_Height_Alpha.x;\n"
"float zTime =  in_Time_ZTime_Height_Alpha.y;\n"
"float height = in_Time_ZTime_Height_Alpha.z;\n"  // 0 <-> 1
"float globalAlpha = in_Time_ZTime_Height_Alpha.w;\n"
"float r_orig = in_Polar.x;\n"
"float q_orig = in_Polar.y;\n"
//"float r_noise = in_Polar.z;\n" // not in use
"float q_noise = in_Polar.w;\n"
// UNITS
"vec2 scale = in_FittedBounds.zw / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z);\n"
"vec2 center = (in_FittedBounds.xy + (in_FittedBounds.zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z) * 2.0 - 1.0;\n"
"center.y = -center.y;\n" // flip y
"vec2 device_pixel = 2.0 / in_ViewportDim_ScreenScale_UnitLength.xy;\n"
// RATIOS
"float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;\n"
"float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;\n"
"float sin_q = FastSin(q_orig);\n"
"float cos_q = FastCos(q_orig);\n"
// STATES
"float state_0 = smoothstep(0.0, 1.0, in_States.x);\n"
"float state_1 = smoothstep(0.0, 1.0, in_States.y);\n"
"float state_2 = smoothstep(0.0, 1.0, in_States.z);\n"
// state_3 uses 3 smoothed values to order aspects of the transition that may need to happen sooner than something else.
"float state_3_fadeOut =    smoothstep(0.0, 0.25, in_States.w);\n"
"float state_3_change =     smoothstep(0.25, 0.5, in_States.w);\n"
"float state_3_fadeIn =     smoothstep(0.5, 1.0, in_States.w);\n"
// COORDINATES
"vec2 theta_geom = mix(vec2(abs_q_orig_ndc, sign(sin_q)), vec2(cos_q, sin_q), state_3_change);\n"
"vec2 theta_noise = mix(vec2(abs_q_noise_ndc, sign(sin_q)), vec2(cos_q, sin_q), state_3_change);\n"
"vec2 cartesian_orig = theta_geom * r_orig;\n"
"vec2 r_geom = mix(vec2(r_orig * (1.0 - state_0), 0.0) * scale, vec2(r_orig * distance(center, vec2(1.0))), state_3_change);\n" // r for noise and geometry
// wave's geometric falloff
"float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_orig.x) - smoothstep(0.5, 1.0, cartesian_orig.x)) * (1.0 - in_States.x * in_States.x * in_States.x);\n"
// aura's geometric falloff
"float aura_point_dist = length(cartesian_orig);\n"
// falloff_aura: formula is for the outer edge. transitions to softness quickly and then back to hard after transition is complete.
"float falloff_aura = mix(1.0, smoothstep(1.0, 0.9, aura_point_dist), state_3_change);\n"
"falloff_aura = mix(falloff_aura, 1.0, state_3_change);\n"
// listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
"float listeningMap = smoothstep(-0.75, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.75, cartesian_orig.x);\n"
// apply height to listening map.
"listeningMap *= height;\n"
"listeningMap *= (state_1 + state_0);\n"
// thinkingMap: Breathing
"float thinkingMap = smoothstep(-0.3, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.3, cartesian_orig.x);\n"
"thinkingMap *= state_2 * ((FastSin(time * kFastTimeMultiplier) + 2.0) * 0.5 * kThinkingHeightMax);\n"
// mapSum (sum of all maps)
"float mapSum = mix(listeningMap + thinkingMap, 1.0, state_3_change);\n"
// noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
"vec2 cartesian_noise = theta_noise * r_geom;\n"
"float noiseFrequency = ((0.00267 + height * 0.004) * (state_0 + state_1) + 0.00267 * state_2) * min(500.0 , max(in_FittedBounds.z, 200.0)) + state_3_change * 0.4;\n"
"float noise0 = snoise(vec3(cartesian_noise * noiseFrequency, zTime));\n"
"float noise1 = snoise(vec3(cartesian_noise * noiseFrequency, zTime + 1.0));\n"
"float noise2 = snoise(vec3(cartesian_noise * noiseFrequency, zTime + 2.0));\n"
// clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
"float abs_noise0 = abs(noise0);\n"
"float abs_noise1 = abs(noise1);\n"
"float abs_noise2 = abs(noise2);\n"
"float abs_noise = max(max(abs_noise0, abs_noise1), abs_noise2);\n"
// noise and mapSum applied to r. re-application of scale. Multiplying device_pixel by 2.0 to gain two "aa-shaded" pixels (after fragment's smoothstep).
"r_geom.y = mix(max(mapSum * abs_noise * scale.y, device_pixel.y * 2.0 * (state_1 + state_2)), r_geom.y, state_3_change);\n"
// Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
"vec2 cartesian_geom = theta_geom * r_geom + center;\n"
"vec3 wave_alpha = (1.0 - mapSum * vec3(abs_noise0, abs_noise1, abs_noise2) * 0.95);\n"
"wave_alpha *= wave_alpha;\n"
// output.
"gl_Position = vec4(cartesian_geom, 0.0, 1.0);\n"
"out_ChannelCoord = max(mapSum * vec3(abs_noise0, abs_noise1, abs_noise2) * (in_FittedBounds.w * 0.5) * in_ViewportDim_ScreenScale_UnitLength.z, 2.0 * (state_1 + state_2));\n"
"out_ColorNoise = 1.0 - (1.0 - vec3(1.0, 0.176, 0.333) * noise0) * (1.0 - vec3(0.251, 1.0, 0.639) * noise1) * (1.0 - vec3(0.0, 0.478, 1.0) * noise2);\n" // screen
"out_Alpha3f = wave_alpha * wave_falloff * globalAlpha * (1.0 - state_3_fadeOut);\n"
"out_Alpha1f = max(out_ColorNoise.x, max(out_ColorNoise.y, out_ColorNoise.z)) * 0.4 * falloff_aura * (globalAlpha * state_3_fadeIn);\n"
"out_CenterY = (in_ViewportDim_ScreenScale_UnitLength.y - (in_FittedBounds.y + (in_FittedBounds.w * 0.5)) * in_ViewportDim_ScreenScale_UnitLength.z);\n"
//"gl_Position = vec4(cartesian.x, cartesian.y * abs_noise * tail, 0.0, 1.0);\n" // thinking test
//"gl_Position = vec4(abs_q_orig_ndc, step(-1.0, abs_q_orig_ndc) * step(abs_q_orig_ndc, -0.75) * step(0.0, sin_q) * 0.5 * state_0 +" // state test
//"                           step(-0.75, abs_q_orig_ndc) * step(abs_q_orig_ndc, -0.5) * step(0.0, sin_q) * 0.5 * state_1 +" // state test
//"                           step(-0.5, abs_q_orig_ndc) * step(abs_q_orig_ndc, -0.25) * step(0.0, sin_q) * 0.5 * state_2 +" // state test
//"                           step(-0.25, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.0) * step(0.0, sin_q) * 0.5 * state_3a +" // state test
//"                           step(0.0, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.25) * step(0.0, sin_q) * 0.5 * state_3b +"  // state test
//"                           step(0.25, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.5) * step(0.0, sin_q) * 0.5 * state_3c +"  // state test
//"                           step(0.5, abs_q_orig_ndc) * step(abs_q_orig_ndc, 0.75) * step(0.0, sin_q) * 0.5 * state_3d +"  // state test
//"                           step(0.75, abs_q_orig_ndc) * step(abs_q_orig_ndc, 1.0) * step(0.0, sin_q) * 0.5 * 0.0,"        // state test
//"                           0.0, 1.0);\n"                                                             // state test
//"gl_Position = vec4(vec2(cos(in_Polar.y), sin(in_Polar.y)), 0.0, 1.0);\n" // pure geometry test
"}\n"
"";
static const GLchar*  siriFlameFragmentShader =
"#version 100\n"
"\n"
"varying mediump vec3 out_ChannelCoord;\n"
"varying mediump vec3 out_Alpha3f;\n"
"varying mediump float out_CenterY;\n"
"\n"
"void main(void)\n"
"{\n"
"   mediump float p = abs(gl_FragCoord.y - out_CenterY);\n"
// intentionally passing outside geometry (for outermost coord) to allow msaa to do its job.
// not passing outside the geometry. if msaa is off.
"   mediump vec3 wave_channel = smoothstep(out_ChannelCoord, out_ChannelCoord - 2.0, vec3(p));\n"
// final 3 wave colors
// vec3(1.0, 0.176, 0.333)
// vec3(0.251, 1.0, 0.639)
// vec3(0.0, 0.478, 1.0)
"   mediump vec4 xColor = vec4(1.0, 0.176, 0.333, out_Alpha3f.x) * wave_channel.x;\n"
"   mediump vec4 yColor = vec4(0.251, 1.0, 0.639, out_Alpha3f.y) * wave_channel.y;\n"
"   mediump vec4 zColor = vec4(0.0, 0.478, 1.0, out_Alpha3f.z) * wave_channel.z;\n"
"   gl_FragColor = 1.0 - (1.0 - xColor) * (1.0 - yColor) * (1.0 - zColor);\n"
"}\n"
"";
// works only with flame vertex shader.
static const GLchar*  siriAuraFragmentShader =
"#version 100\n"
"\n"
"varying mediump vec3 out_ColorNoise;\n"
"varying mediump float out_Alpha1f;\n"
"\n"
"void main(void)\n"
"{\n"
"   gl_FragColor = vec4(out_ColorNoise, out_Alpha1f);\n"
"}\n"
"";
#pragma mark - Shaders for SUICWaveViewMode 2
static const GLchar*  siriTrainingVertexShader =
"#version 100\n"
"#extension GL_EXT_separate_shader_objects : enable\n"
"\n"
"layout(location = 0) attribute vec4 in_Polar;\n"
"layout(location = 1) attribute vec4 in_ViewportDim_ScreenScale_UnitLength;\n"
"layout(location = 2) attribute vec4 in_FittedBounds;\n"
"layout(location = 3) attribute vec4 in_Time_ZTime_Height_Alpha;\n"
"layout(location = 4) attribute vec4 in_States;\n" // idle:x,listening:y,thinking:z,aura:w
"\n"
"varying mediump vec3 out_ChannelCoord;\n"
"varying mediump vec3 out_Alpha3f;\n"
"varying mediump float out_Alpha1f;\n"
"varying mediump float out_CenterY;\n"
"\n"
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//
"vec3 mod289(vec3 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 mod289(vec4 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 permute(vec4 x) {\n"
"return mod289(((x*34.0)+1.0)*x);\n"
"}\n"
"vec4 taylorInvSqrt(vec4 r)\n"
"{\n"
"return 1.79284291400159 - 0.85373472095314 * r;\n"
"}\n"
"float snoise(vec3 v)\n"
"{\n"
"const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;\n"
"const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);\n"
// First corner
"vec3 i  = floor(v + dot(v, C.yyy) );\n"
"vec3 x0 =   v - i + dot(i, C.xxx) ;\n"
// Other corners
"vec3 g = step(x0.yzx, x0.xyz);\n"
"vec3 l = 1.0 - g;\n"
"vec3 i1 = min( g.xyz, l.zxy );\n"
"vec3 i2 = max( g.xyz, l.zxy );\n"
//   x0 = x0 - 0.0 + 0.0 * C.xxx;
//   x1 = x0 - i1  + 1.0 * C.xxx;
//   x2 = x0 - i2  + 2.0 * C.xxx;
//   x3 = x0 - 1.0 + 3.0 * C.xxx;
"vec3 x1 = x0 - i1 + C.xxx;\n"
"vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y\n"
"vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y\n"
// Permutations
"i = mod289(i);\n"
"vec4 p = permute( permute( permute(\n"
"i.z + vec4(0.0, i1.z, i2.z, 1.0 ))\n"
"+ i.y + vec4(0.0, i1.y, i2.y, 1.0 ))\n"
"+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));\n"
// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
"float n_ = 0.142857142857; // 1.0/7.0\n"
"vec3  ns = n_ * D.wyz - D.xzx;\n"
"vec4 j = p - 49.0 * floor(p * ns.z * ns.z);\n"  //  mod(p,7*7)
"vec4 x_ = floor(j * ns.z);\n"
"vec4 y_ = floor(j - 7.0 * x_ );\n"    // mod(j,N)
"vec4 x = x_ *ns.x + ns.yyyy;\n"
"vec4 y = y_ *ns.x + ns.yyyy;\n"
"vec4 h = 1.0 - abs(x) - abs(y);\n"
"vec4 b0 = vec4( x.xy, y.xy );\n"
"vec4 b1 = vec4( x.zw, y.zw );\n"
//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
"vec4 s0 = floor(b0)*2.0 + 1.0;\n"
"vec4 s1 = floor(b1)*2.0 + 1.0;\n"
"vec4 sh = -step(h, vec4(0.0));\n"
"vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;\n"
"vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;\n"
"vec3 p0 = vec3(a0.xy,h.x);\n"
"vec3 p1 = vec3(a0.zw,h.y);\n"
"vec3 p2 = vec3(a1.xy,h.z);\n"
"vec3 p3 = vec3(a1.zw,h.w);\n"
//Normalise gradients
"vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));\n"
"p0 *= norm.x;\n"
"p1 *= norm.y;\n"
"p2 *= norm.z;\n"
"p3 *= norm.w;\n"
// Mix final noise value
"vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);\n"
"m = m * m;\n"
"return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),\n"
"dot(p2,x2), dot(p3,x3) ) );\n"
"}\n"
"const float kThinkingHeightMax = 0.2;\n" // kThinkingHeightMax: max peak of thinking waves 0 <-> 1
"const float kFastTimeMultiplier = 4.4;\n" // fast sine time for speed of thinking waves
"const float pi = 3.1415926535;\n"
"float FastSin( float rad )\n"
"{\n"
"   float x = mod(rad, 2.0 * pi) - pi;\n"
"   return (-4.0/(pi*pi)) * x * (pi - abs(x));\n"
"}\n"
"float FastCos( float rad )\n"
"{\n"
"   return FastSin(rad + pi * 0.5);\n"
"}\n"
"\n"
"void main(void)\n"
"{\n"
"\n"
// ATTRIBUTES
"float time =   in_Time_ZTime_Height_Alpha.x;\n"
"float zTime =  in_Time_ZTime_Height_Alpha.y;\n"
"float height = in_Time_ZTime_Height_Alpha.z;\n"  // 0 <-> 1
"float globalAlpha = in_Time_ZTime_Height_Alpha.w;\n"
"float r_orig = in_Polar.x;\n"
"float q_orig = in_Polar.y;\n"
//"float r_noise = in_Polar.z;\n" // not in use
"float q_noise = in_Polar.w;\n"
// UNITS
"vec2 scale = in_FittedBounds.zw / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z);\n"
"vec2 center = (in_FittedBounds.xy + (in_FittedBounds.zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z) * 2.0 - 1.0;\n"
"center.y = -center.y;\n" // flip y
"vec2 device_pixel = 2.0 / in_ViewportDim_ScreenScale_UnitLength.xy;\n"
// RATIOS
"float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;\n"
"float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;\n"
"float sin_q = FastSin(q_orig);\n"
"float cos_q = FastCos(q_orig);\n"
// STATES
"float state_0 = smoothstep(0.0, 1.0, in_States.x);\n"
"float state_1 = smoothstep(0.0, 1.0, in_States.y);\n"
"float state_2 = smoothstep(0.0, 1.0, in_States.z);\n"
// state_3 will not be used for this particular pipeline
// COORDINATES
"vec2 theta_geom = vec2(abs_q_orig_ndc, sign(sin_q));\n"
"vec2 theta_noise = vec2(abs_q_noise_ndc, sign(sin_q));\n"
"vec2 cartesian_orig = theta_geom * r_orig;\n"
"vec2 r_geom = vec2(r_orig * (1.0 - state_0), 0.0) * scale;\n" // r for noise and geometry
// wave's geometric falloff
"float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_orig.x) - smoothstep(0.5, 1.0, cartesian_orig.x)) * (1.0 - in_States.x * in_States.x * in_States.x);\n"
// waitingMap
"float map_x = abs(theta_geom.x * r_geom.x);\n"
"float waitingMap = clamp(FastSin((map_x + in_States.x * 1.5 - 1.0) * pi), 0.0, 1.0);\n"
"waitingMap *= 1.0 - 0.6 * state_0 * state_0;\n"
// listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
"float listeningMap = smoothstep(-0.75, 0.0, cartesian_orig.x) - smoothstep(0.0, 0.75, cartesian_orig.x);\n"
// apply height to listening map.
"listeningMap *= height;\n"
"listeningMap *= (state_1 + state_0);\n"
// thinkingMap: Curved ping-pong
"float pingPong = FastSin(time * kFastTimeMultiplier) * 0.9;\n"
"float leftScale = max(0.0, FastSin(time * kFastTimeMultiplier + 0.4 * pi));\n"
"leftScale = (leftScale * leftScale * 0.9 + 0.1) * 0.9;\n"
"float rightScale = max(0.0, FastSin(time * kFastTimeMultiplier - 0.6 * pi));\n"
"rightScale = (rightScale * rightScale * 0.9 + 0.1) * 0.9;\n"
"float thinkingMap = smoothstep(pingPong - leftScale, pingPong, abs_q_orig_ndc) * smoothstep(pingPong + rightScale, pingPong, abs_q_orig_ndc) * kThinkingHeightMax;\n"
"thinkingMap *= state_2;\n"
// mirroredSine for thinking map
"float mirroredSineMap = clamp(FastSin((map_x + (1.0 - in_States.z) * 2.0 - 1.0) * pi), 0.0, 1.0);\n"
"mirroredSineMap *= 0.5;\n"
"thinkingMap += mirroredSineMap;\n"
// mapSum (sum of all maps)
"float mapSum = waitingMap + listeningMap + thinkingMap;\n"
// noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
"vec2 cartesian_noise = theta_noise * r_geom;\n"
"float noiseFrequency = ((0.00267 + height * 0.004) * (state_0 + state_1) + 0.001333 * state_2) * min(500.0 , max(in_FittedBounds.z, 200.0));\n"
"float noise0 = snoise(vec3(cartesian_noise * noiseFrequency, zTime));\n"
"float noise1 = snoise(vec3(cartesian_noise * noiseFrequency, zTime + 1.0));\n"
"float noise2 = snoise(vec3(cartesian_noise * noiseFrequency, zTime + 2.0));\n"
// clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
"float abs_noise0 = abs(noise0);\n"
"float abs_noise1 = abs(noise1);\n"
"float abs_noise2 = abs(noise2);\n"
"float abs_noise = max(max(abs_noise0, abs_noise1), abs_noise2);\n"
// noise and mapSum applied to r. re-application of scale. Multiplying device_pixel by 2.0 to gain two "aa-shaded" pixels (after fragment's smoothstep).
"r_geom.y = max(mapSum * abs_noise * scale.y, device_pixel.y * 2.0 * state_1);\n"
// Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
"vec2 cartesian_geom = theta_geom * r_geom + center;\n"
"vec3 wave_alpha = (1.0 - mapSum * vec3(abs_noise0, abs_noise1, abs_noise2) * 0.95);\n"
"wave_alpha *= wave_alpha;\n"
// output.
"gl_Position = vec4(cartesian_geom, 0.0, 1.0);\n"
"out_ChannelCoord = max(mapSum * vec3(abs_noise0, abs_noise1, abs_noise2) * (in_FittedBounds.w * 0.5) * in_ViewportDim_ScreenScale_UnitLength.z, 2.0 * state_1);\n"
"out_Alpha3f = wave_alpha * globalAlpha;\n"
"out_Alpha1f = wave_falloff * globalAlpha;\n"
"out_CenterY = (in_ViewportDim_ScreenScale_UnitLength.y - (in_FittedBounds.y + (in_FittedBounds.w * 0.5)) * in_ViewportDim_ScreenScale_UnitLength.z);\n"
"}\n"
"";
static const GLchar*  siriTrainingFragmentShader =
"#version 100\n"
"\n"
"varying mediump vec3 out_ChannelCoord;\n"
"varying mediump vec3 out_Alpha3f;\n"
"varying mediump float out_Alpha1f;\n"
"varying mediump float out_CenterY;\n"
"\n"
"void main(void)\n"
"{\n"
"   mediump float p = abs(gl_FragCoord.y - out_CenterY);\n"
// intentionally passing outside geometry (for outermost coord) to allow msaa to do its job.
// not passing outside the geometry. if msaa is off.
"   mediump vec3 wave_channel = smoothstep(out_ChannelCoord, out_ChannelCoord - 2.0, vec3(p));\n"
// final 3 wave colors
// vec3(1.0, 0.286, 0.333)
// vec3(0.298, 0.85, 0.39)
// vec3(0.0, 0.478, 1.0)
// For brighter peaks.
"   mediump vec4 colorModifier = vec4(0.3,0.3,0.3,0.0);\n"
"   mediump vec4 xColor = (vec4(1.0, 0.286, 0.333, out_Alpha1f) + colorModifier * (1.0 - out_Alpha3f.x)) * wave_channel.x;\n"
"   mediump vec4 yColor = (vec4(0.298, 0.85, 0.39, out_Alpha1f) + colorModifier * (1.0 - out_Alpha3f.y)) * wave_channel.y;\n"
"   mediump vec4 zColor = (vec4(0.0, 0.478, 1.0, out_Alpha1f) + colorModifier * (1.0 - out_Alpha3f.z)) * wave_channel.z;\n"
"   mediump vec4 screen = 1.0 - (1.0 - xColor) * (1.0 - yColor) * (1.0 - zColor);\n"
//"   mediump vec4 additive = xColor + yColor + zColor;\n"
"   gl_FragColor = screen;\n"
"}\n"
"";
#pragma mark - Shaders for SUICWaveViewMode 1
static const GLchar*  siriDictationVertexShader =
"#version 100\n"
"#extension GL_EXT_separate_shader_objects : enable\n"
"\n"
"layout(location = 0) attribute vec4 in_Polar;\n"
"layout(location = 1) attribute vec4 in_ViewportDim_ScreenScale_UnitLength;\n"
"layout(location = 2) attribute vec4 in_FittedBounds;\n"
"layout(location = 3) attribute vec4 in_Time_ZTime_Height_Alpha;\n"
"layout(location = 4) attribute vec4 in_States;\n" // idle:x,listening:y,thinking:z,aura:w
"layout(location = 5) attribute vec3 in_FragmentColor;\n"
"\n"
"varying mediump vec4 out_Height_Center_Alpha_UnitSize;\n"
"varying mediump vec4 out_Viewport;\n"
"varying mediump vec4 out_FittedBounds;\n"
"varying mediump vec3 out_FragmentColor;\n"
"\n"
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//
"vec3 mod289(vec3 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 mod289(vec4 x) {\n"
"return x - floor(x * (1.0 / 289.0)) * 289.0;\n"
"}\n"
"vec4 permute(vec4 x) {\n"
"return mod289(((x*34.0)+1.0)*x);\n"
"}\n"
"vec4 taylorInvSqrt(vec4 r)\n"
"{\n"
"return 1.79284291400159 - 0.85373472095314 * r;\n"
"}\n"
"float snoise(vec3 v)\n"
"{\n"
"const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;\n"
"const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);\n"
// First corner
"vec3 i  = floor(v + dot(v, C.yyy) );\n"
"vec3 x0 =   v - i + dot(i, C.xxx) ;\n"
// Other corners
"vec3 g = step(x0.yzx, x0.xyz);\n"
"vec3 l = 1.0 - g;\n"
"vec3 i1 = min( g.xyz, l.zxy );\n"
"vec3 i2 = max( g.xyz, l.zxy );\n"
//   x0 = x0 - 0.0 + 0.0 * C.xxx;
//   x1 = x0 - i1  + 1.0 * C.xxx;
//   x2 = x0 - i2  + 2.0 * C.xxx;
//   x3 = x0 - 1.0 + 3.0 * C.xxx;
"vec3 x1 = x0 - i1 + C.xxx;\n"
"vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y\n"
"vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y\n"
// Permutations
"i = mod289(i);\n"
"vec4 p = permute( permute( permute(\n"
"i.z + vec4(0.0, i1.z, i2.z, 1.0 ))\n"
"+ i.y + vec4(0.0, i1.y, i2.y, 1.0 ))\n"
"+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));\n"
// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
"float n_ = 0.142857142857; // 1.0/7.0\n"
"vec3  ns = n_ * D.wyz - D.xzx;\n"
"vec4 j = p - 49.0 * floor(p * ns.z * ns.z);\n"  //  mod(p,7*7)
"vec4 x_ = floor(j * ns.z);\n"
"vec4 y_ = floor(j - 7.0 * x_ );\n"    // mod(j,N)
"vec4 x = x_ *ns.x + ns.yyyy;\n"
"vec4 y = y_ *ns.x + ns.yyyy;\n"
"vec4 h = 1.0 - abs(x) - abs(y);\n"
"vec4 b0 = vec4( x.xy, y.xy );\n"
"vec4 b1 = vec4( x.zw, y.zw );\n"
//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
"vec4 s0 = floor(b0)*2.0 + 1.0;\n"
"vec4 s1 = floor(b1)*2.0 + 1.0;\n"
"vec4 sh = -step(h, vec4(0.0));\n"
"vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;\n"
"vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;\n"
"vec3 p0 = vec3(a0.xy,h.x);\n"
"vec3 p1 = vec3(a0.zw,h.y);\n"
"vec3 p2 = vec3(a1.xy,h.z);\n"
"vec3 p3 = vec3(a1.zw,h.w);\n"
//Normalise gradients
"vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));\n"
"p0 *= norm.x;\n"
"p1 *= norm.y;\n"
"p2 *= norm.z;\n"
"p3 *= norm.w;\n"
// Mix final noise value
"vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);\n"
"m = m * m;\n"
"return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),\n"
"dot(p2,x2), dot(p3,x3) ) );\n"
"}\n"
"const float kThinkingHeightMax = 0.2;\n" // kThinkingHeightMax: max peak of thinking waves 0 <-> 1
"const float kFastTimeMultiplier = 3.0;\n" // fast sine time for speed of thinking waves
"const float pi = 3.1415926535;\n"
"float FastSin( float rad )\n"
"{\n"
"   float x = mod(rad, 2.0 * pi) - pi;\n"
"   return (-4.0/(pi*pi)) * x * (pi - abs(x));\n"
"}\n"
"float FastCos( float rad )\n"
"{\n"
"   return FastSin(rad + pi * 0.5);\n"
"}\n"
"\n"
"void main(void)\n"
"{\n"
"\n"
// ATTRIBUTES
"float time =   in_Time_ZTime_Height_Alpha.x;\n"
"float zTime =  in_Time_ZTime_Height_Alpha.y;\n"
"float height = in_Time_ZTime_Height_Alpha.z;\n"  // 0 <-> 1
"float globalAlpha = in_Time_ZTime_Height_Alpha.w;\n"
"float r_orig = in_Polar.x;\n"
"float q_orig = in_Polar.y;\n"
//"float r_noise = in_Polar.z;\n" // not in use
"float q_noise = in_Polar.w;\n"
// UNITS
"vec2 scale = in_FittedBounds.zw / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z);\n"
"vec2 center = (in_FittedBounds.xy + (in_FittedBounds.zw * 0.5)) / (in_ViewportDim_ScreenScale_UnitLength.xy / in_ViewportDim_ScreenScale_UnitLength.z) * 2.0 - 1.0;\n"
"center.y = -center.y;\n" // flip y
"vec2 logical_pixel = 1.0 / (in_ViewportDim_ScreenScale_UnitLength.xy);\n"
// RATIOS
"float abs_q_orig_ndc = abs(q_orig - pi)/pi * 2.0 - 1.0;\n"
"float abs_q_noise_ndc = abs(q_noise - pi)/pi * 2.0 - 1.0;\n"
"float sin_q = FastSin(q_orig);\n"
"float cos_q = FastCos(q_orig);\n"
// STATES
"float state_0 = smoothstep(0.0, 1.0, in_States.x);\n"
"float state_1 = smoothstep(0.0, 1.0, in_States.y);\n"
// COORDINATES
"vec2 theta_geom = vec2(abs_q_orig_ndc, sign(sin_q));\n"
"vec2 theta_noise = vec2(abs_q_noise_ndc, sign(sin_q));\n"
"vec2 cartesian_orig = theta_geom * r_orig;\n"
"vec2 r_geom = vec2(r_orig * (1.0 - state_0), 0.0) * scale;\n" // r for noise and geometry
"vec2 cartesian_noise = theta_noise * r_geom;\n"
// wave's geometric falloff
//"float wave_falloff = (smoothstep(-1.0, -0.5, cartesian_noise.x) - smoothstep(0.5, 1.0, cartesian_noise.x)) * (1.0 - in_States.x * in_States.x * in_States.x);\n"
// waitingMap
"float map_x = abs(theta_geom.x * r_geom.x);\n"
"float waitingMap = clamp(FastSin((map_x + in_States.x * 1.5 - 1.0) * pi), 0.0, 1.0);\n"
"waitingMap *= 1.0 - 0.6 * state_0 * state_0;\n"
// listeningMap: double polynomial for tapering. when movingCenter is off from absolute center, this can optionally create an irregular left-to-right slope.
"float listeningMap = smoothstep(-1.0, -0.25, cartesian_noise.x) - smoothstep(0.25, 1.0, cartesian_noise.x);\n"
// apply height to listening map.
"listeningMap *= height;\n"
"listeningMap *= (state_1 + state_0);\n"
// mapSum (sum of all maps)
"float mapSum = waitingMap + listeningMap;\n"
// noise. Lower frequency = longer wavelengths. using true cartesian coords before screen transformation
"float noiseFrequency = (0.01 + height * 0.02) * (state_0 + state_1) * max(in_FittedBounds.z, 250.0);\n"
"float noise = snoise(vec3(cartesian_noise * noiseFrequency, zTime));\n"
// clamping noise from -1.0 <-> 1.0 to 0.0 <-> 1.0
"float abs_noise = abs(noise);\n"
// noise and mapSum applied to r. re-application of scale.
"r_geom.y = max(mapSum * abs_noise * scale.y, logical_pixel.y * in_ViewportDim_ScreenScale_UnitLength.z * 3.0);\n" // just make sure we have enough room to make a circle when there's no amplitude height.
// Final coordinates. mapping abs_noise, center to cartesian_geom, theta_geom
"vec2 cartesian_geom = theta_geom * r_geom;\n"
"cartesian_geom += center;\n"
// output.
"float y_center_window = in_ViewportDim_ScreenScale_UnitLength.y - (in_FittedBounds.y + (in_FittedBounds.w * 0.5)) * in_ViewportDim_ScreenScale_UnitLength.z;\n"
"float r_window = max(mapSum * abs_noise * (in_FittedBounds.w * 0.5) * in_ViewportDim_ScreenScale_UnitLength.z, 2.0);\n"
"gl_Position = vec4(cartesian_geom, 0.0, 1.0);\n"
"out_Height_Center_Alpha_UnitSize = vec4(r_window, y_center_window, globalAlpha, in_ViewportDim_ScreenScale_UnitLength.w);\n"
"out_Viewport = in_ViewportDim_ScreenScale_UnitLength;\n"
"out_FittedBounds = in_FittedBounds;\n"
"out_FragmentColor = in_FragmentColor;\n"
"}\n"
"";
static const GLchar*  siriDictationFragmentShader =
"#version 100\n"
"\n"
"varying mediump vec4 out_Height_Center_Alpha_UnitSize;\n"
"varying mediump vec4 out_Viewport;\n"
"varying mediump vec4 out_FittedBounds;\n"
"varying mediump vec3 out_FragmentColor;\n"
"\n"
"void main(void)\n"
"{\n"
"   mediump float unitSize = out_Height_Center_Alpha_UnitSize.w;\n"
"   mediump float halfUnitSize = unitSize * 0.5;\n"
"   mediump float halfLineSize = 0.25 + out_Viewport.z;\n" // 0.25 ensures that we stay above a threshold needed for smoothstep to generate a non-zero pixel appearance for 1x lines. This results in an appearance of linesize+1 for all devices.
"   mediump float halfLineSize_sq = halfLineSize*halfLineSize;\n"
"   mediump vec2 p = floor(vec2(mod(gl_FragCoord.x - (out_FittedBounds.x * out_Viewport.z) + halfUnitSize, unitSize) - halfUnitSize, abs(gl_FragCoord.y - out_Height_Center_Alpha_UnitSize.y) - max(0.0, out_Height_Center_Alpha_UnitSize.x - halfLineSize * 2.0)));\n" // mod p.x against the unitsize and center it in the geometry. // do abs for up and down to ensure equality. subtract the height. FLOOR EVERYTHING to snap to a pixel.
"   mediump float end = step(p.y, 0.0);\n" // we don't want x and d to overlap each other because adding them together if x is ever less than 100% opacity will result in a bad looking cap and more like a circle on top of a line.
// apply the following two lines together with the same smoothstep distance for edge1 to guarantee consistency between the cap and the line, then just add to alpha.
"   mediump float d = (1.0 - smoothstep(0.25, halfLineSize_sq, dot(p, p))) * (1.0 - end);\n"
"   mediump float x = (1.0 - smoothstep(halfLineSize_sq - 1.0, halfLineSize_sq, p.x*p.x)) * end;\n"
"   gl_FragColor = vec4(out_FragmentColor.x, out_FragmentColor.y, out_FragmentColor.z, (x+d)*out_Height_Center_Alpha_UnitSize.z);\n"
"}\n"
"";
#pragma mark - Structs
typedef struct {
    vector_float4 vertexLocation;
} Vertex;
#pragma mark - Macros
#define GL_VALIDATE( expr )     if ( success ) { ( expr ); success = ( GL_NO_ERROR == glGetError() ); }
#define SIZE_OF_ARRAY( array )  ( sizeof( array ) / sizeof ( array[0] ) )
static const float kGlobalAlphaFadeSpeedIncrement = 0.03; // varies how fast the aura fades out when a new one is incoming.
static const CGFloat kMinimumPowerLevel = 0.05; // determines the lowest the flames can go
static const CGFloat kMaximumPowerLevel = 1.0; // determines the highest the flames can go
static const int kNumPowerLevels = 5;
static NSString * const kSUICFlamesViewUIApplicationNotificationReason = @"kSUICFlamesViewUIApplicationNotificationReason";
static NSUInteger sIndexCacheSize = 5;
#pragma mark - Implementation
@implementation SUICFlamesViewLegacy {
    CADisplayLink *_displayLink;
    EAGLContext * _eaglContext;
    EAGLContext *_previousContext;
    NSInteger _currentContextCount;
    NSMutableSet *_renderingDisabledReasons;
    
    GLuint _framebufferHandle;
    GLuint _renderbufferHandle;
#if USE_SIRI_GL_MULTISAMPLE
    GLuint _msaaFBOName;
    GLuint _msaaRenderbuffer;
#endif
    GLint  _flameProgramHandle, _auraProgramHandle, _vShadID, _fShadID;
    GLuint _vertexArrayObjectHandle, _vertexBufferHandle, _elementArrayHandle;
    GLuint _numVertices;
    GLuint _numAuraIndices;
    GLuint _numAuraIndicesCulled;
    GLuint _numWaveIndices;
    
    // the following contribute to the complete VBO. set from fidelity setting
    GLuint _maxVertexCircles;
    GLuint _auraVertexCircles;
    GLfloat _maxSubdivisionLevel;
    GLfloat _auraMinSubdivisionLevel;
    GLfloat _auraMaxSubdivisionLevel;
    
    NSMutableArray *_flameGroups;
    SUICFlameGroup *_currentFlameGroup;
    
    GLint _viewWidth;
    GLint _viewHeight;
    GLfloat _dictationUnitSize;
    UIScreen *_screen;
    
    UIImageView *_overlayImageView;
    
    CFTimeInterval _startTime;
    
    CGFloat _dictationRedColor, _dictationGreenColor, _dictationBlueColor;
    
    SUICAudioLevelSmoother *_levelSmoother;
    SUICFlamesViewFidelity _fidelity;
    
    CGFloat _frameRateScalingFactor;
        
    BOOL _transitionFinished;
    
    BOOL _isInitialized;
    BOOL _hasCustomActiveFrame;
    BOOL _shadersAreCompiled;
    
    BOOL _reduceMotionEnabled;
};
@synthesize mode = _mode;
@synthesize state = _state;
@synthesize activeFrame = _activeFrame;
@synthesize horizontalScaleFactor = _horizontalScaleFactor;
@synthesize showAura = _showAura;
@synthesize freezesAura = _freezesAura;
@synthesize overlayImage = _overlayImage;
@synthesize flamesDelegate = _flamesDelegate;
@synthesize dictationColor = _dictationColor;
@synthesize renderInBackground = _renderInBackground;
@synthesize flamesPaused = _flamesPaused;
@synthesize accelerateTransitions = _accelerateTransitions;
@synthesize reduceFrameRate = _reduceFrameRate;
@synthesize reduceThinkingFramerate = _reduceThinkingFramerate;
- (void)_setValuesForFidelity:(SUICFlamesViewFidelity)fidelity {
    
    // forceably setting fidelity to needed fidelity for SUICWaveViewModeDictation
    if (_mode == SUICFlamesViewModeDictation) {
        _maxVertexCircles = 1;
        const CGFloat currentDisplayScale = [self _currentDisplayScale];
        float idealUnitSize = 6.0 * currentDisplayScale;
        
        // 3 * 2 ^ x. where x = (device-activeFrame-width * 2(upper and lower histogram vertex) / idealUnitSize).
        // value example for calulator: 3*2^((log(width * 2(screenscale) * 2(verts per histogram region) * 2(top and bottom) / 12 / 3))) / log(2))
        _maxSubdivisionLevel = logf(roundf(fmaxf(idealUnitSize, _activeFrame.size.width * currentDisplayScale * _horizontalScaleFactor) / idealUnitSize / 3.0f) * 4.0f) / logf(2);
        _dictationUnitSize = (_activeFrame.size.width * currentDisplayScale * _horizontalScaleFactor) / ((float)[self _numVerticesPerCircle] / 4.0);
        _auraVertexCircles = _maxVertexCircles;
        _auraMinSubdivisionLevel = 0;
        _auraMaxSubdivisionLevel = 0;
        return;
    }
    
    switch (fidelity) {
        // vertices in use for wave: 3*2^6 - 3*2^6 + 3*2^6
        // elements in use for wave: (3*2^6 - 3*2^6) * 3 + (3*2^6 - 2) (fill verts)
        // vertices in use for aura: 3*2^3 - 3*2^1 +         (6 - 3 - 1) *     3*2^3
        // elements in use for aura: (3*2^3 - 3*2^1) * 3 +   (6 - 1 - 3 - 1) * 3*2^3 * 2 + (3*2^1 - 2) (fill verts)
        case SUICFlamesViewFidelityLow:
            _maxVertexCircles = 6;
            _maxSubdivisionLevel = 6;
            _auraVertexCircles = _maxVertexCircles;
            _auraMinSubdivisionLevel = 1;
            _auraMaxSubdivisionLevel = 3;
            break;
            
        // vertices in use for wave: 3*2^7 - 3*2^7 + 3*2^7
        // elements in use for wave: (3*2^7 - 3*2^7) * 3 + (3*2^7 - 2) (fill verts)
        // vertices in use for aura: 3*2^3 - 3*2^1 +         (12 - 3 - 1) *     3*2^3
        // elements in use for aura: (3*2^3 - 3*2^1) * 3 +   (12 - 1 - 3 - 1) * 3*2^3 * 2 + (3*2^1 - 2) (fill verts)
        case SUICFlamesViewFidelityMedium:
            _maxVertexCircles = 12;
            _maxSubdivisionLevel = 7;
            _auraVertexCircles = _maxVertexCircles;
            _auraMinSubdivisionLevel = 1;
            _auraMaxSubdivisionLevel = 3;
            break;
            
        // vertices in use for wave: 3*2^8 - 3*2^8 + 3*2^8
        // elements in use for wave: (3*2^8 - 3*2^8) * 3 + (3*2^8 - 2) (fill verts)
        // vertices in use for aura: 3*2^4 - 3*2^1 +         (18 - 4 - 1) *     3*2^4
        // elements in use for aura: (3*2^4 - 3*2^1) * 3 +   (18 - 1 - 3 - 1) * 3*2^4 * 2 + (3*2^1 - 2) (fill verts)
        case SUICFlamesViewFidelityHigh:
            _maxVertexCircles = 18;
            _maxSubdivisionLevel = 8;
            _auraVertexCircles = _maxVertexCircles;
            _auraMinSubdivisionLevel = 1;
            _auraMaxSubdivisionLevel = 4;
            break;
    }
}
- (id)initWithFrame:(CGRect)frame screen:(UIScreen *)screen fidelity:(SUICFlamesViewFidelity)fidelity{
    self = [super initWithFrame:frame];
    if (self) {
        _reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled();
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reduceMotionStatusChanged:) name:UIAccessibilityReduceMotionStatusDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        _levelSmoother = [[SUICAudioLevelSmoother alloc] initWithMinimumPower:-60.0 maximumPower:-10.0 historyLength:kNumPowerLevels attackSpeed:0.35 decaySpeed:0.9];
        _screen = screen;
        _showAura = YES;
        [self setMode:SUICFlamesViewModeSiri];
        _fidelity = fidelity;
        [self _setValuesForFidelity:fidelity];
        
        _activeFrame = [self bounds];
        _currentContextCount = 0;
        
        _horizontalScaleFactor = 1.0;
        _frameRateScalingFactor = 1.0;
        
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_eaglContext) {
            return nil;
        }
        
        BOOL success = [self _setCurrentContext];
        if (!success) {
            [self _restoreCurrentContext];
            return nil;
        }
        [self _restoreCurrentContext];
        
        _state = SUICFlamesViewStateAboutToListen;
        
        _dictationRedColor = 1.0;
        _dictationGreenColor = 1.0;
        _dictationBlueColor = 1.0;
        
        _flameGroups = [[NSMutableArray alloc] init];
        _currentFlameGroup = [[SUICFlameGroup alloc] init];
        [_flameGroups addObject:_currentFlameGroup];
        
        _renderingDisabledReasons = [NSMutableSet set];
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame screenScale:(CGFloat)screenScale fidelity:(SUICFlamesViewFidelity)fidelity {
    return [self initWithFrame:frame screen:[UIScreen mainScreen] fidelity:fidelity];
}
- (void)dealloc {
    [self _tearDownDisplayLink];
    
    [self _cleanupGL];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self _restoreCurrentContext];
    
    _eaglContext = nil;
}
- (void)didMoveToSuperview {
    // required to avoid memory leak due to circular dependency
    if ([self superview] == nil) {
        [self _tearDownDisplayLink];
    } else {
        [self _setupDisplayLink];
        // Set UIKit properties here to ensure that they only are called when the
        // view is to be displayed and not as part of prewarming in background.
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
    }
}
+ (Class)layerClass {
    return [CAEAGLLayer class];
}
- (void)setFlamesDelegate:(id<SUICFlamesViewProvidingDelegate>)delegate {
    if (delegate == nil && _displayLink) {
        [self _tearDownDisplayLink];
    }
    
    _flamesDelegate = delegate;
}
- (void)setState:(SUICFlamesViewState)state {
    if (_state != state) {
        _transitionFinished = NO;
        _state = state;
        _currentFlameGroup.transitionPhase = _accelerateTransitions ? 0.25f : 0.0f;
        _currentFlameGroup.stateTime = 0.0f;
        if (state == SUICFlamesViewStateSuccess) {
            if (_showAura) {
                // set current to aura state before creating a new wave system
                _currentFlameGroup.isAura = YES;
                
                // for all other flames, we know they must be Auras, so set them to die off since we have a new aura.
                for (SUICFlameGroup *flames in _flameGroups) {
                    if (flames != _currentFlameGroup) {
                        flames.isDyingOff = YES;
                    }
                }
                _state = SUICFlamesViewStateAboutToListen;
                _currentFlameGroup = [[SUICFlameGroup alloc] init];
                [_flameGroups addObject:_currentFlameGroup];
            } else {
                _state = SUICFlamesViewStateAboutToListen;
            }
        }
        
        [self _setPreferredFramesPerSecond];
        [self _updateDisplayLinkPausedState];
    }
}
- (void)fadeOutCurrentAura {
    for (SUICFlameGroup *flames in _flameGroups) {
        if ([flames isAura]) {
            [flames setIsDyingOff:YES];
        }
    }
}
+ (BOOL)_supportsAdaptiveFramerate {
//    static BOOL supportsAdaptiveFramerate = NO;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        supportsAdaptiveFramerate = MGGetBoolAnswer(kMGQSupportsPerseus);
//    });
//
//    return supportsAdaptiveFramerate;
    return NO;
}
- (void)_setPreferredFramesPerSecond {
    // Default value is zero, which means the display link will fire at the native cadence of the display hardware
    NSInteger preferredFramesPerSecond = 0;
    
    if (_flamesPaused) {
        preferredFramesPerSecond = 10;
    } else {
        // on Perseus-enabled devices, reduce frame rate during certain states to save power
        if ([[self class] _supportsAdaptiveFramerate]) {
            switch (_state) {
                case SUICFlamesViewStateAboutToListen:
                case SUICFlamesViewStateSuccess:
                case SUICFlamesViewStateDisabled:
                    preferredFramesPerSecond = 30;
                    break;
                    
                case SUICFlamesViewStateThinking:
                case SUICFlamesViewStateListening:
                    break;
            }
        }
        
        if (_mode == SUICFlamesViewModeSiri && _state == SUICFlamesViewStateThinking && _reduceThinkingFramerate) {
            preferredFramesPerSecond = 20;
            _frameRateScalingFactor = [_screen maximumFramesPerSecond] / preferredFramesPerSecond;
            
            // if it would actually speed up the framerate, keep it the same
            if (_frameRateScalingFactor < 1.0) {
                _frameRateScalingFactor = 1.0;
            }
            
        } else if (_reduceFrameRate) {
            switch (_mode) {
                case SUICFlamesViewModeSiri:
                case SUICFlamesViewModeHeySiriTraining:
                    if (_state != SUICFlamesViewStateThinking) {
                        preferredFramesPerSecond = 30;
                    }
                    break;
                    
                case SUICFlamesViewModeDictation:
                    preferredFramesPerSecond = 30;
                    break;
                default:
                    break;
            }
        }
    }
    [_displayLink setPreferredFramesPerSecond:preferredFramesPerSecond];
}
- (NSInteger)_preferredFramesPerSecond {
    return [_displayLink preferredFramesPerSecond];
}
- (void)_updateDisplayLinkPausedState {
    if (_state == SUICFlamesViewStateThinking || _state == SUICFlamesViewStateListening) {
        // We don't really want to pause the display link in thinking or listening states
        [_displayLink setPaused:NO];
    } else if ((!_showAura || _freezesAura) && _state == SUICFlamesViewStateAboutToListen && _transitionFinished) {
        // if the aura is disabled or frozen, there's no need to have the display link continue to fire needlessly.
        [_displayLink setPaused:YES];
    } else {
        [_displayLink setPaused:_flamesPaused];
    }
}
-(void)setMode:(SUICFlamesViewMode)mode {
    if (_mode == mode) {
        return;
    }
    _shadersAreCompiled = NO;
    _mode = mode;
    
    if (_mode == SUICFlamesViewModeDictation) {
        [self _setValuesForFidelity:0];
    }
    // Anytime a mode changes, it requires re-initialization of GL data.
    if (_isInitialized) {
        [self _initGLAndSetupDisplayLink:YES];
    }
}
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        [self _tearDownDisplayLink];
    } else {
        if (_isInitialized) {
            [self _setupDisplayLink];
        }
    }
}
- (void)setDictationColor:(UIColor *)dictationColor {
    if (dictationColor != _dictationColor) {
        _dictationColor = dictationColor;
        
        [_dictationColor getRed:&_dictationRedColor green:&_dictationGreenColor blue:&_dictationBlueColor alpha:nil];
    }
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // when we're using dictation mode, we need to ensure that we're setting the fidelity according to the activeFrame's width. This requires re-initialization of GL data.
    if (!_hasCustomActiveFrame) {
        _activeFrame = [self bounds];
    }
    if (_mode == SUICFlamesViewModeDictation) {
        [self _setValuesForFidelity:0]; // we need to reset the fidelity values since it relies on activeFrame width
        if (_isInitialized) {
            [self _initGLAndSetupDisplayLink:YES];
        }
    }
    
    // keep the overlayImageView tied to the view's frame
    [_overlayImageView setFrame:[self frame]];
}
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    if (!_hasCustomActiveFrame) {
        _activeFrame = [self bounds];
    }
}
- (void)setActiveFrame:(CGRect)subFrame {
    // multiply by screen scale
    _activeFrame = CGRectMake(subFrame.origin.x, subFrame.origin.y, subFrame.size.width, subFrame.size.height);
    _hasCustomActiveFrame = YES;
    
    // when we're using dictation mode, we need to ensure that we're setting the fidelity according to the activeFrame's width. This requires re-initialization of GL data.
    if (_mode == SUICFlamesViewModeDictation) {
        [self _setValuesForFidelity:0]; // we need to reset the fidelity values since it relies on activeFrame width.
        if (_isInitialized) {
            [self _initGLAndSetupDisplayLink:YES];
        }
    }
}
- (void)setOverlayImage:(UIImage *)overlayImage {
    _overlayImage = overlayImage;
    
    if (_overlayImage) {
        _overlayImageView = [[UIImageView alloc] initWithImage:overlayImage];
        [_overlayImageView setFrame:[self frame]];
        [self addSubview:_overlayImageView];
        
    } else {
        [_overlayImageView removeFromSuperview];
        _overlayImageView = nil;
    }
}
- (void)setRenderInBackground:(BOOL)renderInBackground {
    // SPI not supported for now.
//    _renderInBackground = renderInBackground;
//    int32_t enableBackgroundRendering = renderInBackground;
//    [_eaglContext setParameter:kEAGLCPSetBackgroundRendering to:&enableBackgroundRendering];
}
- (BOOL)flamesPaused {
    return _flamesPaused;
}
- (void)setFlamesPaused:(BOOL)paused {
    _flamesPaused = paused;
    
    // We need to pause _displayLink only for states where the waveform is not visible.
    // Otherwise, we just reduce FPS to a minimum so the waveform is not "jumping" when you change the view's bounds.
    // This "jumping" is happening because the waveform is rendered relatively to the view's frame using display link.
    // Reducing FPS allows to render a few frames while rotation is happening, so the transition is much smoother than
    // just pausing the display link before rotation and resuming after.
    // Still it's preferable to pause rendering completely when possible, since it yields a better performance.
    [self _setPreferredFramesPerSecond];
    [self _updateDisplayLinkPausedState];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen size:(CGSize)size {
    [self prewarmShadersForScreen:screen size:size fidelity:SUICFlamesViewFidelityHigh];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen size:(CGSize)size fidelity:(SUICFlamesViewFidelity)fidelity {
    [self prewarmShadersForScreen:screen size:size fidelity:fidelity prewarmInBackground:NO];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen size:(CGSize)size fidelity:(SUICFlamesViewFidelity)fidelity prewarmInBackground:(BOOL)prewarmInBackground {
    CGRect frame = screen.bounds;
    frame.size.height = size.height;
    frame.size.width = size.width;
    
    [self prewarmShadersForScreen:screen initialFrame:frame activeFrame:frame fidelity:fidelity prewarmInBackground:prewarmInBackground];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen activeFrame:(CGRect)activeFrame fidelity:(SUICFlamesViewFidelity)fidelity {
    [self prewarmShadersForScreen:screen initialFrame:[screen bounds] activeFrame:activeFrame fidelity:fidelity prewarmInBackground:NO];
}
+ (void)prewarmShadersForScreen:(UIScreen *)screen initialFrame:(CGRect)initialFrame activeFrame:(CGRect)activeFrame fidelity:(SUICFlamesViewFidelity)fidelity prewarmInBackground:(BOOL)prewarmInBackground {
    SUICFlamesViewLegacy *flamesView = [[SUICFlamesViewLegacy alloc] initWithFrame:initialFrame screen:screen fidelity:fidelity];
    
    [flamesView setRenderInBackground:prewarmInBackground];
    [flamesView setActiveFrame:activeFrame];
    [flamesView _prewarmShaders];
}
- (void)setHorizontalScaleFactor:(CGFloat)horizontalScaleFactor {
    _horizontalScaleFactor = horizontalScaleFactor;
    if (horizontalScaleFactor != 0.0) {
        [[self layer] setAffineTransform:CGAffineTransformMakeScale(1.0/_horizontalScaleFactor, 1.0)];
        [self _setValuesForFidelity:_fidelity];
    }
}
- (void)prewarmShadersForCurrentMode {
    [self _prewarmShaders];
}
- (void)_prewarmShaders {
    // When running in Simulator don't attempt to prewarm, since doing this on a background thread can cause crashes.
    // rdar://51167937 (CrashTracer: [USER] SpringBoard at GLEngine: gleSetVPTransformFuncAll)
#if !TARGET_OS_SIMULATOR
    // force a complete render pass as part of prewarm
    _isInitialized = [self _initGLAndSetupDisplayLink:NO];
    [self _updateCurveLayer:_displayLink];
#endif
}
- (void)resetAndReinitialize:(BOOL)initialize {
    if (initialize) {
        [self _initGLAndSetupDisplayLink:YES];
    }
    
    // always do this part
    NSMutableArray *discarded = [[NSMutableArray alloc] init];
    for (SUICFlameGroup *flames in _flameGroups) {
        if (flames != _currentFlameGroup)
            [discarded addObject:flames];
    }
    [_flameGroups removeObjectsInArray:discarded];
    
    // force one final draw, to flush any pending animations
    // this is needed for NanoSiri to reset the flames view and not show a frame of the aura animation
    [self _updateCurveLayer:_displayLink];
}
- (void)setRenderingEnabled:(BOOL)enabled forReason:(NSString *)reason {
    if (enabled) {
        [_renderingDisabledReasons removeObject:reason];
    } else {
        [_renderingDisabledReasons addObject:reason];
        if (!_renderInBackground) {
            glFinish();
        }
    }
    if ([self isRenderingEnabled]) {
        [self setNeedsLayout];
    }
}
- (BOOL)_setCurrentContext {
    EAGLContext *previousContext = [EAGLContext currentContext];
    if (_currentContextCount < 1 && previousContext != _eaglContext) {
        _previousContext = previousContext;
    }
    _currentContextCount += 1;
    return [EAGLContext setCurrentContext:_eaglContext];
}
- (void)_restoreCurrentContext {
    _currentContextCount = MAX(_currentContextCount - 1, 0);
    if (_currentContextCount < 1) {
        [EAGLContext setCurrentContext:_previousContext];
    }
}
- (void)_reduceMotionStatusChanged:(NSNotification *)notification {
    _reduceMotionEnabled = UIAccessibilityIsReduceMotionEnabled();
    if (_mode == SUICFlamesViewModeSiri) {
        _shadersAreCompiled = NO;
        [self resetAndReinitialize:YES];
    }
}
- (void)_applicationWillResignActive:(NSNotification *)notification {
    [self setRenderingEnabled:NO forReason:kSUICFlamesViewUIApplicationNotificationReason];
}
- (void)_applicationWillEnterForeground:(NSNotification *)notification {
    [self setRenderingEnabled:YES forReason:kSUICFlamesViewUIApplicationNotificationReason];
}
- (void)_applicationDidBecomeActive:(NSNotification *)notification {
    [self setRenderingEnabled:YES forReason:kSUICFlamesViewUIApplicationNotificationReason];
}
- (void)_setupDisplayLink {
    if (![self isHidden] && !_displayLink) {
        _displayLink = [_screen displayLinkWithTarget:self selector:@selector(_updateCurveLayer:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self _setPreferredFramesPerSecond];
        [self _updateDisplayLinkPausedState];
    }
}
- (BOOL)_setupFramebuffer {
    BOOL success = YES;
    GL_VALIDATE( glGenFramebuffers( 1, &_framebufferHandle ) );
    GL_VALIDATE( glGenRenderbuffers( 1, &_renderbufferHandle ) );
    GL_VALIDATE( glBindFramebuffer( GL_FRAMEBUFFER, _framebufferHandle ) );
    GL_VALIDATE( glBindRenderbuffer( GL_RENDERBUFFER, _renderbufferHandle ) );
    
    if (success) {
        success = [_eaglContext renderbufferStorage: GL_RENDERBUFFER fromDrawable: (id<EAGLDrawable>) self.layer];
    }
    
    GL_VALIDATE( glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbufferHandle ) );
    GL_VALIDATE( glGetRenderbufferParameteriv( GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_viewWidth ) );
    GL_VALIDATE( glGetRenderbufferParameteriv( GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_viewHeight ) );
    
    if (success) {
        success = ( GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus( GL_FRAMEBUFFER ) );
    }
    
#if USE_SIRI_GL_MULTISAMPLE
    GL_VALIDATE( glGenFramebuffers(1, &_msaaFBOName) );
    GL_VALIDATE( glGenRenderbuffers(1, &_msaaRenderbuffer) );
    
    GL_VALIDATE( glBindFramebuffer(GL_FRAMEBUFFER, _msaaFBOName) );
    GL_VALIDATE( glBindRenderbuffer(GL_RENDERBUFFER, _msaaRenderbuffer) );
    
    GL_VALIDATE( glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, USE_SIRI_GL_MULTISAMPLE, USE_SIRI_GL_MSAA_FORMAT, _viewWidth, _viewHeight) );
    GL_VALIDATE( glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaRenderbuffer) );
#endif
    
    return success;
}
- (BOOL)_setupShaders {
    if (_shadersAreCompiled) {
        return YES;
    }
    
    if (_flameProgramHandle) {
        glDeleteProgram( _flameProgramHandle );
        _flameProgramHandle = 0;
    }
    
    if (_auraProgramHandle) {
        glDeleteProgram( _auraProgramHandle );
        _auraProgramHandle = 0;
    }
    
    GLuint vertShader = glCreateShader( GL_VERTEX_SHADER );
    GLuint fragShader0 = glCreateShader( GL_FRAGMENT_SHADER );
    GLuint fragShader1 = 0;
    BOOL success = ( ( 0 != vertShader ) && ( 0 != fragShader0 ) );
    GLint status = 0;
    
    GL_VALIDATE( glDisable( GL_DEPTH_TEST ) );
    GL_VALIDATE( glDisable( GL_DITHER ) );
    GL_VALIDATE( glEnable( GL_BLEND ) );
    GL_VALIDATE( glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) );
    
    switch (_mode) {
        case SUICFlamesViewModeSiri:
            GL_VALIDATE( glShaderSource( vertShader, 1, _reduceMotionEnabled ? &siriFlameAccessibilityVertexShader : &siriFlameVertexShader, NULL ) );
            GL_VALIDATE( glCompileShader( vertShader ) );
            GL_VALIDATE( glGetShaderiv( vertShader, GL_COMPILE_STATUS, &status ) );
            GL_VALIDATE( glShaderSource( fragShader0, 1, &siriFlameFragmentShader, NULL ) );
            GL_VALIDATE( glCompileShader( fragShader0 ) );
            GL_VALIDATE( glGetShaderiv( fragShader0, GL_COMPILE_STATUS, &status ) );
            
            if (_showAura) {
                fragShader1 = glCreateShader( GL_FRAGMENT_SHADER );
                success &= ( ( 0 != fragShader1 ) );
                GL_VALIDATE( glShaderSource( fragShader1, 1, &siriAuraFragmentShader, NULL ) );
                GL_VALIDATE( glCompileShader( fragShader1 ) );
                GL_VALIDATE( glGetShaderiv( fragShader1, GL_COMPILE_STATUS, &status ) );
            }
            
            break;
            
        case SUICFlamesViewModeDictation:
            GL_VALIDATE( glShaderSource( vertShader, 1, &siriDictationVertexShader, NULL ) );
            GL_VALIDATE( glCompileShader( vertShader ) );
            GL_VALIDATE( glGetShaderiv( vertShader, GL_COMPILE_STATUS, &status ) );
            GL_VALIDATE( glShaderSource( fragShader0, 1, &siriDictationFragmentShader, NULL ) );
            GL_VALIDATE( glCompileShader( fragShader0 ) );
            GL_VALIDATE( glGetShaderiv( fragShader0, GL_COMPILE_STATUS, &status ) );
            break;
            
        case SUICFlamesViewModeHeySiriTraining:
            GL_VALIDATE( glShaderSource( vertShader, 1, &siriTrainingVertexShader, NULL ) );
            GL_VALIDATE( glCompileShader( vertShader ) );
            GL_VALIDATE( glGetShaderiv( vertShader, GL_COMPILE_STATUS, &status ) );
            GL_VALIDATE( glShaderSource( fragShader0, 1, &siriTrainingFragmentShader, NULL ) );
            GL_VALIDATE( glCompileShader( fragShader0 ) );
            GL_VALIDATE( glGetShaderiv( fragShader0, GL_COMPILE_STATUS, &status ) );
            break;
            
        default:
            break;
    }
    
    success &= (0 != status);
    
    GL_VALIDATE( _flameProgramHandle  = glCreateProgram() );
    success &= (0 != _flameProgramHandle);
    
    
    GL_VALIDATE( glAttachShader( _flameProgramHandle, vertShader ) );
    GL_VALIDATE( glAttachShader( _flameProgramHandle, fragShader0 ) );
    GL_VALIDATE( glLinkProgram( _flameProgramHandle ) );
    GL_VALIDATE( glGetProgramiv( _flameProgramHandle, GL_LINK_STATUS, &status ) );
    
    success &= (0 != status);
    
    // prewarm attributes
    glClear( GL_COLOR_BUFFER_BIT );
    glVertexAttrib4f(GLSL_IN_FITTED_BOUNDS, (GLfloat)_activeFrame.origin.x, (GLfloat)_activeFrame.origin.y, (GLfloat)_activeFrame.size.width * _horizontalScaleFactor, (GLfloat)_activeFrame.size.height );
    glVertexAttrib4f(GLSL_VIEWPORTDIM_SCREENSCALE_UNITLENGTH, (GLfloat)_viewWidth, (GLfloat)_viewHeight, (GLfloat)[self _currentDisplayScale], (GLfloat)_dictationUnitSize);
    glVertexAttrib4f(GLSL_STATES, 0.0, 0.0, 0.0, 0.0);
    glVertexAttrib4f(GLSL_IN_TIME_ZTIME_HEIGHT_ALPHA, 0.0, 0.0, 0.0, 0.0);
    if (_mode == SUICFlamesViewModeDictation) {
        glVertexAttrib3f(GLSL_FRAGMENT_COLOR, _dictationRedColor, _dictationGreenColor, _dictationBlueColor);
    }
    
    if (0 != fragShader1) {
        GL_VALIDATE( _auraProgramHandle  = glCreateProgram() );
        success &= (0 != _auraProgramHandle);
        GL_VALIDATE( glAttachShader( _auraProgramHandle, vertShader ) );
        GL_VALIDATE( glAttachShader( _auraProgramHandle, fragShader1 ) );
        GL_VALIDATE( glLinkProgram( _auraProgramHandle ) );
        GL_VALIDATE( glGetProgramiv( _auraProgramHandle, GL_LINK_STATUS, &status ) );
        
        success &= (0 != status);
        
        GL_VALIDATE( glUseProgram( _auraProgramHandle ) );
        
        success &= (0 != ( GLSL_IN_POLARVERTEX2_POLAROFFSET2 == glGetAttribLocation( _auraProgramHandle, "in_Polar" ) ) );
        success &= (0 != ( GLSL_IN_FITTED_BOUNDS == glGetAttribLocation( _auraProgramHandle, "in_FittedBounds" ) ) );
        success &= (0 != ( GLSL_IN_TIME_ZTIME_HEIGHT_ALPHA == glGetAttribLocation( _auraProgramHandle, "in_Time_ZTime_Height_Alpha" ) ) );
        success &= (0 != ( GLSL_STATES == glGetAttribLocation( _auraProgramHandle, "in_States" ) ) );
        success &= (0 != ( GLSL_VIEWPORTDIM_SCREENSCALE_UNITLENGTH == glGetAttribLocation( _auraProgramHandle, "in_ViewportDim_ScreenScale_UnitLength" ) ) );
        
        // prewarm
        // <rdar://problem/21030240> Investigate better shader prewarming
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    
    GL_VALIDATE( glUseProgram( _flameProgramHandle ) );
    
    success &= (0 != ( GLSL_IN_POLARVERTEX2_POLAROFFSET2 == glGetAttribLocation( _flameProgramHandle, "in_Polar" ) ) );
    success &= (0 != ( GLSL_IN_FITTED_BOUNDS == glGetAttribLocation( _flameProgramHandle, "in_FittedBounds" ) ) );
    success &= (0 != ( GLSL_IN_TIME_ZTIME_HEIGHT_ALPHA == glGetAttribLocation( _flameProgramHandle, "in_Time_ZTime_Height_Alpha" ) ) );
    success &= (0 != ( GLSL_STATES == glGetAttribLocation( _flameProgramHandle, "in_States" ) ) );
    success &= (0 != ( GLSL_VIEWPORTDIM_SCREENSCALE_UNITLENGTH == glGetAttribLocation( _flameProgramHandle, "in_ViewportDim_ScreenScale_UnitLength" ) ) );
    if (_mode == SUICFlamesViewModeDictation) {
        success &= (0 != ( GLSL_FRAGMENT_COLOR == glGetAttribLocation( _flameProgramHandle, "in_FragmentColor" ) ) );
    }
    
    // prewarm
    // <rdar://problem/21030240> Investigate better shader prewarming
    glDrawArrays(GL_TRIANGLES, 0, 3);
    if (vertShader) {
        glDeleteShader( vertShader );
    }
    
    if (fragShader0) {
        glDeleteShader( fragShader0 );
    }
    
    if (fragShader1) {
        glDeleteShader( fragShader1 );
    }
    
    if (!success) {
        if (_flameProgramHandle) {
            glDeleteProgram( _flameProgramHandle );
            _flameProgramHandle = 0;
        }
        
        if (_auraProgramHandle) {
            glDeleteProgram( _auraProgramHandle );
            _auraProgramHandle = 0;
        }
    }
    
    if (success) {
        _shadersAreCompiled = YES;
    }
    return success;
}
- (GLuint)_numVerticesPerCircle {
    return (int)roundf(3 * powf(2, _maxSubdivisionLevel));
}
- (vector_float2)_predeterminedVertexPositionForAuraWithPolarVertex:(vector_float2)vertex {
    vector_float2 activeFrameOrigin = (vector_float2){_activeFrame.origin.x, _activeFrame.origin.y};
    vector_float2 activeFrameSize = (vector_float2){_activeFrame.size.width * _horizontalScaleFactor, _activeFrame.size.height};
    vector_float2 viewportSize = (vector_float2){_viewWidth, _viewHeight};
    //    vector_float2 scale =  activeFrameSize / viewportSize;
    vector_float2 center = (activeFrameOrigin + (activeFrameSize * 0.5)) / viewportSize * 2.0 - 1.0;
    center = -center;
    float r = vertex.x * vector_distance(center, 1.0);
    float q = vertex.y;
    return (vector_float2){cosf(q), sinf(q)} * r + center;
}
// ∑ of (3 * 2 ^ upperLimit - 3 * 2 ^ lowerLimit) * 3. Clamped by numCircles with continuation of linear upperLimit ∑ of 3 * 2 ^ upperLimit * (remainder of circles)
// example # 1: with upper limit of 8 and lower limit of 1 and a numCircles of 10:   ((3*2^8 - 3*2^1) + (3*2^8)*3)
// example # 2: with upper limit of 8 and lower limit of 7 and a numCircles of 10:   ((3*2^8 - 3*2^7) + (3*2^8)*9)
// example # 4: with upper limit of 4 and lower limit of 1 and a numCircles of 3:    ((3*2^4 - 3*2^1) + (3*2^4)*0)
// example # 5: with upper limit of 4 and lower limit of 3 and a numCircles of 7:    ((3*2^4 - 3*2^3) + (3*2^4)*6)
// example # 6: with upper limit of 8 and lower limit of 3 and a numCircles of 8:    ((3*2^9 - 3*2^3) + (3*2^8)*2)
- (int)_generateIndicesForNumCircleShapes:(int)numCircles withMaxSubdivisionLevel:(float)maxSubdivisionLevel startingWithNumSubdivisionLevel:(float)initialSubdivisionLevel forIndices:(GLuint**)inOutIndices atStartIndex:(int)startIndex withFill:(BOOL)fillBool withCullingForAura:(BOOL)auraCullBool forVertices:(Vertex*)inVertices {
    const GLuint numVertsPerCircle = [self _numVerticesPerCircle];
    int ii = startIndex;
    GLuint * indices = *inOutIndices;
    Vertex * vertices = inVertices;
    
    // The vertex count for a hole should always be able to draw quads (to stay compatible with the histogram form of this geometry) so set initialSubDivisiionLevel at 1 or above.
    if (fillBool) {
        GLuint numTriangleVerts = (uint)roundf(3 * powf(2, initialSubdivisionLevel));
        // our starting vertex should be the outer-most circle if we only have one circle.
        GLuint begin = (numCircles == 1) ? numVertsPerCircle * (_maxVertexCircles - 1) : 0;
        GLuint step = (int)((float)numVertsPerCircle / numTriangleVerts);
        for (int i = 0; i < numTriangleVerts / 2 - 1; ++i) {
            
            indices = (GLuint*) realloc(indices, (ii + 6) * sizeof(GLuint));
            
            indices[ii++] = begin + (i) * step;
            indices[ii++] = begin + (i+1) * step;
            indices[ii++] = begin + (numTriangleVerts - 1 - i - 1) * step;
            
            indices[ii++] = begin + (i) * step;
            indices[ii++] = begin + (numTriangleVerts - 1 - i - 1) * step;
            indices[ii++] = begin + (numTriangleVerts - 1 - i) * step;
        }
    }
    
    for (int i = 0; i < numCircles - 1; ++i) {
        const GLint curr_step = (int)((float)i / numCircles * _maxVertexCircles);
        const GLint next_step = (i == numCircles - 2) ? (_maxVertexCircles - 1) : (int)((float)(i+1) / numCircles * _maxVertexCircles);
        const GLint n_inner = (int)roundf(3 * powf(2, MIN(initialSubdivisionLevel + i, maxSubdivisionLevel)));
        const GLint n_outer = (int)roundf(3 * powf(2, MIN(initialSubdivisionLevel + i+1, maxSubdivisionLevel)));
        const float subdivision_ratio = (float)n_inner / n_outer;
        
        const GLint ring_inner_index = curr_step * numVertsPerCircle;
        const GLint ring_outer_index = next_step * numVertsPerCircle;
        
        for (int j = 0; j < n_inner; ++j) {
            const float ratio = ((float)j/n_inner);
            
            // outer vertex index plus one and minus one. using the ratio of j with n to determine offset. Since we are doubling from the inner circle, we want half the distance the next inner j step. modulo keeps us in range.
            const GLint v_inner = ring_inner_index + (int)(numVertsPerCircle * ratio) % numVertsPerCircle;
            const GLint v_inner_plus_one = ring_inner_index + (int)(numVertsPerCircle * (float)(j+1)/n_inner) % numVertsPerCircle;
            const GLint v_outer = ring_outer_index + (int)(numVertsPerCircle * ratio) % numVertsPerCircle;
            
            // the following ratios must be positive for modulo to work the way we want it to.
            const float ratio_plus_one_outer_offset = ((float)j + (float)subdivision_ratio) / (float)n_inner;
            const float ratio_minus_one_outer_offset = ((float)j + (float)n_inner - (float)subdivision_ratio) / (float)n_inner;
            const GLint v_outer_plus_one = ring_outer_index + (int)(ratio_plus_one_outer_offset * numVertsPerCircle) % numVertsPerCircle;
            const GLint v_outer_minus_one = ring_outer_index + (int)(ratio_minus_one_outer_offset * numVertsPerCircle) % numVertsPerCircle;
            
            // culling setup
            vector_float2 inner_auraPosition = 0.0;
            vector_float2 inner_plus_one_auraPosition = 0.0;
            vector_float2 outer_auraPosition = 0.0;
            vector_float2 outer_plus_one_auraPosition = 0.0;
            vector_float2 outer_minus_one_auraPosition = 0.0;
            if (auraCullBool) {
                inner_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_inner].vertexLocation.xy]);
                inner_plus_one_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_inner_plus_one].vertexLocation.xy]);
                outer_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_outer].vertexLocation.xy]);
                outer_plus_one_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_outer_plus_one].vertexLocation.xy]);
                outer_minus_one_auraPosition = vector_abs([self _predeterminedVertexPositionForAuraWithPolarVertex:vertices[v_outer_minus_one].vertexLocation.xy]);
            }
            
            NSAssert(v_inner < _numVertices && v_inner >= 0, @"Failed to evaluate inner vertex (%i) within valid range: 0 <-> %i", v_inner, _numVertices-1);
            NSAssert(v_outer < _numVertices && v_outer >= 0, @"Failed to evaluate outer vertex (%i) within valid range: %i. ring_outer_index was %i. ring_outer_size was %i. And ratio was %f", v_outer, _numVertices-1, ring_outer_index, numVertsPerCircle, ratio);
            NSAssert(v_outer_plus_one < _numVertices && v_outer_plus_one >= 0, @"Failed to evaluate v_outer_plus_one (%i) within valid range: 0 <-> %i", v_outer_plus_one, _numVertices-1);
            NSAssert(v_outer_minus_one < _numVertices && v_outer_minus_one >= 0, @"Failed to evaluate v_outer_minus_one (%i) within valid range: 0 <-> %i", v_outer_minus_one, _numVertices-1);
            
            // this is where we need to apply our subdivided element if we are infact subdividing
            if (subdivision_ratio != 1.0)
            {
                // vector_length(vector_step(1.1, x)) calculations can result in 0 (x and y within screen), 1 (x or y within screen), 2 (x and y outside of screen).
                // using 1.1 as a fast hack to keep low fidelity vertices near the screen's corner.
                if (!auraCullBool ||
                    vector_length(vector_step(1.1, inner_auraPosition)) +
                    vector_length(vector_step(1.1, outer_minus_one_auraPosition)) +
                    vector_length(vector_step(1.1, outer_auraPosition)) < 3.0) {
                    
                    indices = (GLuint*) realloc(indices, (ii + 3) * sizeof(GLuint));
                    
                    // cw triangle.
                    indices[ii++] = v_inner;
                    indices[ii++] = v_outer_minus_one;
                    indices[ii++] = v_outer;
                }
            }
            
            if (!auraCullBool ||
                vector_length(vector_step(1.1, inner_auraPosition)) +
                vector_length(vector_step(1.1, outer_auraPosition)) +
                vector_length(vector_step(1.1, outer_plus_one_auraPosition)) < 3.0) {
                
                indices = (GLuint*) realloc(indices, (ii + 3) * sizeof(GLuint));
                
                // ccw triangle.
                indices[ii++] = v_inner;
                indices[ii++] = v_outer;
                indices[ii++] = v_outer_plus_one;
            }
            
            if (!auraCullBool ||
                vector_length(vector_step(1.1, inner_auraPosition)) +
                vector_length(vector_step(1.1, outer_plus_one_auraPosition)) +
                vector_length(vector_step(1.1, inner_plus_one_auraPosition)) < 3.0) {
                
                indices = (GLuint*) realloc(indices, (ii + 3) * sizeof(GLuint));
                
                // ccw triangle's adjacent triangle to create quad.
                indices[ii++] = v_inner;
                indices[ii++] = v_outer_plus_one;
                indices[ii++] = v_inner_plus_one;
            }
        }
    }
    
    *inOutIndices = indices;
    
    return ii;
}
- (BOOL)_setupVertexBuffer {
    BOOL success = YES;
    NSAssert(_maxVertexCircles >= 1, @"Init size exepcted non-zero");
    const GLuint numVertsPerCircle = [self _numVerticesPerCircle];
    _numVertices = _maxVertexCircles * numVertsPerCircle;
    
    // raw vertex data
    Vertex vertices[_numVertices];
    GLint vi = 0;
    
    for(int i = 0; i < _maxVertexCircles; ++i) {
        
        // r: radius
        GLfloat r = (float)(i+1) / _maxVertexCircles;
        
        // square r for more inner circles.
        //        r *= r;
        
        const GLint n = numVertsPerCircle;
        
        // subdivided vertex count. starts from a triangle.
        // const GLint n = 3 * powf(2, MIN(i, kMaxSubdivisions));
        
        for (int j = 0; j < n; ++j) {
            // q: theta (radians)
            float q_geom;
            float q_noise;
            if (_mode == SUICFlamesViewModeDictation) {
                q_geom  = M_PI * 2.0 * ((float)((j+1) - (j % 2)) / n);
                q_noise = M_PI * 2.0 * vector_fract((float)((j+1) + ((j % 2) - 1.0)) / n);
            } else {
                q_geom = q_noise = M_PI * 2.0 * ((float)j / n);
            }
            
            // polar (r,q)
            vertices[vi].vertexLocation.xy = (vector_float2){r,q_geom};
            vertices[vi].vertexLocation.zw = (vector_float2){r,q_noise};
            ++vi;
        }
    }
    
    GLuint* indices = NULL;
    
    NSString *cacheKey = SUICGetIndexCacheEntryKey(_activeFrame, _fidelity, _horizontalScaleFactor, _mode, _viewWidth, _viewHeight);
    
    SUICGLIndexCacheEntry *cacheEntry = [[[self class] _indexCache] objectForKey:cacheKey];
    
    if (cacheEntry) {
        _numAuraIndices = [cacheEntry numAuraIndices];
        _numAuraIndicesCulled = [cacheEntry numAuraIndicesCulled];
        _numWaveIndices = [cacheEntry numWaveIndices];
        indices = [cacheEntry gl_indices];
    } else {
        _numAuraIndices = [self _generateIndicesForNumCircleShapes:_auraVertexCircles
                                           withMaxSubdivisionLevel:_auraMaxSubdivisionLevel
                                   startingWithNumSubdivisionLevel:_auraMinSubdivisionLevel
                                                        forIndices:&indices
                                                      atStartIndex:0
                                                          withFill:YES
                                                withCullingForAura:NO
                                                       forVertices:vertices];
        
        _numAuraIndicesCulled = [self _generateIndicesForNumCircleShapes:_auraVertexCircles
                                                 withMaxSubdivisionLevel:_auraMaxSubdivisionLevel
                                         startingWithNumSubdivisionLevel:_auraMinSubdivisionLevel
                                                              forIndices:&indices
                                                            atStartIndex:_numAuraIndices
                                                                withFill:YES
                                                      withCullingForAura:YES
                                                             forVertices:vertices];
        
        _numWaveIndices = [self _generateIndicesForNumCircleShapes:1
                                           withMaxSubdivisionLevel:_maxSubdivisionLevel
                                   startingWithNumSubdivisionLevel:_maxSubdivisionLevel
                                                        forIndices:&indices
                                                      atStartIndex:_numAuraIndicesCulled
                                                          withFill:YES
                                                withCullingForAura:NO
                                                       forVertices:vertices];
        
        _numWaveIndices -= _numAuraIndicesCulled;
        _numAuraIndicesCulled -= _numAuraIndices;
        
        cacheEntry = [[SUICGLIndexCacheEntry alloc] init];
        [cacheEntry setNumAuraIndices:_numAuraIndices];
        [cacheEntry setNumAuraIndicesCulled:_numAuraIndicesCulled];
        [cacheEntry setNumWaveIndices:_numWaveIndices];
        [cacheEntry setGl_indices:indices];
        [[[self class] _indexCache] setObject:cacheEntry forKey:cacheKey];
    }
    
    if (vi != _numVertices) {
        NSAssert(vi == _numVertices, @"VBO was not written to correct range");
    }
    
    // Generate VAO data
    {
        GL_VALIDATE( glGenVertexArraysOES(1, &_vertexArrayObjectHandle) );
        GL_VALIDATE( glBindVertexArrayOES(_vertexArrayObjectHandle) );
        
        //Allocate and assign VBO's - verts+norms+texcoords and indices
        GL_VALIDATE( glGenBuffers(1, &_vertexBufferHandle) );
        GL_VALIDATE( glGenBuffers(1, &_elementArrayHandle) );
        
        // vertices
        GL_VALIDATE( glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferHandle) );
        GL_VALIDATE( glBufferData(GL_ARRAY_BUFFER, _numVertices * sizeof(Vertex), vertices, GL_STATIC_DRAW) );
        
        GL_VALIDATE( glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _elementArrayHandle) );
        GL_VALIDATE( glBufferData(GL_ELEMENT_ARRAY_BUFFER, (_numAuraIndices + _numAuraIndicesCulled + _numWaveIndices) * sizeof(GLuint), indices, GL_STATIC_DRAW) );
        
        GL_VALIDATE( glVertexAttribPointer(GLSL_IN_POLARVERTEX2_POLAROFFSET2, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*)offsetof(Vertex, vertexLocation)) );
        GL_VALIDATE( glEnableVertexAttribArray(GLSL_IN_POLARVERTEX2_POLAROFFSET2) );
    }
    return success;
}
- (BOOL)_initGLAndSetupDisplayLink:(BOOL)setupDisplayLink {
    [self _cleanupGL];
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)[self layer];
    [eaglLayer setOpaque:NO];
    [eaglLayer setContentsScale:[self _currentDisplayScale]];
    
    [self _setCurrentContext];
    
    BOOL success = [self _setupFramebuffer];
    
    if (success) {
        success = [self _setupVertexBuffer];
    }
    
    if (success) {
        success = [self _setupShaders];
    }
    
//    glClearColor(0.6431, 0.66667, 0.7019, 1.0); // testing for dictation
//    glClearColor(1.0, 1.0, 1.0, 1.0); // testing for hey siri setup
    glClearColor(0.0, 0.0, 0.0, 0.0);
    
    if (success && setupDisplayLink) {
        [self _setupDisplayLink];
    }
    [self _restoreCurrentContext];
    return success;
}
- (void)_cleanupGL {
    if (_eaglContext) {
        [self _setCurrentContext];
        
        if (_flameProgramHandle) {
            glDeleteProgram( _flameProgramHandle );
            _flameProgramHandle = 0;
        }
        
        if (_auraProgramHandle) {
            glDeleteProgram( _auraProgramHandle );
            _auraProgramHandle = 0;
        }
        
        if (_elementArrayHandle) {
            glDeleteBuffers(1, &_elementArrayHandle);
            _elementArrayHandle = 0;
        }
        
        if (_vertexBufferHandle) {
            glDeleteBuffers( 1, &_vertexBufferHandle );
            _vertexBufferHandle = 0;
        }
        
        if (_vertexArrayObjectHandle) {
            glDeleteBuffers(1, &_vertexArrayObjectHandle);
            _vertexArrayObjectHandle = 0;
        }
        
        if (_framebufferHandle) {
            glDeleteFramebuffers( 1, &_framebufferHandle );
            _framebufferHandle = 0;
        }
        
        if (_renderbufferHandle) {
            glDeleteRenderbuffers( 1, &_renderbufferHandle );
            _renderbufferHandle = 0;
        }
#if USE_SIRI_GL_MULTISAMPLE
        if (_msaaFBOName) {
            glDeleteBuffers(1, &_msaaFBOName);
            _msaaFBOName = 0;
        }
        
        if (_msaaRenderbuffer) {
            glDeleteBuffers(1, &_msaaRenderbuffer);
            _msaaRenderbuffer = 0;
        }
#endif
        glFinish();
        [self _restoreCurrentContext];
    }
}
- (BOOL)_resizeFromLayer:(CAEAGLLayer*)layer {
    if (![self isRenderingEnabled]) {
        return NO;
    }
    
    BOOL success = YES;
    
    GL_VALIDATE( glBindRenderbuffer( GL_RENDERBUFFER, _renderbufferHandle ) );
    
    if (success) {
        success = [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable: layer];
    }
    
    GL_VALIDATE( glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_viewWidth ) );
    GL_VALIDATE( glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_viewHeight ) );
    
    if (success){
        success = ( GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus( GL_FRAMEBUFFER ) );
    }
    
#if USE_SIRI_GL_MULTISAMPLE
    
    if(success) {
#if DEBUG
        NSAssert(_msaaFBOName, @"Where is my msaaFBO!!!");
#endif
        
        if(_msaaRenderbuffer)
            glDeleteRenderbuffers(1, &_msaaRenderbuffer);
        glGenRenderbuffers(1, &_msaaRenderbuffer);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _msaaFBOName);
        glBindRenderbuffer(GL_RENDERBUFFER, _msaaRenderbuffer);
        
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, USE_SIRI_GL_MULTISAMPLE, USE_SIRI_GL_MSAA_FORMAT, _viewWidth, _viewHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaRenderbuffer);
        
        glViewport(0, 0, _viewWidth, _viewHeight);
        
        if (_viewWidth && _viewHeight) {
            NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, @"Resize failed to make complete framebuffer object");
        }
    }
#endif
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbufferHandle);
    
    return success;
}
- (void)_updateOrthoProjection {
    if (![self isRenderingEnabled]) {
        return;
    }
    
    glViewport( 0, 0, _viewWidth, _viewHeight );
}
- (void)layoutSubviews {
    [self _setCurrentContext];
    
    if (!_isInitialized) {
        _isInitialized = [self _initGLAndSetupDisplayLink:YES];
    }
    else {
        [self _resizeFromLayer:(CAEAGLLayer*)[self layer]];
    }
    
    [self _updateOrthoProjection];
    [self _restoreCurrentContext];
}
- (CGFloat)_currentDisplayScale {
    // prefer the scale from the trait collection, but if it is not valid use the screen scale instead.
    CGFloat traitScale = [[self traitCollection] displayScale];
    CGFloat scale = (traitScale >= 1.0 ? traitScale : [_screen scale]);
    if ([self _deviceNeeds2xFlamesWithCurrentScale:scale]) {
        scale = 2.0;
    }
    
    return scale;
}
- (BOOL)_deviceNeeds2xFlamesWithCurrentScale:(CGFloat)scale {
    // <rdar://problem/41995955> Downscale flames view to display as 2x on N56
    static BOOL needsLowerQualityFlames = NO;
#ifdef MGPROD_N56
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        needsLowerQualityFlames = (MGGetProductType() == MGProductTypeN56);
    });
#endif
    // Only lower the quality if we're trying to render it at a 3x scale, to prevent cases where we might want to be rendering it at lower scales
    return (needsLowerQualityFlames && scale == 3.0);
}
- (void)_tearDownDisplayLink {
    _state = SUICFlamesViewStateDisabled;
    [_displayLink invalidate];
    _displayLink = nil;
}
- (BOOL)inSiriMode {
    return ([self mode] == SUICFlamesViewModeSiri);
}
- (BOOL)inDictationMode {
    return ([self mode] == SUICFlamesViewModeDictation);
}
- (void)stopRenderingAndCleanupGL {
    [self _tearDownDisplayLink];
    [self _cleanupGL];
}
- (BOOL)isRenderingEnabled {
#if TARGET_OS_TV
    return (![self _isOriginatingProcessInBackground] || _renderInBackground) && [_renderingDisabledReasons count] < 1;
#else
    return [_renderingDisabledReasons count] < 1;
#endif
}
- (BOOL)_isOriginatingProcessInBackground {
#if !TARGET_OS_SIMULATOR
//    uint32_t isBackground = 0;
//    proc_pidoriginatorinfo(0x2, &isBackground, sizeof(isBackground));
//    return (isBackground > 0);
    return NO; // proc_pidoriginatorinfo SPI does not exist on public SDK
#else
    return NO; // proc_pidoriginatorinfo SPI does not exist on Simulator
#endif
}
- (void)_updateCurveLayer:(CADisplayLink*)sender {
    if (!_currentFlameGroup) {
        return;
    }
    
    if (!_isInitialized) {
        return;
    }
    
    if (![self isRenderingEnabled]) {
        return;
    }
    
//    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)[self layer];
//    if (![eaglLayer isDrawableAvailable]) {
//        return;
//    }
    
    BOOL flamesTransitionFinished = NO;
    BOOL auraTransitionFinished = NO;
    {
        float *phase = _currentFlameGroup.transitionPhasePtr;
        vector_float4 *states = _currentFlameGroup.stateModifiersPtr;
        if (*phase < 1.0) {
            switch (_state) {
                case SUICFlamesViewStateAboutToListen:
                    *phase += (0.03 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){1.0, 0.0, 0.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    [_levelSmoother setDecaySpeed:0.95];
                    break;
                case SUICFlamesViewStateListening:
                    *phase += (0.03 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){0.0, 1.0, 0.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    [_levelSmoother setDecaySpeed:0.9];
                    break;
                case SUICFlamesViewStateThinking:
                    *phase += (0.02 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){0.0, 0.0, 1.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    break;
                case SUICFlamesViewStateSuccess:
                    // Since a new _currentFlameGroup is immediately allocated when this state is hit, and _currentFlameGroup becomes of state SUICFlamesViewStateAboutToListen, this switch case will never execute for any duration.
                    break;
                case SUICFlamesViewStateDisabled:
                    *phase += (0.03 * _frameRateScalingFactor);
                    *phase = MIN(*phase, 1.0);
                    *states = vector_mix(*states, (vector_float4){0.0, 0.0, 0.0, 0.0}, (vector_float4){*phase, *phase, *phase, *phase});
                    if (*phase == 1.0) {
                        [self setHidden:YES];
                    }
                    break;
            }
        }
        else
        {
            flamesTransitionFinished = YES;
        }
    }
    
    // <rdar://problem/20979777> SpringBoard is checking power levels even when not recording
    float powerLevel = 0.0;
    if (_state == SUICFlamesViewStateListening) {
        powerLevel = [self _currentMicPowerLevel];
    }
    
    [self _setCurrentContext];
    
#if USE_SIRI_GL_MULTISAMPLE
    glBindFramebuffer(GL_FRAMEBUFFER, _msaaFBOName);
#else
    // Bind our default FBO to render to the screen
    //glBindFramebuffer(GL_FRAMEBUFFER, _framebufferHandle);
#endif
    
    GLfloat timeInterval = [_displayLink duration];
    glClear( GL_COLOR_BUFFER_BIT );
    
    const CGFloat activeFrameOriginX = _activeFrame.origin.x * _horizontalScaleFactor;
    const CGFloat activeFrameWidth = _activeFrame.size.width * _horizontalScaleFactor;
    glVertexAttrib4f(GLSL_IN_FITTED_BOUNDS, (GLfloat)activeFrameOriginX, (GLfloat)_activeFrame.origin.y, (GLfloat)activeFrameWidth, (GLfloat)_activeFrame.size.height);
    glVertexAttrib4f(GLSL_VIEWPORTDIM_SCREENSCALE_UNITLENGTH, (GLfloat)_viewWidth, (GLfloat)_viewHeight, (GLfloat)[self _currentDisplayScale], (GLfloat)_dictationUnitSize);
    if (_mode == SUICFlamesViewModeDictation) {
        glVertexAttrib3f(GLSL_FRAGMENT_COLOR, _dictationRedColor, _dictationGreenColor, _dictationBlueColor);
    }
    
    NSMutableArray *discarded = [[NSMutableArray alloc] init];
    for (SUICFlameGroup *flames in _flameGroups) {
        vector_float4 *states = flames.stateModifiersPtr;
        // Don't animate the aura group if frozen.
        if (!(_freezesAura && flames.isAura)) {
            if (_reduceMotionEnabled) {
                flames.stateTime    += timeInterval * 0.5 * _frameRateScalingFactor;
                flames.zTime        += timeInterval * ((0.1 + powerLevel * 0.5) * ((*states).x + (*states).y) + (*states).z * 0.1 + (*states).w * 0.05); // manipulates that speed of zTime with irregular increments depending on the state
            } else {
                flames.stateTime    += timeInterval * _frameRateScalingFactor;
                flames.zTime        += timeInterval * ((0.25 + powerLevel * 2.0) * ((*states).x + (*states).y) + (*states).z * 0.25 + (*states).w * 0.05); // manipulates that speed of zTime with irregular increments depending on the state
            }
        }
        
        GLuint indicesLength = 0;
        GLuint indicesPosition = 0;
        
        if (flames.isDyingOff) {
            flames.globalAlpha = MAX(flames.globalAlpha - kGlobalAlphaFadeSpeedIncrement, 0.0);
        }
        
        if (flames.isAura && _mode == SUICFlamesViewModeSiri) {
            float *phase = flames.transitionPhasePtr;
            indicesLength = _numAuraIndicesCulled;
            indicesPosition = _numAuraIndices;
            if (*phase < 1.0) {
                *phase += (_reduceMotionEnabled ? 0.001 : 0.005) * _frameRateScalingFactor;
                *phase = MIN(*phase, 1.0);
                // since this transtion is longer than the standard speed, all states except aura should be pushed to zero quickly.
                *states = vector_mix(*states, (vector_float4){0.0, 0.0, 0.0, 1.0}, (vector_float4){*phase, *phase, *phase, *phase});
                indicesLength = _numAuraIndices;
                indicesPosition = 0;
                
                // check if the aura reached full size. states = {0, 0, 0, 1} is full aura
                if ((*states).x <= DBL_EPSILON &&
                    (*states).y <= DBL_EPSILON &&
                    (*states).z <= DBL_EPSILON &&
                    (*states).w + DBL_EPSILON >= 1.0) {
                    if ([[self flamesDelegate] respondsToSelector:@selector(flamesViewAuraDidDisplay:)]) {
                        [[self flamesDelegate] flamesViewAuraDidDisplay:self];
                    }
                }
            } else {
                auraTransitionFinished = YES;
            }
        }
        
        if ((_reduceMotionEnabled && states->w > 0.5) || (!_reduceMotionEnabled && states->w > 0.0)) {
            glUseProgram(_auraProgramHandle);
            
            // globally defined attributes
            glVertexAttrib4f(GLSL_STATES, (*states).x, (*states).y, (*states).z, (*states).w);
            glVertexAttrib4f(GLSL_IN_TIME_ZTIME_HEIGHT_ALPHA, flames.stateTime, flames.zTime, powerLevel, flames.globalAlpha);
            // FLAME ---------------------
            glDrawElements(GL_TRIANGLES, indicesLength, GL_UNSIGNED_INT, (void*)((indicesPosition) * sizeof(GLuint)));
            
            glUseProgram(_flameProgramHandle);
        } else {
            indicesLength = _numWaveIndices;
            indicesPosition = _numAuraIndices + _numAuraIndicesCulled;
            
            // globally defined attributes
            glVertexAttrib4f(GLSL_STATES, (*states).x, (*states).y, (*states).z, (*states).w);
            glVertexAttrib4f(GLSL_IN_TIME_ZTIME_HEIGHT_ALPHA, flames.stateTime, flames.zTime, powerLevel, flames.globalAlpha);
            // FLAME ---------------------
            glDrawElements(GL_TRIANGLES, indicesLength, GL_UNSIGNED_INT, (void*)((indicesPosition) * sizeof(GLuint)));
        }
        
        if (flames.globalAlpha == 0.0)
        {
            [discarded addObject:flames];
        }
    }
    
    if (discarded.count)
        [_flameGroups removeObjectsInArray:discarded];
    
#if USE_SIRI_GL_MULTISAMPLE
    //Bind both MSAA and View FrameBuffers.
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _framebufferHandle);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFBOName);
    
    glResolveMultisampleFramebufferAPPLE();
    
    // Discard the multisample color attachment now that we've resolved it
    const GLenum colorAttachment0 = GL_COLOR_ATTACHMENT0;
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, &colorAttachment0);
#endif
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbufferHandle);
    [_eaglContext presentRenderbuffer: GL_RENDERBUFFER];
    [self _restoreCurrentContext];
    
    if (!_transitionFinished) {
        // If freezing the aura, only consider a transition finished if both the flames and aura are finished.
        BOOL transitionFinished = _freezesAura ? (flamesTransitionFinished && auraTransitionFinished) : flamesTransitionFinished;
        if (transitionFinished) {
            _transitionFinished = YES;
            [self _didFinishTransition];
        }
    }
}
- (void)_didFinishTransition {
    [self _updateDisplayLinkPausedState];
}
+ (NSCache<NSString *, SUICGLIndexCacheEntry *> *)_indexCache {
    static NSCache<NSString *, SUICGLIndexCacheEntry *> *sIndexCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIndexCache = [[NSCache alloc] init];
        [sIndexCache setCountLimit:sIndexCacheSize];
    });
    return sIndexCache;
}
+ (void)setIndexCacheSize:(NSUInteger)size {
    sIndexCacheSize = size;
    [[self _indexCache] setCountLimit:sIndexCacheSize];
}
#pragma mark - Power level calculations
- (float)_currentMicPowerLevel {
    float power = [[self flamesDelegate] audioLevelForFlamesView:self];
    // map the 0.0–1.0 level we get from the smoother to the minimum/maximum with which we want to actually drive the animation
    return ([_levelSmoother smoothedLevelForMicPower:power] * (kMaximumPowerLevel - kMinimumPowerLevel)) + kMinimumPowerLevel;
}
#pragma mark - UITraitEnvironment
- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (previousTraitCollection) {
        UITraitCollection *currentTraitCollection = [self traitCollection];
        if ([currentTraitCollection displayScale] != [previousTraitCollection displayScale]) {
            // currently we only expect scale to change on J105a
            [self resetAndReinitialize:YES];
            [self _setValuesForFidelity:_fidelity];
            [self setNeedsLayout];
        }
    }
}
@end
