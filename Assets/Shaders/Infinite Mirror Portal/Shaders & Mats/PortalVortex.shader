Shader "Portal/PortalVortex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _Intensty("Intensty", Range (0,1)) = 1
        _Speed("Speed", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+2"}
        ZTest Greater
        ZWrite Off
        Blend SrcAlpha One
        Cull Front
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            fixed _Intensty, _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 uvs = fixed2(i.uv.x , i.uv.y + (_Time.y * _Speed));
                fixed4 col = tex2D(_MainTex, uvs);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return fixed4(col.rgb * _Color.rgb, col.a * i.uv.y * _Intensty);
            }
            ENDCG
        }
    }
}
