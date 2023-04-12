Shader "Test/ForwardRenderingHair"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AOMap ("AO Map", 2D) = "white" {}
        _AOScale ("AO Scale", Range(0.0, 30.0)) = 20.0
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Specular Size", Range(8.0, 256)) = 20
        
        [Space(20)]
        _Ramp ("Ramp Texture", 2D) = "white" {}
        
        [Space(20)]
        _Outline ("Outline", Range(0, 1)) = 0.001
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        
        exponent ("exponent", float) = 0.0
        scale ("scale", float) = 0.0
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
                fixed3 world_binormal : texcoord2;
                
                // SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AOMap;
            float _AOScale;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _Ramp;

            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv.xy, _MainTex);

                fixed3 world_normal = UnityObjectToWorldNormal(v.normal);
                fixed3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.world_normal = world_normal;
                o.world_binormal = cross(world_normal, world_tangent) * v.tangent.w;
                // TRANSFER_SHADOW(o)
                return o;
            }

            float exponent;
            float scale;
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 light_direction = normalize(UnityWorldSpaceLightDir(i.pos));
                fixed3 view_direction = normalize(UnityWorldSpaceViewDir(i.pos));
                
                // 漫反射
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed half_lambert = dot(i.world_normal, light_direction) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * tex2D(_Ramp, float2(half_lambert, 0.0)).rgb;

                // 高光
                // fixed3 half_diretion = normalize(light_direction + view_direction);
                // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.world_normal, half_diretion)), _Gloss);
             //    float3 H = normalize(light_direction + view_direction);
	            // float dotTH = dot(i.world_binormal, H);
	            // float sinTH = sqrt(1.0 - dotTH * dotTH);
             //    float dirAtten = smoothstep(-1.0, 0.0, dotTH);
	            // fixed3 specular = dirAtten * pow(sinTH, exponent)* scale;
                fixed3 specular = pow(max(dot(normalize(UnityWorldSpaceLightDir(i.world_normal)),normalize(i.world_normal) * 2 - 1), 0.0), _Gloss);

                // 遮罩
                fixed4 ao_mask = tex2D(_AOMap, i.uv) * _AOScale;
                specular *= ao_mask.r;
                
                // fixed shadow = SHADOW_ATTENUATION(i);
                // return fixed4((ambient + diffuse + specular) * tex, 1.0);
                return fixed4(specular, 1.0);
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
