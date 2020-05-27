Shader "Custom/VerticalFog"
{
	Properties 
	{
		[Header(Object Colors)]
	    _TopColor ("Top Y Color", Color) = (.5,.5,.5,1.0)
		_FrontColor ("Front Z Color", Color) = (.5,.5,.5,1.0)
		_LeftColor ("Left X Color", Color) = (.5,.5,.5,1.0)
		[Header(Fog Colors)]
		_FogColor ("Fog Color Middle", Color) = (.5,.5,.5,1.0)
		_MidleColorEnd ("Fog Color End", Color) = (.5,.5,.5,1.0)
		[Header(Fog Settings)]
		_AlphaPoint("Siperate top-fog point", float) = 1.0
		_Range("Fog Range Size", float) = 1.0
		_FO("Fog Opacity Lerp", Range(0.0,3.0)) = 1.0
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque"}

		Pass
		{
			LOD 200
            Cull Off

			CGPROGRAM

			#pragma vertex vert 
            #pragma fragment frag
			
			struct VertexInput 
			{
		       half4 vertex : POSITION;
		       half3 normal : NORMAL;
	        };

	        struct VertexOutput 
			{
		      half4 pos : SV_POSITION;
		      half3 wp : TEXCOORD0; // world position
		      half4 color : COLOR;
	        };

	        half4 _FrontColor, _TopColor, _LeftColor;
			half4 _FogColor, _MidleColorEnd;

			half _AlphaPoint, _Range, _FO;

	        VertexOutput vert(VertexInput i) 
			{
		       VertexOutput o;
		       o.pos = UnityObjectToClipPos(i.vertex);
		       o.wp = mul(unity_ObjectToWorld, i.vertex);
				// normal direction
		       half3 normalDir = normalize(mul(half4(i.normal, 0), unity_ObjectToWorld).xyz); 

		       if (dot(normalDir, half3(0, 1, 0)) > 0.9) // if it is upper gorund to Y direction
			   {
				  o.color = _TopColor;
			   }
			   else
			   {	// set X-Direction colors
			       o.color = lerp(_FrontColor, _LeftColor, clamp(abs(dot(normalDir, half3(1, 0, 0))), 0, 1));
			   }

		       return o;
	        }
						
			half4 frag (VertexOutput i) : COLOR
			{
				half4 color;

				if(i.wp.y > _AlphaPoint)
				{
					color = i.color;
				}
				else
				{
				    color = lerp (_FogColor, _MidleColorEnd, clamp((-i.wp.y - _Range) * _FO, 0, 1));
				}

				return color;			
			}
			
			ENDCG
	    }

	}
	FallBack Off
}