Shader "Unlit/Water Displacment unlit lwrp"
{
    Properties 
	{
		_BaseMap("Texture", 2D) = "white" {}
        _BaseColor("Color", Color) = (1, 1, 1, 1)
        _Cutoff("AlphaCutout", Range(0.0, 1.0)) = 0.5

		/*_Steepness("Steepness", Range(0, 1)) = 0.5
        _WavelengthWater("Wavelength", Float) = 10
        _Direction("Direction (2D)", Vector) = (1,1,0.5,50)*/

        // using X and Y for the direction, Z for steepness, and W for the wavelength
        _Timespeed("Time Speed",Range(0.0, 1.0)) = 0.5
        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,1,0.25,60)
        _WaveB ("Wave B (dir, steepness, wavelength)", Vector) = (1,0.6,0.25,31)
        //_WaveC ("Wave C (dir, steepness, wavelength)", Vector) = (1,1.3,0.25,18)
	}
	
	SubShader 
	{      		
		Pass 
		{
            Tags { "RenderType"="Transparent" 
                   "Queue"="Transparent"
                   "IgnoreProjector" = "True" 
                   "RenderPipeline" = "LightweightPipeline" }

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            //ColorMask 0

			HLSLPROGRAM
			
			// Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
			
            // for fog
            #pragma multi_compile_fog
            // Gpu instantiating
			#pragma multi_compile_instancing
			#pragma instancing_options assumeuniformscaling

           // #pragma shader_feature _ALPHATEST_ON
           // #pragma shader_feature _ALPHAPREMULTIPLY_ON
			
			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment
			
			//#include "Unlit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //float _WavelengthWater, _Steepness;
           // float2 _Direction;
            float _Timespeed;
            float4 _WaveA,_WaveB;//,_WaveC;

			struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv        : TEXCOORD0;
                float fogCoord  : TEXCOORD1;
                float4 vertex : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };  

            float3 GerstnerWave (float4 wave, float3 p)//, inout float3 tangent, inout float3 binormal) 
            {
		        float steepness = wave.z;
		        float wavelength = wave.w;
		        float k = 2 * 3.1415926 / wavelength;
			    float c = sqrt(9.8 / k);
			    float2 d = normalize(wave.xy);
			    float f = k * (dot(d, p.xz) - c * _Time.y * _Timespeed);
			    float a = steepness / k;

			    /*tangent += float3(
				    -d.x * d.x * (steepness * sin(f)),
				    d.x * (steepness * cos(f)),
				    -d.x * d.y * (steepness * sin(f)));

			    binormal += float3(
				    -d.x * d.y * (steepness * sin(f)),
				    d.y * (steepness * cos(f)),
				    -d.y * d.y * (steepness * sin(f)));*/

			    return float3(d.x * (a * cos(f)), a * sin(f),d.y * (a * cos(f)));
		    }

			Varyings UnlitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                //UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 gridPoint  = input.positionOS.xyz;
                //float3 tangent = 0;
			   // float3 binormal =0;
			    float3 p = gridPoint;

			    p += GerstnerWave(_WaveA, gridPoint);//, tangent, binormal);
                p += GerstnerWave(_WaveB, gridPoint);//, tangent, binormal);
                //p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
			    //float3 normal = normalize(cross(binormal, tangent))

                VertexPositionInputs vertexInput = GetVertexPositionInputs(p);
                output.vertex = vertexInput.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
                
                //output.normal = normal;
                
                return output;
            }

            half4 UnlitPassFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                //UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half2 uv = input.uv;
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                half3 color = texColor.rgb * _BaseColor.rgb;
                half alpha = texColor.a * _BaseColor.a;
                AlphaDiscard(alpha, _Cutoff);

                color *= alpha;

                color = MixFog(color, input.fogCoord);

                return half4(color, alpha);
            }
			
			ENDHLSL
		}
	}
}
