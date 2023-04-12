Shader "Test/CartoonHairShader" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        _Gloss ("Gloss", Range(0.0, 1.0)) = 0.5
        _Power ("Power", Range(0.0, 5.0)) = 1.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGPROGRAM
        #pragma surface surf Standard 
        #pragma target 3.5

        sampler2D _MainTex;
        
        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
        };
        half _Gloss;
        half _Power;
        float _Cutoff;
        half3 _Color;
        void surf (Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = _Color.rgb * tex2D(_MainTex, IN.uv_MainTex).rgb;
            o.Metallic = 0.0;
            o.Smoothness = _Gloss;
            // o.Specular  = pow(max(dot(normalize(UnityWorldSpaceLightDir(IN.worldPos)), normalize(IN.worldNormal) * 2 - 1), 0.0), _Power);
        }
        ENDCG
    }

    FallBack "Diffuse"
}    