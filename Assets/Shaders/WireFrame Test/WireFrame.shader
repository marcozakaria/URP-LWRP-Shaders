// resources
// https://github.com/UnityCommunity/UnityLibrary/blob/master/Assets/Shaders/2D/Effects/WireFrame.shader
// https://catlikecoding.com/unity/tutorials/advanced-rendering/flat-and-wireframe-shading/

shader "Custom/WireFrame"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1.0,1.0,1.0,1.0)
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Wire Frame)]
        _WireThickness ("Wire Thickness", Range(0, 800)) = 100
        [HDR]_WireColor("Wire Color", Color) = (1.0,0.0,0.0,1.0)
    }
    SubShader
    {
        Tags {  "RenderPipeline" = "UniversalPipeline"  
                "LightMode" = "UniversalForward"
                "PassFlags" = "OnlyDirectional"
                "Queue"="Transparent"
                "RenderType"="Transparent"}
        LOD 100

        Pass
        {
            Name "MainPass"
           // Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            // make fog work
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
               // float3 WorldSpaceNormal :NORMAL;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float fogCoord : TEXCOORD1;
               // float3 viewDir : TEXCOORD2;
               // float3 worldPos : TEXCOORD3;
              //  float3 worldNormal : NORMAL;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float fogCoord : TEXCOORD1;
                float4 dist : TEXCOORD2;
               // float3 viewDir : TEXCOORD3;
               // float3 worldPos : TEXCOORD4;
               // float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half4 _BaseColor, _WireColor;
            half _WireThickness;

            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.fogCoord = ComputeFogFactor(o.vertex.z);
               // o.viewDir =  GetWorldSpaceViewDir(v.vertex);
                //o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                //o.worldNormal = TransformObjectToWorldNormal(v.WorldSpaceNormal);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g i[3], inout TriangleStream<g2f> stream)
            {
                float2 p0 = i[0].vertex.xy / i[0].vertex.w;
                float2 p1 = i[1].vertex.xy / i[1].vertex.w;
                float2 p2 = i[2].vertex.xy / i[2].vertex.w;

                float2 edge0 = p2 - p1;
                float2 edge1 = p2 - p0;
                float2 edge2 = p1 - p0;

                float area = abs(edge1.x * edge2.y - edge1.y * edge2.x);
				float wireThickness = 800 - _WireThickness ;

                g2f o;
                o.uv = i[0].uv;
                o.fogCoord = i[0].fogCoord;
                o.vertex = i[0].vertex;
                o.dist.xyz = float3( (area / length(edge0)), 0.0, 0.0) * o.vertex.w * wireThickness;
				o.dist.w = 1.0 / o.vertex.w;
                stream.Append(o);

                o.uv = i[1].uv;
                o.fogCoord = i[1].fogCoord;
                o.vertex = i[1].vertex;
                o.dist.xyz = float3(0.0, (area / length(edge1)), 0.0) * o.vertex.w * wireThickness;
				o.dist.w = 1.0 / o.vertex.w;
                stream.Append(o);

                o.uv = i[2].uv;
                o.fogCoord = i[2].fogCoord;
                o.vertex = i[2].vertex;
                o.dist.xyz = float3(0.0, 0.0, (area / length(edge2))) * o.vertex.w * wireThickness;
				o.dist.w = 1.0 / o.vertex.w;
                stream.Append(o);
            }

            half4 frag (g2f i) : SV_Target
            {

                half4 col = tex2D(_MainTex, i.uv) * _BaseColor;

                float minDistanceToEdge = min(i.dist[0], min(i.dist[1], i.dist[2])) * i.dist[3];

                col = lerp(_WireColor, col, minDistanceToEdge);

                if(minDistanceToEdge > 0.9)
                {
                    col.a = _WireColor.a;
                }

                // apply fog
                col.rgb = MixFog(col, i.fogCoord);

                return col;
            }
            ENDHLSL
        }

        // Shadow caster pass to produce shadows from directional light
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
