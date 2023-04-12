Shader "Test/ForwardRenderingSkin"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Range(0.0, 10.0)) = 1.0
        _AOMap ("AO Map", 2D) = "white" {}
        _AOScale ("AO Scale", Range(0.0, 30.0)) = 20.0
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
        
        [Space(20)]
        _Ramp ("Ramp Texture", 2D) = "white" {}
        
        [Space(20)]
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimMin ("Rim Min", Range(0.0, 10.0)) = 0.0
        _RimMax ("Rim Max", Range(0.0, 10.0)) = 1.0
        _RimSmooth ("Rim Smooth", Range(0.0, 10.0)) = 1.0
        
        [Space(20)]
        _Outline ("Outline", Range(0, 1)) = 0.001
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        
        Pass {
			NAME "OUTLINE"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Outline;
			fixed4 _OutlineColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			}; 
			
			struct v2f
			{
			    float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (a2v v)
			{
				v2f o;
				
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
				normal.z = -0.5;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			float4 frag(v2f i) : SV_Target
			{
				float3 tex = tex2D(_MainTex, i.uv);
				return float4(_OutlineColor.rgb, 1);         
			}
			
			ENDCG
		}

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
            sampler2D _Ramp;
            fixed4 _Specular;
            fixed _SpecularScale;
            float _RimMin;
            float _RimMax;
            float _RimSmooth;
            fixed4 _RimColor;

            v2f vert (a2f v)
            {
                v2f o;
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
                fixed half_lambert = dot(bump, light_direction) * 0.5 + 0.5;
                // fixed3 diffuse = _LightColor0.rgb * saturate(dot(bump, light_direction)) * half_lambert;
                fixed3 diffuse = _LightColor0.rgb * tex2D(_Ramp, float2(half_lambert, 0.0)).rgb;

                // 高光
                fixed3 half_diretion = normalize(light_direction + view_direction);
                fixed spec = dot(bump, half_diretion);
				fixed w = fwidth(spec) * 2.0;
				fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);

                // 边缘光
                half f =  1.0 - saturate(dot(view_direction, i.world_normal));
                half rim = smoothstep(_RimMin, _RimMax, f);
                rim = smoothstep(0, _RimSmooth, rim);
                half3 rim_color = rim * _RimColor.rgb *  _RimColor.a;
                diffuse += rim_color;
                
                // 遮罩
                fixed ao_mask = tex2D(_AOMap, i.uv).g * _AOScale;
                diffuse *= ao_mask;
                diffuse += 0.5;
                
                return fixed4((ambient + diffuse + specular) * tex, 1.0);
            }
            ENDCG
        }
    }
	
	FallBack "Diffuse"
}
