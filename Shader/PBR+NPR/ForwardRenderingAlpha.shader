Shader "Test/ForwardRenderingAlpha"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Range(0.0, 10.0)) = 1.0
        _AOMap ("AO Map", 2D) = "white" {}
        _AOScale ("AO Scale", Range(0.0, 30.0)) = 20.0
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Specular Size", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" "IngoreProjector" = "Ture" "RenderType" = "TransparentCutout" }
        LOD 100
        
        Cull Off

        Pass
        {
            ZWrite On
            ColorMask 0
        }
        
        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct a2f
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : tangent;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 T_to_W_0 : texcoord1;
                float4 T_to_W_1 : texcoord2;
                float4 T_to_W_2 : texcoord3;
                // SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float _BumpScale;
            sampler2D _AOMap;
            float _AOScale;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv.xy, _MainTex);
                
                float3 world_position = mul(unity_ObjectToWorld, v.vertex);
                fixed3 world_normal = UnityObjectToWorldNormal(v.normal);
                fixed3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 world_binormal = cross(world_normal, world_tangent) * v.tangent.w;
                o.T_to_W_0 = float4(world_tangent.x, world_binormal.x, world_normal.x, world_position.x);
                o.T_to_W_1 = float4(world_tangent.y, world_binormal.y, world_normal.y, world_position.y);
                o.T_to_W_2 = float4(world_tangent.z, world_binormal.z, world_normal.z, world_position.z);
                
                // TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 法线
                fixed3 bump = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
                float3 world_position = float3(i.T_to_W_0.w, i.T_to_W_1.w, i.T_to_W_2.w);
                fixed3 light_direction = normalize(UnityWorldSpaceLightDir(world_position));
                fixed3 view_direction = normalize(UnityWorldSpaceViewDir(world_position));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
                bump = normalize(half3(dot(i.T_to_W_0.xyz, bump), dot(i.T_to_W_1.xyz, bump), dot(i.T_to_W_2.xyz, bump)));
                
                // 漫反射
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed half_lambert = dot(bump, light_direction) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(bump, light_direction)) * half_lambert;

                // 高光
                // fixed3 reflect_diretion = normalize(reflect(-world_light_diretion, world_normal));
                fixed3 half_diretion = normalize(light_direction + view_direction);
                // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(half_diretion, view_diretion)), _Gloss);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, half_diretion)), _Gloss);

                // 遮罩
                fixed ao_mask = tex2D(_AOMap, i.uv).g * _AOScale;
                diffuse *= ao_mask;
                
                // fixed shadow = SHADOW_ATTENUATION(i);
                return fixed4((ambient + diffuse + specular) * tex, tex.a);
            }
            ENDCG
        }
    }
    Fallback "Test/ForwardRenderingClothes"
}
