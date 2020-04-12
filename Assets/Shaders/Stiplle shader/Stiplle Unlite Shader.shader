Shader "Custom/Stiplle Unlit Shader"
{
    Properties
    {
        [HDR]_BaseColor("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}      

        _Transparency("Transparency Power", Range(0.4,2)) = 1.0
        _CameraThresHod("Camera threshold",float)=1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // base pass with steppling
        Pass
        {
            cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;

               // UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _BaseColor;

            half _Transparency;
            float _CameraThresHod;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex); // vertex pos in the worlds
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            inline void MakeStippling(v2f i)
            {
                // threshold values foreach 4x4 block of pixels , random selected numbers
                const float4x4 thresholdMatrix =
                {
                    1, 9, 3, 11,
                    13, 5, 15, 7,
                    4, 12, 2, 10,
                    16, 8, 14, 6
                };
                
                // vwrtex distance from camera 
                float camDist = distance(i.worldPos,_WorldSpaceCameraPos);
                if(camDist < _CameraThresHod)
                {
                    // multiply screen pos by (Width , height) of screen to get pixel coordinates
                    float2 pixelPos = i.vertex.xy / i.vertex.w * _ScreenParams.xy;
                    // divide by 17 to get value in range (0,1)
                    float threshhold = thresholdMatrix[pixelPos.x % 4][pixelPos.y % 4] / 17;
                    //clip discrad current pixel if value is less than zero
                    clip(lerp(1.0,0.0,_CameraThresHod-camDist/ _Transparency) - threshhold);
                }
                
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //Stipple section
                
                MakeStippling(i);
                // end stipple 

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv)*_BaseColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
        // Gpu instantiation pass
        Pass
        {
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
