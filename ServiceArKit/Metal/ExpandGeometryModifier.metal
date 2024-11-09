/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A geometry modifier that scales an entity along its vertex normals.
*/


#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

/// Scales the entity along its vertex normals. The amount of scaling is based on a value contained in the first
/// component of the material's custom vector.
[[visible]]
void ExpandGeometryModifier(realitykit::geometry_parameters params)
{
    auto uniforms = params.uniforms();
    auto geometry = params.geometry();
 //   float2 uv0 = geometry.uv0();
    auto transform = uniforms.uv0_transform();
    float2 offset = uniforms.uv0_offset();
 //   float2 uv1 = geometry.uv1();
    float2 newUV0 = transform * geometry.uv0() + offset;
    
    params.geometry().set_uv0(newUV0);

}
