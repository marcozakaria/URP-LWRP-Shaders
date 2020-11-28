// ref : https://gist.github.com/phi-lira/225cd7c5e8545be602dca4eb5ed111ba

// For vertex data
struct Attributes
{
    half4 positionOS   : POSITION;
    half3 normalOS     : NORMAL;
    half4 tangentOS    : TANGENT;
    half2 uv           : TEXCOORD0;
    half2 uvLM         : TEXCOORD1;    // uv light map
    half4 color        : COLOR;        // vertex color 

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    half3 normalOS                  : NORMAL;
    half2 uv                       : TEXCOORD0;
    half2 uvLM                     : TEXCOORD1;
    half4 positionWSAndFogFactor   : TEXCOORD2; // xyz: positionWS, w: vertex fog factor
    half3  normalWS                 : TEXCOORD3;
    half3 tangentWS                 : TEXCOORD4;
    half4 positionOS                : TEXCOORD5;

    half4 color                    : COLOR;  

#if _NORMALMAP

    half3 bitangentWS               : TEXCOORD6;
#endif

#ifdef _MAIN_LIGHT_SHADOWS
    half4 shadowCoord              : TEXCOORD7; // compute shadow coord per-vertex for the main light
#endif
    half4 positionCS               : SV_POSITION;  // position screen space
};

half _Hiegth, _Base;
half4 _Tint, _Darker;
half _LightPower, _TPower, _AlphaCutoff, _ShadowPower;

Varyings LitPassVertex(Attributes input)
{
    Varyings output;
    output.color = input.color;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;

    output.positionWSAndFogFactor = half4(vertexInput.positionWS, fogFactor);
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

half3x3 RotY(half angle)
{
    return half3x3
    (
        cos(angle), 0, sin(angle),
        0, 1, 0,
        -sin(angle), 0, cos(angle)
    );
}

half Hash21( half2 p) // random number
{
    p = frac( p * half2(123.34, 456.21));
    p += dot(p, p+45.32);
    return frac(p.x * p.y);
}

[maxvertexcount(6)]
void LitPassGeom(triangle Varyings input[3], inout TriangleStream<Varyings> outStream)
{
    half3 basePos = (input[0].positionWSAndFogFactor.xyz + input[1].positionWSAndFogFactor.xyz + input[2].positionWSAndFogFactor.xyz) / 3; // midlle pos of triangle

    Varyings o = input[0];
    half3 rotatedTangent = normalize(mul(o.tangentWS , RotY(Hash21(o.positionWSAndFogFactor.xy) * 90)));

    half3 oPos = (basePos - rotatedTangent *_Base );      // left
    o.positionCS = TransformWorldToHClip(oPos);

    Varyings o2 = input[1];
    half3 oPos2 = (basePos + rotatedTangent *_Base );        // right
    o2.positionCS = TransformWorldToHClip(oPos2);

    Varyings o3 = input[2];
    half3 oPos3 = (basePos + rotatedTangent *_Base + o3.normalWS * _Hiegth);
    o3.positionCS = TransformWorldToHClip(oPos3);   // top right

     Varyings o4 = input[2];
    half3 oPos4 = (basePos - rotatedTangent *_Base  + o4.normalWS * _Hiegth);  //top left
    o4.positionCS = TransformWorldToHClip(oPos4);

    half3 newNormal = mul(rotatedTangent , RotY(PI / 2));

    o4.uv = TRANSFORM_TEX(half2(0 ,1) , _BaseMap);
    o3.uv = TRANSFORM_TEX(half2(1 ,1) , _BaseMap);
    o2.uv = TRANSFORM_TEX(half2(1 ,0) , _BaseMap);
    o.uv = TRANSFORM_TEX(half2(0 ,0) , _BaseMap);

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

half4 TransforWorldToShadowCoords(half3  positionWS)
{
    half cascadeIndex = ComputeCascadeIndex(positionWS);
    return mul(_MainLightWorldToShadow[cascadeIndex], half4(positionWS, 1.0));
}

half4 LitPassFragment(Varyings input, bool vf : SV_IsFrontFace) : SV_Target
{   
    half3 normalWS = input.normalWS;
    normalWS = normalize(normalWS);
    if(vf == false)
    {
        normalWS = -normalWS;
    }
    half3 positionWS = input.positionWSAndFogFactor.xyz;

    half3 color = (0,0,0);
    Light mainLight;

    half4 shadowCoord = TransforWorldToShadowCoords(positionWS);
    mainLight = GetMainLight(shadowCoord);

    half3 normalLight = LightingLambert(mainLight.color, mainLight.direction, normalWS) * _LightPower;
    half3 inverseNormalLight = LightingLambert(mainLight.color, mainLight.direction, -normalWS) * _TPower;

    color = _Tint + normalLight + inverseNormalLight;
    color = lerp(color, _Darker, 1 - input.uv.y);
    color = lerp(_Darker, color, clamp(mainLight.shadowAttenuation + _ShadowPower, 0, 1));

    half fogFactor = input.positionWSAndFogFactor.w;
    color = MixFog(color, fogFactor);
    half a = _BaseMap.Sample(sampler_BaseMap, input.uv).a;

    clip(a - _AlphaCutoff);

    return half4(color, 1);
}