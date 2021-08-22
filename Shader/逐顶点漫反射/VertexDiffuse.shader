Shader "Test/VertexDiffuse"
{
    Properties
    {
        _Diffuse ("漫反射颜色", Color) = (1,1,1,1)
        _SpecularColor ("高光颜色", Color) = (1,1,1,1)
        _Gloss("高光光斑大小", Range(8, 200)) = 10
        [Toggle] _HalfLambert ("使用半兰伯特光照模型", Float) = 0
        [Toggle] _Ambient ("受环境光影响", Float) = 0
    }
    SubShader
    {
        Pass
        {
           Tags{"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert //顶点函数，完成顶点坐标从模型空间到裁剪空间的转换（相当于世界坐标转屏幕坐标）,每个顶点调用一次
            #pragma fragment frag //片元函数，返回模型每一个像素的颜色值，每个像素调用一次
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _SpecularColor;
            half _Gloss;
            float _HalfLambert;
            float _Ambient;
            struct a2v
            {
                float4 vertex : POSITION; //顶点(模型空间)
                float3 normal : NORMAL; //法线(模型空间)
            };
            struct v2f
            {
                float4 position : SV_POSITION; //剪裁空间中的顶点坐标（一般是系统直接使用）
                fixed3 color : COLOR; //可以传递一组值(4个),这里只赋值3个也可以
            };

            // 语义：
            // POSITION -> 用v接收顶点坐标，顶点坐标从模型 mesh获取
            // SV_POSITION -> 解释说明返回值，返回裁剪空间下的顶点坐标
            // 逐顶点漫射，在顶点函数中计算漫反射颜色
            v2f vert(const a2v v)
            {
                v2f f;
                f.position = UnityObjectToClipPos(v.vertex);

                const fixed3 normal_direction = normalize(mul((float3x3)unity_ObjectToWorld, v.normal)); //v.normal还在模型空间，要转换到世界空间
                const fixed3 light_direction = normalize(_WorldSpaceLightPos0.xyz); //因为光是平行光，所以对于顶点来说，光的位置（向量）就是光的方向（向量）
                const fixed3 cosine_value = dot(normal_direction, light_direction); //cosθ = 光方向 · 法线方向
                fixed3 diffuse;
                
                const fixed3 reflect_direction = normalize(reflect(-light_direction, normal_direction));
                const fixed3 view_direction = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                const fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(dot(reflect_direction,view_direction), 0), _Gloss); //Specular = 直射光 * pow(max(cosθ,0),10)  θ:是反射光方向和视野方向的夹角

                if (_HalfLambert)
                {
                    diffuse = _LightColor0.rgb * cosine_value * 0.5 + 0.5; //半兰伯特光照模型：Diffuse = 直射光颜色 * (cos(光和法线的夹角) * 0.5 + 0.5)
                }
                else
                {
                    diffuse = _LightColor0.rgb * max(0, cosine_value); //兰伯特光照模型：漫反射 = 直射光颜色 * max(0,cos(光和法线的夹角))
                }
                
                diffuse *= _Diffuse.rgb; //叠加物体本身颜色
                diffuse += UNITY_LIGHTMODEL_AMBIENT.rgb * _Ambient; //叠加环境光颜色
                f.color = diffuse + specular; //叠加高光
                
                return f;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                return fixed4(f.color, 1);
            }
            ENDCG
        }
    }
}
