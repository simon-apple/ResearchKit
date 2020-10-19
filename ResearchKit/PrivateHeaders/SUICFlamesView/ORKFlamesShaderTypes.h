/*
See LICENSE folder for this sample’s licensing information.
Abstract:
Header containing types and enum constants shared between Metal shaders and C/ObjC source
*/
#include <simd/simd.h>
typedef struct {
    vector_float4 vertexLocation;
    vector_float4 color;
} Vertex;
// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
enum {
    SiriFlames_VertexInput_Polar,
    SiriFlames_VertexInput_Viewport,
    SiriFlames_VertexInput_Bounds,
    SiriFlames_VertexInput_Time_Ztime_Height_Alpha,
    SiriFlames_VertexInput_States,
};
