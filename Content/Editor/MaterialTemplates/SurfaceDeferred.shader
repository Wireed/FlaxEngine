// File generated by Flax Materials Editor
// Version: @0

#define MATERIAL 1
@3

#include "./Flax/Common.hlsl"
#include "./Flax/MaterialCommon.hlsl"
#include "./Flax/GBufferCommon.hlsl"
@7
// Primary constant buffer (with additional material parameters)
META_CB_BEGIN(0, Data)
float4x4 ViewProjectionMatrix;
float4x4 WorldMatrix;
float4x4 ViewMatrix;
float4x4 PrevViewProjectionMatrix;
float4x4 PrevWorldMatrix;
float3 ViewPos;
float ViewFar;
float3 ViewDir;
float TimeParam;
float4 ViewInfo;
float4 ScreenSize;
float4 LightmapArea;
float3 WorldInvScale;
float WorldDeterminantSign;
float2 Dummy0;
float LODDitherFactor;
float PerInstanceRandom;
float4 TemporalAAJitter;
float3 GeometrySize;
float Dummy1;
@1META_CB_END

#if CAN_USE_LIGHTMAP

// Irradiance and directionality prebaked lightmaps
Texture2D Lightmap0 : register(t0);
Texture2D Lightmap1 : register(t1);
Texture2D Lightmap2 : register(t2);

#endif

// Material shader resources
@2

// Interpolants passed from the vertex shader
struct VertexOutput
{
	float4 Position          : SV_Position;
	float3 WorldPosition     : TEXCOORD0;
	float2 TexCoord          : TEXCOORD1;
	float2 LightmapUV        : TEXCOORD2;
#if USE_VERTEX_COLOR
	half4 VertexColor        : COLOR;
#endif
	float3 WorldNormal       : TEXCOORD3;
	float4 WorldTangent      : TEXCOORD4;
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	float4 CustomVSToPS[CUSTOM_VERTEX_INTERPOLATORS_COUNT] : TEXCOORD9;
#endif
	float3 InstanceOrigin    : TEXCOORD6;
	float2 InstanceParams    : TEXCOORD7; // x-PerInstanceRandom, y-LODDitherFactor
#if IS_MOTION_VECTORS_PASS
	float3 PrevWorldPosition : TEXCOORD8;
#endif
#if USE_TESSELLATION
    float TessellationMultiplier : TESS;
#endif
};

// Interpolants passed to the pixel shader
struct PixelInput
{
	float4 Position          : SV_Position;
	float3 WorldPosition     : TEXCOORD0;
	float2 TexCoord          : TEXCOORD1;
	float2 LightmapUV        : TEXCOORD2;
#if USE_VERTEX_COLOR
	half4 VertexColor        : COLOR;
#endif
	float3 WorldNormal       : TEXCOORD3;
	float4 WorldTangent      : TEXCOORD4;
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	float4 CustomVSToPS[CUSTOM_VERTEX_INTERPOLATORS_COUNT] : TEXCOORD9;
#endif
	float3 InstanceOrigin    : TEXCOORD6;
	float2 InstanceParams    : TEXCOORD7; // x-PerInstanceRandom, y-LODDitherFactor
#if IS_MOTION_VECTORS_PASS
	float3 PrevWorldPosition : TEXCOORD8;
#endif
	bool IsFrontFace         : SV_IsFrontFace;
};

// Material properties generation input
struct MaterialInput
{
	float3 WorldPosition;
	float TwoSidedSign;
	float2 TexCoord;
#if USE_LIGHTMAP
	float2 LightmapUV;
#endif
#if USE_VERTEX_COLOR
	half4 VertexColor;
#endif
	float3x3 TBN;
	float4 SvPosition;
	float3 PreSkinnedPosition;
	float3 PreSkinnedNormal;
	float3 InstanceOrigin;
	float2 InstanceParams;
#if USE_INSTANCING
	float3 InstanceTransform1;
	float3 InstanceTransform2;
	float3 InstanceTransform3;
#endif
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	float4 CustomVSToPS[CUSTOM_VERTEX_INTERPOLATORS_COUNT];
#endif
};

float3x3 CalcTangentBasis(float3 normal, float4 tangent)
{
	float3 bitangent = cross(normal, tangent.xyz) * tangent.w;
	return float3x3(tangent.xyz, bitangent, normal);
}

MaterialInput GetMaterialInput(ModelInput input, VertexOutput output, float3 localNormal)
{
	MaterialInput result = (MaterialInput)0;
	result.WorldPosition = output.WorldPosition;
	result.TexCoord = output.TexCoord;
#if USE_LIGHTMAP
	result.LightmapUV = output.LightmapUV;
#endif
#if USE_VERTEX_COLOR
	result.VertexColor = output.VertexColor;
#endif
	result.TBN = CalcTangentBasis(output.WorldNormal, output.WorldTangent);
	result.TwoSidedSign = WorldDeterminantSign;
	result.SvPosition = output.Position;
	result.PreSkinnedPosition = input.Position.xyz;
	result.PreSkinnedNormal = localNormal;
#if USE_INSTANCING
	result.InstanceOrigin = input.InstanceOrigin.xyz;
	result.InstanceParams = float2(input.InstanceOrigin.w, input.InstanceTransform1.w);
	result.InstanceTransform1 = input.InstanceTransform1.xyz;
	result.InstanceTransform2 = input.InstanceTransform2.xyz;
	result.InstanceTransform3 = input.InstanceTransform3.xyz;
#else
	result.InstanceOrigin = WorldMatrix[3].xyz;
	result.InstanceParams = float2(PerInstanceRandom, LODDitherFactor);
#endif
	return result;
}

MaterialInput GetMaterialInput(VertexOutput output, float3 localPosition, float3 localNormal)
{
	MaterialInput result = (MaterialInput)0;
	result.WorldPosition = output.WorldPosition;
	result.TexCoord = output.TexCoord;
#if USE_LIGHTMAP
	result.LightmapUV = output.LightmapUV;
#endif
#if USE_VERTEX_COLOR
	result.VertexColor = output.VertexColor;
#endif
	result.TBN = CalcTangentBasis(output.WorldNormal, output.WorldTangent);
	result.TwoSidedSign = WorldDeterminantSign;
	result.InstanceOrigin = WorldMatrix[3].xyz;
	result.InstanceParams = float2(PerInstanceRandom, LODDitherFactor);
	result.SvPosition = output.Position;
	result.PreSkinnedPosition = localPosition;
	result.PreSkinnedNormal = localNormal;
	return result;
}

MaterialInput GetMaterialInput(PixelInput input)
{
	MaterialInput result = (MaterialInput)0;
	result.WorldPosition = input.WorldPosition;
	result.TexCoord = input.TexCoord;
#if USE_LIGHTMAP
	result.LightmapUV = input.LightmapUV;
#endif
#if USE_VERTEX_COLOR
	result.VertexColor = input.VertexColor;
#endif
	result.TBN = CalcTangentBasis(input.WorldNormal, input.WorldTangent);
	result.TwoSidedSign = WorldDeterminantSign * (input.IsFrontFace ? 1.0 : -1.0);
	result.InstanceOrigin = input.InstanceOrigin;
	result.InstanceParams = input.InstanceParams;
	result.SvPosition = input.Position;
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	result.CustomVSToPS = input.CustomVSToPS;
#endif
	return result;
}

#if USE_INSTANCING
#define INSTANCE_TRANS_WORLD float4x4(float4(input.InstanceTransform1.xyz, 0.0f), float4(input.InstanceTransform2.xyz, 0.0f), float4(input.InstanceTransform3.xyz, 0.0f), float4(input.InstanceOrigin.xyz, 1.0f))
#else
#define INSTANCE_TRANS_WORLD WorldMatrix
#endif

// Gets the local to world transform matrix (supports instancing)
float4x4 GetInstanceTransform(ModelInput input)
{
	return INSTANCE_TRANS_WORLD;
}
float4x4 GetInstanceTransform(ModelInput_Skinned input)
{
	return INSTANCE_TRANS_WORLD;
}
float4x4 GetInstanceTransform(ModelInput_PosOnly input)
{
	return INSTANCE_TRANS_WORLD;
}
float4x4 GetInstanceTransform(MaterialInput input)
{
	return INSTANCE_TRANS_WORLD;
}

// Removes the scale vector from the local to world transformation matrix (supports instancing)
float3x3 RemoveScaleFromLocalToWorld(float3x3 localToWorld)
{
#if USE_INSTANCING
	// Extract per axis scales from localToWorld transform
	float scaleX = length(localToWorld[0]);
	float scaleY = length(localToWorld[1]);
	float scaleZ = length(localToWorld[2]);
	float3 invScale = float3(
		scaleX > 0.00001f ? 1.0f / scaleX : 0.0f,
		scaleY > 0.00001f ? 1.0f / scaleY : 0.0f,
		scaleZ > 0.00001f ? 1.0f / scaleZ : 0.0f);
#else
	float3 invScale = WorldInvScale;
#endif
	localToWorld[0] *= invScale.x;
	localToWorld[1] *= invScale.y;
	localToWorld[2] *= invScale.z;
	return localToWorld;
}

// Transforms a vector from tangent space to world space
float3 TransformTangentVectorToWorld(MaterialInput input, float3 tangentVector)
{
	return mul(tangentVector, input.TBN);
}

// Transforms a vector from world space to tangent space
float3 TransformWorldVectorToTangent(MaterialInput input, float3 worldVector)
{
	return mul(input.TBN, worldVector);
}

// Transforms a vector from world space to view space
float3 TransformWorldVectorToView(MaterialInput input, float3 worldVector)
{
	return mul(worldVector, (float3x3)ViewMatrix);
}

// Transforms a vector from view space to world space
float3 TransformViewVectorToWorld(MaterialInput input, float3 viewVector)
{
	return mul((float3x3)ViewMatrix, viewVector);
}

// Transforms a vector from local space to world space
float3 TransformLocalVectorToWorld(MaterialInput input, float3 localVector)
{
	float3x3 localToWorld = (float3x3)GetInstanceTransform(input);
	//localToWorld = RemoveScaleFromLocalToWorld(localToWorld);
	return mul(localVector, localToWorld);
}

// Transforms a vector from local space to world space
float3 TransformWorldVectorToLocal(MaterialInput input, float3 worldVector)
{
	float3x3 localToWorld = (float3x3)GetInstanceTransform(input);
	//localToWorld = RemoveScaleFromLocalToWorld(localToWorld);
	return mul(localToWorld, worldVector);
}

// Gets the current object position (supports instancing)
float3 GetObjectPosition(MaterialInput input)
{
	return input.InstanceOrigin.xyz;
}

// Gets the current object size (supports instancing)
float3 GetObjectSize(MaterialInput input)
{
	float4x4 world = GetInstanceTransform(input);
	return GeometrySize * float3(world._m00, world._m11, world._m22);
}

// Get the current object random value (supports instancing)
float GetPerInstanceRandom(MaterialInput input)
{
	return input.InstanceParams.x;
}

// Get the current object LOD transition dither factor (supports instancing)
float GetLODDitherFactor(MaterialInput input)
{
#if USE_DITHERED_LOD_TRANSITION
	return input.InstanceParams.y;
#else
	return 0;
#endif
}

// Gets the interpolated vertex color (in linear space)
float4 GetVertexColor(MaterialInput input)
{
#if USE_VERTEX_COLOR
	return input.VertexColor;
#else
	return 1;
#endif
}

// Get material properties function (for vertex shader)
Material GetMaterialVS(MaterialInput input)
{
@5
}

// Get material properties function (for domain shader)
Material GetMaterialDS(MaterialInput input)
{
@6
}

// Get material properties function (for pixel shader)
Material GetMaterialPS(MaterialInput input)
{
@4
}

// Programmatically set the line number after all the material inputs which have a variable number of line endings
// This allows shader error line numbers after this point to be the same regardless of which material is being compiled
#line 1000

// Calculates the transform matrix from mesh tangent space to local space
float3x3 CalcTangentToLocal(ModelInput input)
{
	float bitangentSign = input.Tangent.w ? -1.0f : +1.0f;
	float3 normal = input.Normal.xyz * 2.0 - 1.0;
	float3 tangent = input.Tangent.xyz * 2.0 - 1.0;
	float3 bitangent = cross(normal, tangent) * bitangentSign;
	return float3x3(tangent, bitangent, normal);
}

float3x3 CalcTangentToWorld(float4x4 world, float3x3 tangentToLocal)
{
	float3x3 localToWorld = RemoveScaleFromLocalToWorld((float3x3)world);
	return mul(tangentToLocal, localToWorld); 
}

// Vertex Shader function for GBuffer Pass and Depth Pass (with full vertex data)
META_VS(IS_SURFACE, FEATURE_LEVEL_ES2)
META_PERMUTATION_1(USE_INSTANCING=0)
META_PERMUTATION_1(USE_INSTANCING=1)
META_PERMUTATION_2(USE_INSTANCING=0, IS_MOTION_VECTORS_PASS=1)
META_VS_IN_ELEMENT(POSITION, 0, R32G32B32_FLOAT,   0, 0,     PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(TEXCOORD, 0, R16G16_FLOAT,      1, 0,     PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(NORMAL,   0, R10G10B10A2_UNORM, 1, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(TANGENT,  0, R10G10B10A2_UNORM, 1, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(TEXCOORD, 1, R16G16_FLOAT,      1, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(COLOR,    0, R8G8B8A8_UNORM,    2, 0,     PER_VERTEX, 0, USE_VERTEX_COLOR)
META_VS_IN_ELEMENT(ATTRIBUTE,0, R32G32B32A32_FLOAT,3, 0,     PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,1, R32G32B32A32_FLOAT,3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,2, R32G32B32_FLOAT,   3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,3, R32G32B32_FLOAT,   3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,4, R16G16B16A16_FLOAT,3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
VertexOutput VS(ModelInput input)
{
	VertexOutput output;

	// Compute world space vertex position
	float4x4 world = GetInstanceTransform(input);
	output.WorldPosition = mul(float4(input.Position.xyz, 1), world).xyz;
#if IS_MOTION_VECTORS_PASS
	output.PrevWorldPosition = mul(float4(input.Position.xyz, 1), PrevWorldMatrix).xyz;
#endif

	// Compute clip space position
	output.Position = mul(float4(output.WorldPosition.xyz, 1), ViewProjectionMatrix);

	// Pass vertex attributes
	output.TexCoord = input.TexCoord;
#if USE_VERTEX_COLOR
	output.VertexColor = input.Color;
#endif
	output.InstanceOrigin = world[3].xyz;
#if USE_INSTANCING
	output.LightmapUV = input.LightmapUV * input.InstanceLightmapArea.zw + input.InstanceLightmapArea.xy;
	output.InstanceParams = float2(input.InstanceOrigin.w, input.InstanceTransform1.w);
#else
	output.LightmapUV = input.LightmapUV * LightmapArea.zw + LightmapArea.xy;
	output.InstanceParams = float2(PerInstanceRandom, LODDitherFactor);
#endif

	// Calculate tanget space to world space transformation matrix for unit vectors
	float3x3 tangentToLocal = CalcTangentToLocal(input);
	float3x3 tangentToWorld = CalcTangentToWorld(world, tangentToLocal);
	output.WorldNormal = tangentToWorld[2];
	output.WorldTangent.xyz = tangentToWorld[0];
	output.WorldTangent.w = input.Tangent.w ? -1.0f : +1.0f;

	// Get material input params if need to evaluate any material property
#if USE_POSITION_OFFSET || USE_TESSELLATION || USE_CUSTOM_VERTEX_INTERPOLATORS
	MaterialInput materialInput = GetMaterialInput(input, output, tangentToLocal[2].xyz);
	Material material = GetMaterialVS(materialInput);
#endif

	// Apply world position offset per-vertex
#if USE_POSITION_OFFSET
	output.WorldPosition += material.PositionOffset;
	output.Position = mul(float4(output.WorldPosition.xyz, 1), ViewProjectionMatrix);
#endif

	// Get tessalation multiplier (per vertex)
#if USE_TESSELLATION
    output.TessellationMultiplier = material.TessellationMultiplier;
#endif

	// Copy interpolants for other shader stages
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	output.CustomVSToPS = material.CustomVSToPS;
#endif

	return output;
}

// Vertex Shader function for Depth Pass
META_VS(IS_SURFACE, FEATURE_LEVEL_ES2)
META_PERMUTATION_1(USE_INSTANCING=0)
META_PERMUTATION_1(USE_INSTANCING=1)
META_VS_IN_ELEMENT(POSITION, 0, R32G32B32_FLOAT,   0, 0,     PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(ATTRIBUTE,0, R32G32B32A32_FLOAT,3, 0,     PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,1, R32G32B32A32_FLOAT,3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,2, R32G32B32_FLOAT,   3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,3, R32G32B32_FLOAT,   3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
META_VS_IN_ELEMENT(ATTRIBUTE,4, R16G16B16A16_FLOAT,3, ALIGN, PER_INSTANCE, 1, USE_INSTANCING)
float4 VS_Depth(ModelInput_PosOnly input) : SV_Position
{
	float4x4 world = GetInstanceTransform(input);
	float3 worldPosition = mul(float4(input.Position.xyz, 1), world).xyz;
	float4 position = mul(float4(worldPosition.xyz, 1), ViewProjectionMatrix);
	return position;
}

#if USE_SKINNING

// The skeletal bones matrix buffer (stored as 4x3, 3 float4 behind each other)
Buffer<float4> BoneMatrices : register(t0);

#if PER_BONE_MOTION_BLUR

// The skeletal bones matrix buffer from the previous frame
Buffer<float4> PrevBoneMatrices : register(t1);

float3x4 GetPrevBoneMatrix(int index)
{
	float4 a = PrevBoneMatrices[index * 3];
	float4 b = PrevBoneMatrices[index * 3 + 1];
	float4 c = PrevBoneMatrices[index * 3 + 2];
	return float3x4(a, b, c);
}

float3 SkinPrevPosition(ModelInput_Skinned input)
{
	float4 position = float4(input.Position.xyz, 1);
	float3x4 boneMatrix = input.BlendWeights.x * GetPrevBoneMatrix(input.BlendIndices.x);
	boneMatrix += input.BlendWeights.y * GetPrevBoneMatrix(input.BlendIndices.y);
	boneMatrix += input.BlendWeights.z * GetPrevBoneMatrix(input.BlendIndices.z);
	boneMatrix += input.BlendWeights.w * GetPrevBoneMatrix(input.BlendIndices.w);
	return mul(boneMatrix, position);
}

#endif

// Cached skinning data to avoid multiple calculation 
struct SkinningData
{
	float3x4 BlendMatrix;
};

// Calculates the transposed transform matrix for the given bone index
float3x4 GetBoneMatrix(int index)
{
	float4 a = BoneMatrices[index * 3];
	float4 b = BoneMatrices[index * 3 + 1];
	float4 c = BoneMatrices[index * 3 + 2];
	return float3x4(a, b, c);
}

// Calculates the transposed transform matrix for the given vertex (uses blending)
float3x4 CalcBoneMatrix(ModelInput_Skinned input)
{
	float3x4 boneMatrix = input.BlendWeights.x * GetBoneMatrix(input.BlendIndices.x);
	boneMatrix += input.BlendWeights.y * GetBoneMatrix(input.BlendIndices.y);
	boneMatrix += input.BlendWeights.z * GetBoneMatrix(input.BlendIndices.z);
	boneMatrix += input.BlendWeights.w * GetBoneMatrix(input.BlendIndices.w);
	return boneMatrix;
}

// Transforms the vertex position by weighted sum of the skinning matrices
float3 SkinPosition(ModelInput_Skinned input, SkinningData data)
{
	float4 position = float4(input.Position.xyz, 1);
	return mul(data.BlendMatrix, position);
}

// Transforms the vertex position by weighted sum of the skinning matrices
float3x3 SkinTangents(ModelInput_Skinned input, SkinningData data)
{
	// Unpack vertex tangent frame
	float bitangentSign = input.Tangent.w ? -1.0f : +1.0f;
	float3 normal = input.Normal.xyz * 2.0 - 1.0;
	float3 tangent = input.Tangent.xyz * 2.0 - 1.0;

	// Apply skinning
	tangent = mul(data.BlendMatrix, float4(tangent, 0));
	normal = mul(data.BlendMatrix, float4(normal, 0));

	float3 bitangent = cross(normal, tangent) * bitangentSign;
	return float3x3(tangent, bitangent, normal);
}

// Vertex Shader function for GBuffers/Depth Pass (skinned mesh rendering)
META_VS(IS_SURFACE, FEATURE_LEVEL_ES2)
META_PERMUTATION_1(USE_SKINNING=1)
META_PERMUTATION_2(USE_SKINNING=1, IS_MOTION_VECTORS_PASS=1)
META_PERMUTATION_3(USE_SKINNING=1, IS_MOTION_VECTORS_PASS=1, PER_BONE_MOTION_BLUR=1)
META_VS_IN_ELEMENT(POSITION,     0, R32G32B32_FLOAT,   0, 0,     PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(TEXCOORD,     0, R16G16_FLOAT,      0, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(NORMAL,       0, R10G10B10A2_UNORM, 0, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(TANGENT,      0, R10G10B10A2_UNORM, 0, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(BLENDINDICES, 0, R8G8B8A8_UINT,     0, ALIGN, PER_VERTEX, 0, true)
META_VS_IN_ELEMENT(BLENDWEIGHT,  0, R16G16B16A16_FLOAT,0, ALIGN, PER_VERTEX, 0, true)
VertexOutput VS_Skinned(ModelInput_Skinned input)
{
	VertexOutput output;
	
	// Perform skinning
	SkinningData data;
	data.BlendMatrix = CalcBoneMatrix(input);
	float3 position = SkinPosition(input, data);
	float3x3 tangentToLocal = SkinTangents(input, data);
	
	// Compute world space vertex position
	float4x4 world = GetInstanceTransform(input);
	output.WorldPosition = mul(float4(position, 1), world).xyz;
#if IS_MOTION_VECTORS_PASS
#if PER_BONE_MOTION_BLUR
	float3 prevPosition = SkinPrevPosition(input);
	output.PrevWorldPosition = mul(float4(prevPosition, 1), PrevWorldMatrix).xyz;
#else
	output.PrevWorldPosition = mul(float4(position, 1), PrevWorldMatrix).xyz;
#endif
#endif

	// Compute clip space position
	output.Position = mul(float4(output.WorldPosition.xyz, 1), ViewProjectionMatrix);

	// Pass vertex attributes
	output.TexCoord = input.TexCoord;
#if USE_VERTEX_COLOR
	output.VertexColor = float4(0, 0, 0, 1);
#endif
	output.LightmapUV = float2(0, 0);
	output.InstanceOrigin = world[3].xyz;
#if USE_INSTANCING
	output.InstanceParams = float2(input.InstanceOrigin.w, input.InstanceTransform1.w);
#else
	output.InstanceParams = float2(PerInstanceRandom, LODDitherFactor);
#endif

	// Calculate tanget space to world space transformation matrix for unit vectors
	float3x3 tangentToWorld = CalcTangentToWorld(world, tangentToLocal);
	output.WorldNormal = tangentToWorld[2];
	output.WorldTangent.xyz = tangentToWorld[0];
	output.WorldTangent.w = input.Tangent.w ? -1.0f : +1.0f;

	// Get material input params if need to evaluate any material property
#if USE_POSITION_OFFSET || USE_TESSELLATION || USE_CUSTOM_VERTEX_INTERPOLATORS
	MaterialInput materialInput = GetMaterialInput(output, input.Position.xyz, tangentToLocal[2].xyz);
	Material material = GetMaterialVS(materialInput);
#endif

	// Apply world position offset per-vertex
#if USE_POSITION_OFFSET
	output.WorldPosition += material.PositionOffset;
	output.Position = mul(float4(output.WorldPosition.xyz, 1), ViewProjectionMatrix);
#endif

	// Get tessalation multiplier (per vertex)
#if USE_TESSELLATION
    output.TessellationMultiplier = material.TessellationMultiplier;
#endif
	
	// Copy interpolants for other shader stages
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	output.CustomVSToPS = material.CustomVSToPS;
#endif

	return output;
}

#endif

#if USE_TESSELLATION

// Interpolants passed from the hull shader to the domain shader
struct TessalationHSToDS
{
	float4 Position          : SV_Position;
	float3 WorldPosition     : TEXCOORD0;
	float2 TexCoord          : TEXCOORD1;
	float2 LightmapUV        : TEXCOORD2;
#if USE_VERTEX_COLOR
	half4 VertexColor        : COLOR;
#endif
	float3 WorldNormal       : TEXCOORD3;
	float4 WorldTangent      : TEXCOORD4;
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	float4 CustomVSToPS[CUSTOM_VERTEX_INTERPOLATORS_COUNT] : TEXCOORD9;
#endif
	float3 InstanceOrigin    : TEXCOORD6;
	float2 InstanceParams    : TEXCOORD7;
#if IS_MOTION_VECTORS_PASS
	float3 PrevWorldPosition : TEXCOORD8;
#endif
	float TessellationMultiplier : TESS;
};

// Interpolants passed from the domain shader and to the pixel shader
struct TessalationDSToPS
{
	float4 Position          : SV_Position;
	float3 WorldPosition     : TEXCOORD0;
	float2 TexCoord          : TEXCOORD1;
	float2 LightmapUV        : TEXCOORD2;
#if USE_VERTEX_COLOR
	half4 VertexColor        : COLOR;
#endif
	float3 WorldNormal       : TEXCOORD3;
	float4 WorldTangent      : TEXCOORD4;
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	float4 CustomVSToPS[CUSTOM_VERTEX_INTERPOLATORS_COUNT] : TEXCOORD9;
#endif
	float3 InstanceOrigin    : TEXCOORD6;
	float2 InstanceParams    : TEXCOORD7;
#if IS_MOTION_VECTORS_PASS
	float3 PrevWorldPosition : TEXCOORD8;
#endif
};

MaterialInput GetMaterialInput(TessalationDSToPS input)
{
	MaterialInput result = (MaterialInput)0;
	result.WorldPosition = input.WorldPosition;
	result.TexCoord = input.TexCoord;
#if USE_LIGHTMAP
	result.LightmapUV = input.LightmapUV;
#endif
#if USE_VERTEX_COLOR
	result.VertexColor = input.VertexColor;
#endif
	result.TBN = CalcTangentBasis(input.WorldNormal, input.WorldTangent);
	result.TwoSidedSign = WorldDeterminantSign;
	result.InstanceOrigin = input.InstanceOrigin;
	result.InstanceParams = input.InstanceParams;
	result.SvPosition = input.Position;
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	result.CustomVSToPS = input.CustomVSToPS;
#endif
	return result;
}

struct TessalationPatch
{
	float EdgeTessFactor[3] : SV_TessFactor;
	float InsideTessFactor  : SV_InsideTessFactor;
#if MATERIAL_TESSELLATION == MATERIAL_TESSELLATION_PN
	float3 B210 : POSITION4;
	float3 B120 : POSITION5;
	float3 B021 : POSITION6;
	float3 B012 : POSITION7;
	float3 B102 : POSITION8;
	float3 B201 : POSITION9;
	float3 B111 : CENTER;
#endif
};

TessalationPatch HS_PatchConstant(InputPatch<VertexOutput, 3> input)
{
	TessalationPatch output;

	// Average tess factors along edges, and pick an edge tess factor for the interior tessellation
	float4 tessellationMultipliers;
	tessellationMultipliers.x = 0.5f * (input[1].TessellationMultiplier + input[2].TessellationMultiplier);
	tessellationMultipliers.y = 0.5f * (input[2].TessellationMultiplier + input[0].TessellationMultiplier);
	tessellationMultipliers.z = 0.5f * (input[0].TessellationMultiplier + input[1].TessellationMultiplier);
	tessellationMultipliers.w = 0.333f * (input[0].TessellationMultiplier + input[1].TessellationMultiplier + input[2].TessellationMultiplier);
	tessellationMultipliers = clamp(tessellationMultipliers, 1, MAX_TESSELLATION_FACTOR);

	output.EdgeTessFactor[0] = tessellationMultipliers.x; // 1->2 edge
	output.EdgeTessFactor[1] = tessellationMultipliers.y; // 2->0 edge
	output.EdgeTessFactor[2] = tessellationMultipliers.z; // 0->1 edge
	output.InsideTessFactor  = tessellationMultipliers.w;

#if MATERIAL_TESSELLATION == MATERIAL_TESSELLATION_PN
	// Calculate PN-Triangle coefficients
	// Refer to Vlachos 2001 for the original formula
	float3 p1 = input[0].WorldPosition;
	float3 p2 = input[1].WorldPosition;
	float3 p3 = input[2].WorldPosition;
	float3 n1 = input[0].WorldNormal;
	float3 n2 = input[1].WorldNormal;
	float3 n3 = input[2].WorldNormal;

	// Calculate control points
	output.B210 = (2.0f * p1 + p2 - dot((p2 - p1), n1) * n1) / 3.0f;
	output.B120 = (2.0f * p2 + p1 - dot((p1 - p2), n2) * n2) / 3.0f;
	output.B021 = (2.0f * p2 + p3 - dot((p3 - p2), n2) * n2) / 3.0f;
	output.B012 = (2.0f * p3 + p2 - dot((p2 - p3), n3) * n3) / 3.0f;
	output.B102 = (2.0f * p3 + p1 - dot((p1 - p3), n3) * n3) / 3.0f;
	output.B201 = (2.0f * p1 + p3 - dot((p3 - p1), n1) * n1) / 3.0f;
	float3 e = (output.B210 + output.B120 + output.B021 + 
	output.B012 + output.B102 + output.B201) / 6.0f;
	float3 v = (p1 + p2 + p3) / 3.0f;
	output.B111 = e + ((e - v) / 2.0f);
#endif

	return output;
}

META_HS(USE_TESSELLATION, FEATURE_LEVEL_SM5)
META_PERMUTATION_1(IS_MOTION_VECTORS_PASS=0)
META_PERMUTATION_1(IS_MOTION_VECTORS_PASS=1)
META_HS_PATCH(TESSELLATION_IN_CONTROL_POINTS)
[domain("tri")]
[partitioning("fractional_odd")]
[outputtopology("triangle_cw")]
[maxtessfactor(MAX_TESSELLATION_FACTOR)]
[outputcontrolpoints(3)]
[patchconstantfunc("HS_PatchConstant")]
TessalationHSToDS HS(InputPatch<VertexOutput, TESSELLATION_IN_CONTROL_POINTS> input, uint ControlPointID : SV_OutputControlPointID)
{
	TessalationHSToDS output;

	// Pass through shader
#define COPY(thing) output.thing = input[ControlPointID].thing;
	COPY(Position);
	COPY(WorldPosition);
	COPY(TexCoord);
	COPY(LightmapUV);
#if USE_VERTEX_COLOR
	COPY(VertexColor);
#endif
	COPY(WorldNormal);
	COPY(WorldTangent);
	COPY(InstanceOrigin);
	COPY(InstanceParams);
#if IS_MOTION_VECTORS_PASS
	COPY(PrevWorldPosition);
#endif
	COPY(TessellationMultiplier);
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	COPY(CustomVSToPS);
#endif
#undef COPY

	return output;
}

#if MATERIAL_TESSELLATION == MATERIAL_TESSELLATION_PHONG

// Orthogonal projection on to plane
float3 ProjectOntoPlane(float3 planeNormal, float3 planePoint, float3 pointToProject)
{
    return pointToProject - dot(pointToProject-planePoint, planeNormal) * planeNormal;
}

#endif

META_DS(USE_TESSELLATION, FEATURE_LEVEL_SM5)
META_PERMUTATION_1(IS_MOTION_VECTORS_PASS=0)
META_PERMUTATION_1(IS_MOTION_VECTORS_PASS=1)
[domain("tri")]
TessalationDSToPS DS(TessalationPatch constantData, float3 barycentricCoords : SV_DomainLocation, const OutputPatch<TessalationHSToDS, 3> input)
{
	TessalationDSToPS output;

	// Get the barycentric coords
	float U = barycentricCoords.x;
	float V = barycentricCoords.y;
	float W = barycentricCoords.z;

	// Interpolate patch attributes to generated vertices
#define INTERPOLATE(thing) output.thing = U * input[0].thing + V * input[1].thing + W * input[2].thing
#define COPY(thing) output.thing = input[0].thing
	INTERPOLATE(Position);
#if MATERIAL_TESSELLATION == MATERIAL_TESSELLATION_PN
	// Precompute squares and squares * 3 
	float UU = U * U;
	float VV = V * V;
	float WW = W * W;
	float UU3 = UU * 3.0f;
	float VV3 = VV * 3.0f;
	float WW3 = WW * 3.0f;

	// Interpolate using barycentric coordinates and PN Triangle control points
	output.WorldPosition =
		input[0].WorldPosition * UU * U +
		input[1].WorldPosition * VV * V + 
		input[2].WorldPosition * WW * W + 
		constantData.B210 * UU3 * V +
		constantData.B120 * VV3 * U +
		constantData.B021 * VV3 * W +
		constantData.B012 * WW3 * V +
		constantData.B102 * WW3 * U +
		constantData.B201 * UU3 * W +
		constantData.B111 * 6.0f * W * U * V;
#if IS_MOTION_VECTORS_PASS
	output.PrevWorldPosition =
		input[0].PrevWorldPosition * UU * U +
		input[1].PrevWorldPosition * VV * V + 
		input[2].PrevWorldPosition * WW * W + 
		constantData.B210 * UU3 * V +
		constantData.B120 * VV3 * U +
		constantData.B021 * VV3 * W +
		constantData.B012 * WW3 * V +
		constantData.B102 * WW3 * U +
		constantData.B201 * UU3 * W +
		constantData.B111 * 6.0f * W * U * V;
#endif
#else
	INTERPOLATE(WorldPosition);
#if IS_MOTION_VECTORS_PASS
	INTERPOLATE(PrevWorldPosition);
#endif
#endif
	INTERPOLATE(TexCoord);
	INTERPOLATE(LightmapUV);
#if USE_VERTEX_COLOR
	INTERPOLATE(VertexColor);
#endif
	INTERPOLATE(WorldNormal);
	INTERPOLATE(WorldTangent);
	COPY(InstanceOrigin);
	COPY(InstanceParams);
#if USE_CUSTOM_VERTEX_INTERPOLATORS
	UNROLL
	for (int i = 0; i < CUSTOM_VERTEX_INTERPOLATORS_COUNT; i++)
	{
		INTERPOLATE(CustomVSToPS[i]);
	}
#endif
#undef INTERPOLATE
#undef COPY

	// Interpolating tangents can unnormalize it, so normalize it
	output.WorldNormal = normalize(output.WorldNormal);
	output.WorldTangent.xyz = normalize(output.WorldTangent.xyz);

#if MATERIAL_TESSELLATION == MATERIAL_TESSELLATION_PHONG
	// Orthogonal projection in the tangent planes
	float3 posProjectedU = ProjectOntoPlane(input[0].WorldNormal, input[0].WorldPosition, output.WorldPosition);
	float3 posProjectedV = ProjectOntoPlane(input[1].WorldNormal, input[1].WorldPosition, output.WorldPosition);
	float3 posProjectedW = ProjectOntoPlane(input[2].WorldNormal, input[2].WorldPosition, output.WorldPosition);

	// Interpolate the projected points
	output.WorldPosition = U * posProjectedU + V * posProjectedV + W * posProjectedW;
#if IS_MOTION_VECTORS_PASS
	posProjectedU = ProjectOntoPlane(input[0].WorldNormal, input[0].PrevWorldPosition, output.PrevWorldPosition);
	posProjectedV = ProjectOntoPlane(input[1].WorldNormal, input[1].PrevWorldPosition, output.PrevWorldPosition);
	posProjectedW = ProjectOntoPlane(input[2].WorldNormal, input[2].PrevWorldPosition, output.PrevWorldPosition);
	output.PrevWorldPosition = U * posProjectedU + V * posProjectedV + W * posProjectedW;
#endif
#endif

	// Perform displacement mapping
#if USE_DISPLACEMENT
	MaterialInput materialInput = GetMaterialInput(output);
	Material material = GetMaterialDS(materialInput);
	output.WorldPosition += material.WorldDisplacement;
#if IS_MOTION_VECTORS_PASS
	output.PrevWorldPosition += material.WorldDisplacement;
#endif
#endif

	// Recalculate the clip space position
	output.Position = mul(float4(output.WorldPosition, 1), ViewProjectionMatrix);

	return output;
}

#endif

#if USE_LIGHTMAP

float3 SampleLightmap(Material material, MaterialInput materialInput)
{
	// Sample lightmaps
	float4 lightmap0 = Lightmap0.Sample(SamplerLinearClamp, materialInput.LightmapUV);
	float4 lightmap1 = Lightmap1.Sample(SamplerLinearClamp, materialInput.LightmapUV);
	float4 lightmap2 = Lightmap2.Sample(SamplerLinearClamp, materialInput.LightmapUV);

	// Unpack H-basis
	float3 h0 = float3(lightmap0.x, lightmap1.x, lightmap2.x);
	float3 h1 = float3(lightmap0.y, lightmap1.y, lightmap2.y);
	float3 h2 = float3(lightmap0.z, lightmap1.z, lightmap2.z);
	float3 h3 = float3(lightmap0.w, lightmap1.w, lightmap2.w);

	// Sample baked diffuse irradiance from the H-basis coefficients
	float3 normal = material.TangentNormal;
#if MATERIAL_SHADING_MODEL == SHADING_MODEL_FOLIAGE
	normal *= material.TangentNormal;
#endif
	return GetHBasisIrradiance(normal, h0, h1, h2, h3) / PI;
}

#endif

#if USE_DITHERED_LOD_TRANSITION

void ClipLODTransition(PixelInput input)
{
	float ditherFactor = input.InstanceParams.y;
	if (abs(ditherFactor) > 0.001)
	{
		float randGrid = cos(dot(floor(input.Position.xy), float2(347.83452793, 3343.28371863)));
		float randGridFrac = frac(randGrid * 1000.0);
		half mask = (ditherFactor < 0.0) ? (ditherFactor + 1.0 > randGridFrac) : (ditherFactor < randGridFrac);
		clip(mask - 0.001);
	}
}

#else

void ClipLODTransition(PixelInput input)
{
}

#endif

// Pixel Shader function for GBuffer Pass
META_PS(true, FEATURE_LEVEL_ES2)
META_PERMUTATION_1(USE_LIGHTMAP=0)
META_PERMUTATION_1(USE_LIGHTMAP=1)
void PS_GBuffer(
		in PixelInput input
		,out float4 Light : SV_Target0
#if MATERIAL_DOMAIN == MATERIAL_DOMAIN_SURFACE
		// GBuffer
		,out float4 RT0   : SV_Target1
		,out float4 RT1   : SV_Target2
		,out float4 RT2   : SV_Target3
#if USE_GBUFFER_CUSTOM_DATA
		,out float4 RT3   : SV_Target4
#endif
#endif
	)
{
	Light = 0;

	// LOD masking
	ClipLODTransition(input);

	// Get material parameters
	MaterialInput materialInput = GetMaterialInput(input);
	Material material = GetMaterialPS(materialInput);

#if MATERIAL_DOMAIN == MATERIAL_DOMAIN_SURFACE

	// Masking
#if MATERIAL_MASKED
	clip(material.Mask - MATERIAL_MASK_THRESHOLD);
#endif
	
#if USE_LIGHTMAP

	float3 diffuseColor = GetDiffuseColor(material.Color, material.Metalness);
	float3 specularColor = GetSpecularColor(material.Color, material.Specular, material.Metalness);

	// Sample lightmap
	float3 diffuseIndirectLighting = SampleLightmap(material, materialInput);

	// Apply static indirect light
	Light.rgb = diffuseColor * diffuseIndirectLighting * AOMultiBounce(material.AO, diffuseColor);

#endif

	// Pack material properties to GBuffer
	RT0 = float4(material.Color, material.AO);
	RT1 = float4(material.WorldNormal * 0.5 + 0.5, MATERIAL_SHADING_MODEL * (1.0 / 3.0));
	RT2 = float4(material.Roughness, material.Metalness, material.Specular, 0);

	// Custom data
#if USE_GBUFFER_CUSTOM_DATA
#if MATERIAL_SHADING_MODEL == SHADING_MODEL_SUBSURFACE
	RT3 = float4(material.SubsurfaceColor, material.Opacity);
#elif MATERIAL_SHADING_MODEL == SHADING_MODEL_FOLIAGE
	RT3 = float4(material.SubsurfaceColor, material.Opacity);
#else
	RT3 = float4(0, 0, 0, 0);
#endif
#endif

#endif

	// Add light emission
#if USE_EMISSIVE
	Light.rgb += material.Emissive;
#endif
}

// Pixel Shader function for Depth Pass
META_PS(IS_SURFACE, FEATURE_LEVEL_ES2)
void PS_Depth(PixelInput input
#if GLSL
	, out float4 OutColor : SV_Target0
#endif
	)
{	
	// LOD masking
	ClipLODTransition(input);

#if MATERIAL_MASKED
	// Perform per pixel clipping if material requries it
	MaterialInput materialInput = GetMaterialInput(input);
	Material material = GetMaterialPS(materialInput);
	clip(material.Mask - MATERIAL_MASK_THRESHOLD);
#endif

#if GLSL
	OutColor = 0;
#endif
}

// Pixel Shader function for Motion Vectors Pass
META_PS(true, FEATURE_LEVEL_ES2)
META_PERMUTATION_1(IS_MOTION_VECTORS_PASS=1)
float4 PS_MotionVectors(PixelInput input) : SV_Target0
{
#if IS_MOTION_VECTORS_PASS
	// LOD masking
	ClipLODTransition(input);

#if MATERIAL_MASKED
	// Perform per pixel clipping if material requries it
	MaterialInput materialInput = GetMaterialInput(input);
	Material material = GetMaterialPS(materialInput);
	clip(material.Mask - MATERIAL_MASK_THRESHOLD);
#endif

	// Calculate this and previosu frame pixel locations in clip space
	float4 prevClipPos = mul(float4(input.PrevWorldPosition, 1), PrevViewProjectionMatrix);
	float4 curClipPos = mul(float4(input.WorldPosition, 1), ViewProjectionMatrix);
	float2 prevHPos = prevClipPos.xy / prevClipPos.w;
	float2 curHPos = curClipPos.xy / curClipPos.w;

	// Revert temporal jitter offset
	prevHPos -= TemporalAAJitter.zw;
	curHPos -= TemporalAAJitter.xy;

	// Clip Space -> UV Space
	float2 vPosPrev = prevHPos.xy * 0.5f + 0.5f;
	float2 vPosCur = curHPos.xy * 0.5f + 0.5f;
	vPosPrev.y = 1.0 - vPosPrev.y;
	vPosCur.y = 1.0 - vPosCur.y;

	// Calculate per-pixel motion vector
	return float4(vPosCur - vPosPrev, 0, 1);
#else
	return float4(0, 0, 0, 1);
#endif
}
