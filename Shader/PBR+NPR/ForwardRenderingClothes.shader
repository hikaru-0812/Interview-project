Shader "Test/ForwardRenderingClothes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Space(20)]
        _BumpTex ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Range(0.0, 10.0)) = 1.0
        
        [Space(20)]
        _AOMap ("AO Map", 2D) = "white" {}
        _AOScale ("AO Scale", Range(0.0, 30.0)) = 20.0
        
        [Space(20)]
        _Specular ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Specular Size", Range(8.0, 256)) = 20
        
        [Space(20)]
        _RampMap ("Ramp Map", 2D) = "white" {}
        _ShadowColor ("Shadow Color", Color) = (0.7, 0.7, 0.8)
	    _ShadowRange ("Shadow Range", Range(0, 1)) = 0.5
        _ShadowSmooth("Shadow Smooth", Range(0, 1)) = 0.2
        _OutlineWidth ("Outline Width", Range(0.01, 2)) = 0.24
        _OutLineColor ("OutLine Color", Color) = (0.0,0.0,0.0,1)
        
        [Space(20)]
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimMin ("Rim Min", Range(0.0, 10.0)) = 0.0
        _RimMax ("Rim Max", Range(0.0, 10.0)) = 1.0
        _RimSmooth ("Rim Smooth", Range(0.0, 10.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            Cull Back
            
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
                float2 uv : TEXCOORD0;
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
                float3 world_normal : texcoord4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float _BumpScale;
            sampler2D _AOMap;
            float _AOScale;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _RampMap;
            half3 _ShadowColor;
            half _ShadowRange;
            float _RimMin;
            float _RimMax;
            float _RimSmooth;
            fixed4 _RimColor;

            v2f vert (a2f v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex);
                
                float3 world_position = mul(unity_ObjectToWorld, v.vertex);
                fixed3 world_normal = UnityObjectToWorldNormal(v.normal);
                fixed3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 world_binormal = cross(world_normal, world_tangent) * v.tangent.w;
                o.T_to_W_0 = float4(world_tangent.x, world_binormal.x, world_normal.x, world_position.x);
                o.T_to_W_1 = float4(world_tangent.y, world_binormal.y, world_normal.y, world_position.y);
                o.T_to_W_2 = float4(world_tangent.z, world_binormal.z, world_normal.z, world_position.z);

                o.world_normal = world_normal;
                
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
                fixed half_lambert = dot(normalize(i.world_normal), light_direction) * 0.5 + 0.5;
                // fixed3 diffuse = _LightColor0.rgb * saturate(dot(bump, light_direction)) * half_lambert;
                half3 ramp =  tex2D(_RampMap, float2(saturate(half_lambert - _ShadowRange), 0.5));
                half3 diffuse = lerp(_ShadowColor, tex, ramp);

                // 高光
                fixed3 half_diretion = normalize(light_direction + view_direction);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, half_diretion)), _Gloss);

                // 边缘光
                half f =  1.0 - saturate(dot(view_direction, i.world_normal));
                half rim = smoothstep(_RimMin, _RimMax, f);
                rim = smoothstep(0, _RimSmooth, rim);
                half3 rim_color = rim * _RimColor.rgb *  _RimColor.a;
                diffuse += rim_color;
                
                // 遮罩
                fixed ao_mask = tex2D(_AOMap, i.uv).g * _AOScale;
                diffuse *= ao_mask;
                
                return fixed4((ambient + diffuse + specular) * tex, 1.0);
            }
            ENDCG
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed3 frag() : COLOR
            {
                SHADOW_CASTER_FRAGMENT()
            }
            
            ENDCG
        }
    }
}
