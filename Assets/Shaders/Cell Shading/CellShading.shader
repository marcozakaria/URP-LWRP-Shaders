// resources : 
// https://roystan.net/articles/toon-shader.html
// https://torchinsky.me/cel-shading/
// https://teofilobd.github.io/unity/shaders/urp/graphics/2020/05/18/From-Built-in-to-URP.html#conclusion-

Shader "Toon/CellShading"
{
    Properties
    {
        [Header(Main)]
        _TexColor("Texture Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength",Range(0,1)) = 0.5

        //_OutlineWidth("Outline Width",Range(0,0.1)) = 0.01
        //_OUTLINE_COLOR("OutLineColor",Color) = (0,0,0,1.0)

        [Header(Reflection)]
        [HDR]
        _SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
        _Glossiness("Glossiness", Float) = 32

        [Header(Rim)]
        [HDR]
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.716
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags {  "RenderPipeline" = "UniversalPipeline"  
                "LightMode" = "UniversalForward"
                "PassFlags" = "OnlyDirectional" }
        LOD 100

        Pass
        {
            Name "MainPass"
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // to make object recive shadows
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            //#include "Packages/com.unity.shadergraph/ShaderLibrary/ShaderVariablesFunctions.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 WorldSpaceNormal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
                float4 shadowCoord : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _ShadowStrength;
            half4 _TexColor;

            half _Glossiness;
            half4 _SpecularColor;

            half _RimAmount, _RimThreshold;
            half4 _RimColor;

            float3 GetWorldSpaceViewDir(float3 positionWS) 
            {
                if (unity_OrthoParams.w == 0) {
                    // Perspective
                    return _WorldSpaceCameraPos - positionWS;
                } else {
                    // Orthographic
                    float4x4 viewMat = GetWorldToViewMatrix();
                    return -viewMat[1].xyz;
                }
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = TransformObjectToWorldNormal(v.WorldSpaceNormal);
                o.viewDir =  GetWorldSpaceViewDir(v.vertex);
                // transform vertex first to worl space then get shadows
                o.shadowCoord = TransformWorldToShadowCoord(mul(unity_ObjectToWorld, v.vertex)); // GetShadowCoord ,TransformWorldToShadowCoord
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Normalizing vector so it's length always 1.
                float3 normal = normalize(i.worldNormal);
                // Calculating specualr reflection.
                float3 viewDir = normalize(i.viewDir);

                Light mainLight = GetMainLight(i.shadowCoord);

                // Calculating Dot Product for surface normal and light direction.
                float NdotL = dot(_MainLightPosition, normal);
                // Calculating light intensity on the surface.
                // If surface faced towards the light source (NdotL > 0), 
                // then it is completely lit.
                // Otherwise we use Shadow Strength for shading
                float lightIntensity = NdotL > 0 ? 1 : _ShadowStrength;
                float4 light = lightIntensity * _MainLightColor;
                light *=  (mainLight.distanceAttenuation * mainLight.shadowAttenuation);

                
                // Calculating half vector.
                float3 halfVector = normalize(_MainLightPosition + viewDir);
                // Clamping NdotH value in [0, 1] range.
                float NdotH =  dot(normal, halfVector);
                // Calculating fixed-size specualr reflection.
                float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
                // Creating specular mask.
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _SpecularColor;

                // Rim Coloring
                float4 rimDot = 1 - dot(viewDir, normal);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                float4 rim = rimIntensity * _RimColor;               

                // Sample the texture
                half4 col = tex2D(_MainTex, i.uv) * _TexColor;

                // Apply shading
                col *= (light  + rim + specular);

                return col;
            }
            ENDHLSL
        }

        // Shadow caster pass
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
