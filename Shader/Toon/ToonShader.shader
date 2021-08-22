Shader "Unlit/TestToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Outline ("轮廓线宽度", Range(0.0, 0.005)) = 0.001
		_OutlineColor ("轮廓线颜色", Color) = (0, 0, 0, 1)
        _RampTimes("光影分割次数",Range(0.3, 1.0)) = 0.3
        _Brightness("光照强度", Range(0.0, 1.0)) = 0.1
        _Strength("亮部亮度", Range(0.0, 1.0)) = 0.5
        _RampTex("渐进纹理", 2D) = "whith"
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            Name "Outline"
            Cull Front
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            float _Outline;
            fixed4 _OutlineColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f f;
                float4 pos = float4(UnityObjectToViewPos(v.vertex), 1.0);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                normal.z = -0.05;
                pos += float4(normalize(normal), 1) * _Outline;
                f.pos = mul(UNITY_MATRIX_P, pos);
                return f;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                return fixed4(_OutlineColor.rgb, 1.0);
            }
            
            ENDCG
        }
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Diffuse;
            float _Brightness;
            float _Strength;
            float _RampTimes;
            sampler2D _RampTex;
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                half3 world_normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float get_toon_color(float3 normal, float3 lightDir)
            {
                float toon = max(0.0, dot(normalize(normal), normalize(lightDir)));
                // return floor(toon / _RampTimes);
                
                float ramp_color = tex2D(_RampTex, half2(toon, toon));
                return toon * ramp_color;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);
                albedo *= get_toon_color(i.world_normal, _WorldSpaceLightPos0.xyz) * _Strength + _Brightness;
                return albedo;
            }
            ENDCG
        }
    }
}
