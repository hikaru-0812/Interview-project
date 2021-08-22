Shader "Test/Alpha"
{
    Properties
    {
        _MainTex ("图片纹理", 2D) = "white"{}
        _NormalMap("法线贴图", 2D) = "bump"{}
        _BumpScale("法线强度", Range(0, 10)) = 1
        _SpecularColor ("高光颜色", Color) = (1,1,1,1)
        _Gloss("高光光斑大小", Range(8, 200)) = 100
        [Toggle] _HalfLambert ("使用半兰伯特光照模型", Float) = 0
        [Toggle] _BlinnPhong ("使用BlinnPhong高光光照模型", Float) = 0
        [Toggle] _Ambient ("受环境光影响", Float) = 0
    }
    SubShader
    {
        Tags{"Queue" = "Transparent" "IngnoreProjector" = "True" "RenderType" = "Transparent"}
        Pass
        {
           Tags{"LightMode" = "ForwardBase"}
           ZWrite Off
           Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert //顶点函数，完成顶点坐标从模型空间到裁剪空间的转换（相当于世界坐标转屏幕坐标）,每个顶点调用一次
            #pragma fragment frag //片元函数，返回模型每一个像素的颜色值，每个像素调用一次
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST; //贴图的tilling和offset
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float _BumpScale;
            fixed4 _SpecularColor; 
            half _Gloss;
            float _HalfLambert;
            float _BlinnPhong;
            float _Ambient;
            struct a2v
            {
                float4 vertex : POSITION; //顶点(模型空间)
                float3 normal : NORMAL; //法线(模型空间)
                float4 tangent : TANGENT; //tangent.w用来确定切线空间中坐标轴的方向
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 position : SV_POSITION; //剪裁空间中的顶点坐标（一般是系统直接使用）
                //fixed3 world_normal_direction : TEXCOORD0; //可以传递一组值(4个),这里只赋值3个也可以
                float3 light_direction : TEXCOORD0; //切线空间下的平行光方向
                float4 world_vertex : TEXCOORD1;
                float4 uv : TEXCOORD2; //x,y用来存储主贴图的uv,z,w用来存储法线贴图的uv
            };

            fixed3 get_diffuse(fixed3 cosine_value, fixed4 texColor, v2f f)
            {
                fixed3 diffuse;
                if (_HalfLambert)
                {
                    diffuse = _LightColor0.rgb * cosine_value * 0.5 + 0.5; //半兰伯特光照模型：Diffuse = 直射光颜色 * (cos(光和法线的夹角) * 0.5 + 0.5)
                }
                else
                {
                    diffuse = _LightColor0.rgb * max(0, cosine_value); //兰伯特光照模型：漫反射 = 直射光颜色 * max(0,cos(光和法线的夹角))
                }
                diffuse *= texColor.rgb;
                diffuse += UNITY_LIGHTMODEL_AMBIENT.rgb * _Ambient * texColor; //叠加环境光颜色
                return diffuse;
            }

            fixed3 get_specular(fixed3 normal_direction, fixed3 light_direction,  v2f f)
            {
                fixed3 reflect_direction = normalize(reflect(-light_direction, normal_direction));
                // fixed3 view_direction = normalize(_WorldSpaceCameraPos.xyz - f.world_vertex);
                fixed3 view_direction = normalize(UnityWorldSpaceViewDir(f.world_vertex));
                fixed3 specular;

                if (_BlinnPhong)
                {
                    fixed3 half_direction = normalize(view_direction + light_direction);
                    specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(dot(normal_direction,half_direction), 0), _Gloss); //Specular = 直射光 * pow(max(cosθ,0),10)  θ:是法线和x的夹角  x 是平行光和视野方向的平分线
                    
                }
                else
                {
                    specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(dot(reflect_direction,view_direction), 0), _Gloss); //Specular = 直射光 * pow(max(cosθ,0),10)  θ:是反射光方向和视野方向的夹角
                }
                
                return specular;
            }

            // 语义：
            // POSITION -> 用v接收顶点坐标，顶点坐标从模型 mesh获取
            // SV_POSITION -> 解释说明返回值，返回裁剪空间下的顶点坐标
            v2f vert(a2v v)
            {
                v2f f;
                
                f.position = UnityObjectToClipPos(v.vertex);
                // f.world_normal_direction = UnityObjectToWorldNormal(v.normal);
                f.world_vertex = mul(unity_ObjectToWorld, v.vertex);
                f.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                f.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
                
                TANGENT_SPACE_ROTATION; //调用这个宏之后,会得到一个矩阵rotation,这个矩阵用来把切线空间下的法线方向转换成模型空间下
                //ObjSpaceLightDir(v.vertex) //得到模型空间下的平行光方向
                f.light_direction = mul(rotation, ObjSpaceLightDir(v.vertex));
                
                return f;
            }

            // SV_Target -> 颜色值，显示到屏幕上的颜色
            // 逐片元漫射，在片元函数中计算漫反射颜色
            fixed4 frag(v2f f) : SV_Target
            {
                //fixed3 normal_direction = normalize(f.world_normal_direction);
                fixed4 texColor = tex2D(_MainTex, f.uv.xy);
                fixed4 normal_color = tex2D(_NormalMap, f.uv.zw);
                fixed3 tangent_normal = normalize(UnpackNormal(normal_color));
                tangent_normal.xy *= _BumpScale; //应用法线强度
                
                // fixed3 light_direction = normalize(_WorldSpaceLightPos0.xyz); //因为光是平行光，所以对于顶点来说，光的位置（向量）就是光的方向（向量）
                fixed3 light_direction = normalize(WorldSpaceLightDir(f.world_vertex).xyz);
                // fixed3 cosine_value = dot(normal_direction, light_direction); //cosθ = 光方向· 法线方向
                fixed3 cosine_value = dot(tangent_normal, light_direction);
                
                fixed3 diffuse = get_diffuse(cosine_value, texColor, f);
                // fixed3 specular = get_specular(normal_direction, light_direction, f);
                
                // return fixed4(diffuse + specular, 1); //叠加高光
                return fixed4(diffuse, texColor.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}