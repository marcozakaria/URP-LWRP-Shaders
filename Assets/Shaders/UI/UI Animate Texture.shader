Shader "UI/AnimateTexture"
{
    Properties
    {
		[PerRendererData]_MainTex ("MainTex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _EffectTex ("EffectTex", 2D) = "white" {}
        _AnimateX ("AnimateX", Range(-10, 10)) = 0
        _AnimateY ("AnimateY", Range(-10, 10)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags {
			//"IgnoreProjector"="True"  //PROJECTOR IS DEPRECATED in LWRP
			"RenderType"="Transparent" 
			"Queue"="Transparent"
			"CanUseSpriteAtlas"="True"
            "PreviewType"="Plane"
		}
        LOD 100

        Pass
        {
			Blend One OneMinusSrcAlpha
            Cull Off
			ZWrite Off
			Lighting Off
			ZTest[unity_GUIZTestMode]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma target 2.0 // minumim supported version

            #include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _Color;
			uniform sampler2D _EffectTex;
			uniform float4 _EffectTex_ST;
            uniform float _AnimateX;
            uniform float _AnimateY;

           struct VertexInput 
		   {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput 
			{
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) 
			{
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }

			
			float rand(float x, float y)
			{
				// function changes from 2d to 1d to simulate random number
				// frac returns the decimal number to the right 
				return frac(sin(x*12.9898 + y*78.233)*43758.5453);
			}

            float4 frag(VertexOutput i, float facing : VFACE) : COLOR 
			{
                //float isFrontFace = ( facing >= 0 ? 1 : 0 );
                //float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                //float4 combinedTime = _Time; // _Time used to nimate things inside shaders 
                float2 animateUV = ((i.uv0 + (_Time.g * _AnimateX) * float2(1,0)) + (_Time.g * _AnimateY) * float2(0,1));
                float4 _EffectTex_var = tex2D(_EffectTex, TRANSFORM_TEX( animateUV , _EffectTex));
                float colorMain = (_MainTex_var.a * _Color.a * i.vertexColor.a); // A
                float3 finalColor = (saturate(((_MainTex_var.rgb * _Color.rgb * i.vertexColor.rgb) * _EffectTex_var.rgb)) * colorMain);
				half4 final = fixed4(finalColor, colorMain);
				#ifdef UNITY_UI_ALPHACLIP
				clip(final.a - 0.001);
				#endif
                return final;
            }
            ENDCG
        }
    }
}
