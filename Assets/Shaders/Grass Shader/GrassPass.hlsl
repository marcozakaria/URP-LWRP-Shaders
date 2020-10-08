// ref : https://gist.github.com/phi-lira/225cd7c5e8545be602dca4eb5ed111ba

// For vertex data
struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 uv           : TEXCOORD0;
    float2 uvLM         : TEXCOORD1;    // uv light map
    float4 color        : COLOR;        // vertex color 

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    half3 normalOS                  : NORMAL;
    float2 uv                       : TEXCOORD0;
    float2 uvLM                     : TEXCOORD1;
    float4 positionWSAndFogFactor   : TEXCOORD2; // xyz: positionWS, w: vertex fog factor
    half3  normalWS                 : TEXCOORD3;
    half3 tangentWS                 : TEXCOORD4;
    float4 positionOS                : TEXCOORD5;

    float4 color                    : COLOR;  

#if _NORMALMAP

    half3 bitangentWS               : TEXCOORD6;
#endif

#ifdef _MAIN_LIGHT_SHADOWS
    float4 shadowCoord              : TEXCOORD7; // compute shadow coord per-vertex for the main light
#endif
    float4 positionCS               : SV_POSITION;  // position screen space
};

float _Hiegth, _Base;
float4 _Tint;

Varyings LitPassVertex(Attributes input)
{
    Varyings output;
    output.color = input.color;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
    output.positionCS = vertexInput.positionCS;
    output.positionOS = input.positionOS;

    output.normalWS = vertexNormalInput.normalWS;
    output.tangentWS = vertexNormalInput.tangentWS;

    #if _NORMALMAP
        output.bitangentWS = vertexNormalInput.bitangentWS;
    #endif

    #ifdef _MAIN_LIGHT_SHADOWS
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    return output;
}

float3x3 RotY(float angle)
{
    return float3x3
    (
        cos(angle), 0, sin(angle),
        0, 1, 0,
        -sin(angle), 0, cos(angle)
    );
}

float Hash21( float2 p) // random number
{
    p = frac( p * float2(123.34, 456.21));
    p += dot(p, p+45.32);
    return frac(p.x * p.y);
}

[maxvertexcount(6)]
void LitPassGeom(triangle Varyings input[3], inout TriangleStream<Varyings> outStream)
{
    float3 basePos = (input[0].positionWSAndFogFactor.xyz + input[1].positionWSAndFogFactor.xyz + input[2].positionWSAndFogFactor.xyz) / 3; // midlle pos of triangle

    Varyings o = input[0];
    float3 rotatedTangent = normalize(mul(o.tangentWS , RotY(Hash21(o.positionWSAndFogFactor.xy) * 90)));

    float3 oPos = (basePos - rotatedTangent *_Base );      // left
    o.positionCS = TransformWorldToHClip(oPos);

    Varyings o2 = input[1];
    float3 oPos2 = (basePos + rotatedTangent *_Base );        // right
    o2.positionCS = TransformWorldToHClip(oPos2);

    Varyings o3 = input[2];
    float3 oPos3 = (basePos + rotatedTangent *_Base + o3.normalWS * _Hiegth);
    o3.positionCS = TransformWorldToHClip(oPos3);   // top right

     Varyings o4 = input[2];
    float3 oPos4 = (basePos - rotatedTangent *_Base  + o4.normalWS * _Hiegth);  //top left
    o4.positionCS = TransformWorldToHClip(oPos4);

    float3 newNormal = mul(rotatedTangent , RotY(PI / 2));

    o4.uv = TRANSFORM_TEX(float2(0 ,1) , _BaseMap);
    o3.uv = TRANSFORM_TEX(float2(1 ,1) , _BaseMap);
    o2.uv = TRANSFORM_TEX(float2(1 ,0) , _BaseMap);
    o.uv = TRANSFORM_TEX(float2(0 ,0) , _BaseMap);

    o.normalWS = newNormal;
    o2.normalWS = newNormal;
    o3.normalWS = newNormal;
    o4.normalWS = newNormal;

    outStream.Append(o4);
    outStream.Append(o3);
    outStream.Append(o);

    outStream.RestartStrip();   // mark new triangle

    outStream.Append(o3);
    outStream.Append(o2);
    outStream.Append(o);

    outStream.RestartStrip();
}

half4 LitPassFragment(Varyings input, bool vf : SV_IsFrontFace) : SV_Target
{
    return(1,1,1,1);
}