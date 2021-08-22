Shader "Unlit/ToonShaderEdgeLight"
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
        _RampTex("渐进纹理", 2D) = "whith"{}
        _RimColor("边缘光颜色", Color) = (1,1,1,1)
        _RimRange("边缘光范围", Range(0.0, 0.5)) = 0.1
        _XRayColor("透视颜色", Color) = (1.0, 1.0, 1.0, 1.0)
        _XRayRange("可视范围", Range(0.0001, 3.0)) = 1
    }
    SubShader
    {
        Tags 
        {"Queue"="Geometry" "RenderType"="Opaque"}

        Pass
        {
            Blend SrcAlpha One
            ZWrite off
            ZTest Greater
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _XRayColor;
            float _XRayRange;
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 world_normal : TEXCOORD1;
                float3 world_pos: TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f f;
                
                f.vertex = UnityObjectToClipPos(v.vertex);
                f.world_normal = UnityObjectToWorldNormal(v.normal);
                f.world_pos = mul(unity_ObjectToWorld, v.vertex);
                
                return f;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                float3 normal = normalize(f.world_normal);
                float3 view_dir = normalize(UnityWorldSpaceViewDir(f.world_pos));
                float rim = 1 - dot(normal, view_dir);
                
                return _XRayColor * pow(rim, 1 / _XRayRange);
            }
            
            ENDCG
        }
        
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
            fixed4 _RimColor;
            float _RimRange;
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                half3 world_normal : TEXCOORD1;
                float3 world_pos: TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float get_toon_color(float3 normal, float3 light_dir, float3 word_pos)
            {
                float toon = max(0.0, dot(normalize(normal), normalize(light_dir)));
                float toon_color = floor(toon / _RampTimes);
                //return toon_color;

                float ramp_color = tex2D(_RampTex, half2(toon, toon));
                return toon * ramp_color;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);
                albedo *= get_toon_color(i.world_normal, _WorldSpaceLightPos0.xyz, i.world_pos) * _Strength + _Brightness;

                // 边缘光
                fixed3 view_dir = normalize(UnityWorldSpaceViewDir(i.world_pos));
                float rim = 1.0 - dot(i.world_normal, view_dir);
                fixed4 rim_color = _RimColor * pow(rim, 1 / _RimRange);
                albedo += rim_color;
                
                return albedo;
            }
            ENDCG
        }
    }
}
