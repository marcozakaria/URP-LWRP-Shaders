Shader "Custom/URP_Grass"
{
    Properties
    {
        [MainTexture] _BaseMap("Texture", 2D) = "white" {}
        _Hiegth("Height", float) = 1.0
        _Base("Base", float) = 1.0

        _Tint("Tint", Color) = (0.5,0.5,0.5,1.0)
        _Darker("Darker Color", Color) = (0.5,0.5,0.5,1)
        _LightPower("Light Power", float) = 0.05
        _TPower("Transolancy Power", float) = 0.02
        _AlphaCutoff("Alpha Cutoff",Float) = 0.1
        _ShadowPower("Shadow Power", Float) = 0.35
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
             Name "Geometry Pass"
             Tags { "LightMode" = "UniversalForward" }         

             ZWrite On
             Cull Off

             HLSLPROGRAM

             #pragma prefer_hlslcc gles
             #pragma exclude_renderers d3d11_9x
             #pragma target 4.0

             #pragma shader_feature _ALPHATEST_ON
             #pragma shader_feature _ALPHAPREMULTIPLY_ON
             #pragma shader_feature _EMISSION
             #pragma shader_feature _METALLICSPECGLOSSMAP
             #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
             #pragma shader_feature _OCCLUSIONMAP

             #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
             #pragma shader_feature _GLOSSYREFLECTIONS_OFF
             #pragma shader_feature _SPECULAR_SETUP
             #pragma shader_feature _RECEIVE_SHADOWS_ON

             // Unity defined keywords
             #pragma multi_compile _ DIRLIGHTMAP_COMBINED
             #pragma multi_compile _ LIGHTMAP_ON
             #pragma multi_compile_fog

             // GPU Instancing
             #pragma multi_compile_instancing
          
             #pragma require geometry 

             #pragma geometry LitPassGeom
             #pragma vertex LitPassVertex
             #pragma fragment LitPassFragment

             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
             #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

             #include "GrassPass.hlsl"

             ENDHLSL

        }
    }
}
