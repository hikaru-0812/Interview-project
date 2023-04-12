Shader "Test/PBR&NPRShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MetallicTex("Metallic(R),Smoothness(A)",2D) = "white"{}
        _Metallic ("Metallic", Range(0, 1)) = 1.0
        _Glossiness("Smoothness",Range(0,1)) = 1.0
        [Normal]_Normal("NormalMap",2D) = "bump"{}
        _OcclussionTex("Occlusion",2D) = "white"{}
        _AO("AO",Range(0,1)) = 1.0
        _Emission("Emission",Color) = (0,0,0,1)
        
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
        Tags { "Queue" = "AlphaTest" "IngoreProjector" = "Ture" "RenderType" = "TransparentCutout" }
        
        Cull Off
        
        UsePass "Test/ForwardRenderingSkin/OUTLINE"
        
        Pass
        {
            ZWrite On
            ColorMask 0
        }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MetallicTex;
            fixed _Metallic;
            fixed _Glossiness;
            sampler2D _OcclussionTex;
            fixed _AO;
            half3 _Emission;
            sampler2D _Normal;
            sampler2D _Ramp;
            float _RimMin;
            float _RimMax;
            float _RimSmooth;
            fixed4 _RimColor;

            struct v2f
            {
                float4 pos:SV_POSITION;//裁剪空间位置输出
                float2 uv: TEXCOORD0; // 贴图UV
                float3 worldPos: TEXCOORD1;//世界坐标
                float3 tSpace0:TEXCOORD2;//TNB矩阵0
                float3 tSpace1:TEXCOORD3;//TNB矩阵1
                float3 tSpace2:TEXCOORD4;//TNB矩阵2
                //TNB矩阵同时也传递了世界空间法线及世界空间切线
                
                UNITY_FOG_COORDS(5)//雾效坐标 fogCoord
                UNITY_SHADOW_COORDS(6)//阴影坐标 _ShadowCoord

                half3 sh: TEXCOORD7;//球谐参数
            };

            v2f vert (appdata_full v)
            {
                v2f o;//定义返回v2f 结构体o
                UNITY_INITIALIZE_OUTPUT(v2f, o);//将o初始化。
                o.pos = UnityObjectToClipPos(v.vertex);//计算齐次裁剪空间下的坐标位置
                //这里的uv只定义了两个分量。TranformTex方法加入了贴图的TillingOffset值。
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;//世界空间坐标计算。
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);//世界空间法线计算
                half3 worldTangent = UnityObjectToWorldDir(v.tangent);//世界空间切线计算
                //利用切线和法线的叉积来获得副切线，tangent.w分量确定副切线方向正负，
                //unity_WorldTransformParams.w判定模型是否有变形翻转。
                half3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
            
                //组合TBN矩阵，用于后续的切线空间法线计算。
                o.tSpace0 = float3(worldTangent.x,worldBinormal.x,worldNormal.x);
                o.tSpace1 = float3(worldTangent.y,worldBinormal.y,worldNormal.y);
                o.tSpace2 = float3(worldTangent.z,worldBinormal.z,worldNormal.z);

                o.sh += Shade4PointLights(
                            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                            unity_LightColor[0].rgb, unity_LightColor[1].rgb, 
                            unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                            unity_4LightAtten0, o.worldPos, worldNormal);
                o.sh = ShadeSHPerVertex(worldNormal, o.sh);
            
                UNITY_TRANSFER_LIGHTING(o, v.texcoord1.xy); 
                // pass shadow and, possibly, light cookie coordinates to pixel shader
                //在appdata_full结构体里。v.texcoord1就是第二套UV，也就是光照贴图的UV。
                //计算并传递阴影坐标
                
                UNITY_TRANSFER_FOG(o, o.pos); // pass fog coordinates to pixel shader。计算传递雾效的坐标。
            
                return o;
            }

            fixed4 PBR(v2f i, half3 worldNormal, fixed3 lightDir, float3 worldViewDir)
            {
                SurfaceOutputStandard o;//声明变量
                UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandard,o);//初始化里面的信息。避免有的时候报错干扰
                fixed4 AlbedoColorSampler = tex2D(_MainTex, i.uv) * _Color;//采样颜色贴图，同时乘以控制的TintColor
                o.Albedo = AlbedoColorSampler.rgb;//颜色分量，a分量在后面
                o.Emission = _Emission;//自发光
                fixed4 MetallicSmoothnessSampler = tex2D(_MetallicTex,i.uv);//采样Metallic-Smoothness贴图
                o.Metallic = MetallicSmoothnessSampler.g * _Metallic; //g通道乘以控制色并赋予金属度
                o.Smoothness = MetallicSmoothnessSampler.r * _Glossiness; //r通道乘以控制色并赋予光滑度
                o.Alpha = AlbedoColorSampler.a;//单独赋予透明度
                o.Occlusion = tex2D(_OcclussionTex, i.uv).g * _AO; //采样AO贴图，乘以控制色，赋予AO
                o.Normal = worldNormal;//赋予法线
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos) //计算光照衰减和阴影

                UnityGI gi;
                UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
                gi.indirect.diffuse = 0;//indirect部分先给0参数，后面需要计算出来。这里只是示意
                gi.indirect.specular = 0;
                gi.light.color = _LightColor0.rgb;//unity内置的灯光颜色变量
                gi.light.dir = lightDir;//赋予之前计算的灯光方向。

                UnityGIInput giInput;
                UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);//初始化归零
                giInput.light = gi.light;//之前这个light已经给过，这里补到这个结构体即可。
                giInput.worldPos = i.worldPos;//世界坐标
                giInput.worldViewDir = worldViewDir;//摄像机方向
                giInput.atten = atten;//在之前的光照衰减里面已经被计算。其中包含阴影的计算了。
                giInput.ambient = i.sh;
                
                //反射探针相关
                giInput.probeHDR[0] = unity_SpecCube0_HDR;
                giInput.probeHDR[1] = unity_SpecCube1_HDR;
                #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
                    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
                #endif
                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
                    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
                    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
                    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
                    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
                #endif

                //基于PBS的全局光照（gi变量）的计算函数。计算结果是gi的参数（Light参数和Indirect参数）。注意这一步还没有做真的光照计算。
                LightingStandard_GI(o, giInput, gi);
                fixed4 c = 0;
                // realtime lighting: call lighting function
                //PBS计算
                c += LightingStandard(o, worldViewDir, gi);
                return c;
            }

            fixed4 NPR(v2f i, half3 bump, fixed3 light_direction, fixed3 view_direction, half3 worldNormal)
            {
                // 漫反射
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed half_lambert = dot(bump, light_direction) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * tex2D(_Ramp, float2(half_lambert, 0.0)).rgb;

                // 高光
                fixed3 half_diretion = normalize(light_direction + view_direction);
                fixed spec = dot(bump, half_diretion);
				fixed w = fwidth(spec) * 2.0;
				fixed3 specular = fixed3(0, 0, 0) * lerp(0, 1, smoothstep(-w, w, spec + 10 - 1)) * step(0.0001, 10);

                // 边缘光
                half f =  1.0 - saturate(dot(view_direction, worldNormal));
                half rim = smoothstep(_RimMin, _RimMax, f);
                rim = smoothstep(0, _RimSmooth, rim);
                half3 rim_color = rim * _RimColor.rgb *  _RimColor.a;
                diffuse += rim_color;

                // 遮罩
                fixed ao_mask = tex2D(_OcclussionTex, i.uv).g * _AO;
                diffuse *= ao_mask;
                
                return fixed4((ambient + diffuse + specular) * tex, tex.a);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normalTex = UnpackNormal(tex2D(_Normal,i.uv));//使用法线的采样方式对法线贴图进行采样。
                //切线空间法线（带贴图）转向世界空间法线，这里是常用的法线转换方法。
                half3 worldNormal = normalize(half3(dot(i.tSpace0,normalTex),dot(i.tSpace1,normalTex), dot(i.tSpace2,normalTex)));
                //计算灯光方向：注意这个方法已经包含了对灯光的判定。
                //其实在forwardbase pass中，可以直接用灯光坐标代替这个方法，因为只会计算Directional Light。
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));//片段指向摄像机方向viewDir
                fixed3 view_direction = normalize(UnityWorldSpaceViewDir(i.worldPos));
                
                fixed4 c1 = PBR(i, worldNormal, lightDir, worldViewDir) * 0.1f;
                fixed4 c2 = NPR(i, normalTex, lightDir, view_direction, worldNormal) * 0.9f;
                fixed4 c = c1 + c2;

                //叠加雾效。
                UNITY_EXTRACT_FOG(i);//此方法定义了一个片段着色器里的雾效坐标变量，并赋予传入的雾效坐标。
                UNITY_APPLY_FOG(_unity_fogCoord, c); // apply fog
                return c;
            }
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
