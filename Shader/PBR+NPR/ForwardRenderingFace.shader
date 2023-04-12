Shader "Test/ForwardRenderingFace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AOMap ("AO Map", 2D) = "white" {}
        _AOScale ("AO Scale", Range(0.0, 30.0)) = 20.0
        
        [Space(20)]
        _Ramp ("Ramp Texture", 2D) = "white" {}
        
        [Space(20)]
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Specular Size", Range(0.0, 20)) = 0.1
        
        [Space(20)]
        _Outline ("Outline", Range(0, 1)) = 0.001
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        UsePass "Test/ForwardRenderingSkin/OUTLINE"

        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }
            
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
                float3 world_normal : texcoord1;
                // float3 light_diretion : texcoord4;
                // float3 view_diretion : texcoord5;
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AOMap;
            float _AOScale;
            sampler2D _Ramp;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 漫反射
                fixed3 tex = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 light_direction = normalize(UnityWorldSpaceLightDir(i.pos));
                fixed3 diffuse = _LightColor0.rgb;

                // 高光
                fixed3 view_direction = normalize(UnityWorldSpaceViewDir(i.pos));
                fixed3 half_diretion = normalize(light_direction + view_direction);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.world_normal, half_diretion)), _Gloss);

                // 自阴影
                fixed3 ao_mask = tex2D(_AOMap, i.uv);
                diffuse *= ao_mask.g * _AOScale;

                // sdf 阴影
                float3 forward = unity_ObjectToWorld._12_22_32;
                float3 right = unity_ObjectToWorld._13_23_33;
                float forward_l = dot(normalize(forward.xz), normalize(light_direction.xz));
                float right_l = dot(normalize(right.xz), normalize(light_direction.xz));
                right_l = -(acos(right_l) / 3.14159265 - 0.5) * 2;
                float3 light_dir_h = normalize(float3(light_direction.x, 0, light_direction.z));
                float sdf_direction = sign(dot(light_dir_h, -right_l)); // sdf 方向需要根据光线方向调整
                ao_mask = tex2D(_AOMap, i.uv * float2(sdf_direction, 1));
                float light_attenuation = (forward_l > 0) * min(ao_mask.b > right_l, ao_mask.b > -right_l) * 0.5 + 0.75;
                specular *= ao_mask.r;
                
                return fixed4((ambient + diffuse + specular) * tex * light_attenuation, 1.0);
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
