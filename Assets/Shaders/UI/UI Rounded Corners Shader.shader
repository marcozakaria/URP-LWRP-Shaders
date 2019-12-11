Shader "UI/UI Rounded Corners Shader"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0

		// corner variables
		[space(10)]
		_Radius("Radius Circle", Range(0,0.5)) = 0.5
		_Width("Width percentage", Range(0,1)) = 1
		_Height("Height percentage", Range(0,1)) = 1
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

				// my corner variables
				float _Radius;
				float _Width;
				float _Height;

				v2f vert(appdata_t IN)
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

				// function from shader graph nodes docmentation
				float Unity_RoundedRectangle_float(float2 UV, float Width, float Height, float Radius)
				{
					Radius = max(min(min(abs(Radius * 2), abs(Width)), abs(Height)), 1e-5);
					float2 uv = abs(UV * 2 - 1) - float2(Width, Height) + Radius;
					float d = length(max(0, uv)) / Radius;
					return saturate((1 - d) / fwidth(d));
				}

				fixed4 frag(v2f IN) : SV_Target
				{
					fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
					
					// calclate round alpha 
					float alpha = Unity_RoundedRectangle_float(IN.texcoord,
						_Width, _Height, _Radius);
					c.a = min(c.a, alpha); // take minimum alpha between image and round function

					c.rgb *= c.a;
					return c;
				}

			ENDCG
			}
		}
}
