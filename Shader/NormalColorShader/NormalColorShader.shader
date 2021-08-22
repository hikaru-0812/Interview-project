// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Test/NormalColorShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
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
            
            //application to vertex 从应用传到顶点的数据
            struct a2v
            {
                float4 vertex : POSITION; //告诉unity把模型空间下的顶点坐标填充给vertex
                float3 normal : NORMAL; //告诉unity把模型空间下的法线方向填充给normal
                float4 texcoord : TEXCOORD; //告诉unity把第一套纹理坐标填充给texcoord
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 normal : COLOR0;
            };
            
            // 语义：
            // POSITION -> 用v接收顶点坐标，顶点坐标从模型 mesh获取
            // SV_POSITION -> 解释说明返回值，返回裁剪空间下的顶点坐标
            v2f vert(const a2v v)
            {
                v2f f;
                f.position = UnityObjectToClipPos(v.vertex);
                f.normal = v.normal;
                return f;
            }

            fixed4 frag(v2f f) : SV_Target
            {
                return fixed4(f.normal , 1.0);
            }
            
            ENDCG
        }
    }
    //Fallback"VertexLit"
}
