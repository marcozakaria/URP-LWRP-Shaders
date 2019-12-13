Shader "UI/UI Outline Shader"
{
    Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0

		// outline variables
		_Outline("Outline Thickness", Float) = 0
		[HDR] _OutlineColor("Outline Color", Color) = (1,1,1,1)
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
				"CanUseSpriteAtlas" = "True"
			}

			Cull Off
			Lighting Off
			ZWrite Off
			Blend One OneMinusSrcAlpha

			Pass
			{
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile _ PIXELSNAP_ON
				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float4 color    : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord  : TEXCOORD0;
				};

				fixed4 _Color;
				// outline variables
				float _Outline;
				fixed4 _OutlineColor;

				v2f vert(appdata_t IN) // default vert
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;
					#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
					#endif

					return OUT;
				}

				sampler2D _MainTex;
				sampler2D _AlphaTex;
				float4 _MainTex_TexelSize; // defalut unity property , it is the size of a texel of the texture  Vector4(1 / width, 1 / height, width, height) 
				float _AlphaSplitEnabled;

				fixed4 SampleSpriteTexture(float2 uv)
				{
					fixed4 color = tex2D(_MainTex, uv);

	#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
					if (_AlphaSplitEnabled)
						color.a = tex2D(_AlphaTex, uv).r;
	#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

					return color;
				}

				fixed4 frag(v2f IN) : SV_Target
				{
					fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
					
					// If these pixel is contains alpha work on it
					if (c.a != 0)
					{
						// Get the neighbouring four pixels.
						fixed4 pixelUp = tex2D(_MainTex, IN.texcoord + fixed2(0, _MainTex_TexelSize.y * _Outline)); //height
						fixed4 pixelDown = tex2D(_MainTex, IN.texcoord - fixed2(0, _MainTex_TexelSize.y* _Outline)); // height
						fixed4 pixelRight = tex2D(_MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x* _Outline, 0)); //width
						fixed4 pixelLeft = tex2D(_MainTex, IN.texcoord - fixed2(_MainTex_TexelSize.x* _Outline, 0)); //width

						// If one of the neighbouring pixels is transparent clear, draw out line on it
						if (pixelUp.a * pixelDown.a * pixelRight.a * pixelLeft.a == 0) 
						{
							c.rgba = _OutlineColor;
						}
					}
					
					c.rgb *= c.a;
					return c;
				}
			ENDCG
			}
		}
}
