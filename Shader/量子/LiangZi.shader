// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LiangZi"
{
	Properties
	{
		_Alpha("Alpha", Float) = 0
		_ScreenTexture("ScreenTexture", 2D) = "white" {}
		_ScreenTexTlingOffset("ScreenTexTlingOffset", Vector) = (1,1,0,0)
		_ScreenColor("ScreenColor", Color) = (0.3468875,0.25,1,0)
		_Panner("Panner", Vector) = (0,0,1,1)
		_FresnelMask("FresnelMask", Vector) = (1,5,1,0)
		_AldeboColor("AldeboColor", Color) = (0,0,0,0)
		_AlphaAdd("AlphaAdd", Float) = 0.25
		_Fresnel1_Power("Fresnel1_Power", Float) = 2
		_Fresnel1_Mul("Fresnel1_Mul", Float) = 0.5
		_OutLineFresnel("OutLineFresnel", Vector) = (1,5,0,1)
		_OutLineFresnelColor("OutLineFresnelColor", Color) = (1,1,1,0)
		_OutLineFresnelScale("OutLineFresnelScale", Float) = 1
		_VertexPosMaskColor("VertexPosMaskColor", Color) = (1,0.2028302,0.2028302,0)
		_VertexPosXYZ_Scale("VertexPosXYZ_Scale", Vector) = (0,1,0,0)
		_VertexPosOffset("VertexPosOffset", Float) = 0
		_VertexPosMaskSmooth("VertexPosMaskSmooth", Vector) = (-0.9,-1,1,5)
		_OutLineVertexColor("OutLineVertexColor", Color) = (1,0.2311321,0.2311321,0)
		_OutLineVertexOffset("OutLineVertexOffset", Float) = 0

	}
	
	SubShader
	{
		LOD 0

		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		
		Pass
		{
			
			Name "First"
			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
			};

			uniform sampler2D _ScreenTexture;
			uniform float4 _Panner;
			uniform float4 _ScreenTexTlingOffset;
			uniform float4 _ScreenColor;
			uniform float4 _AldeboColor;
			uniform float4 _FresnelMask;
			uniform float4 _OutLineFresnel;
			uniform float4 _OutLineFresnelColor;
			uniform float _OutLineFresnelScale;
			uniform float4 _VertexPosMaskSmooth;
			uniform float4 _VertexPosMaskColor;
			uniform float4 _VertexPosXYZ_Scale;
			uniform float _VertexPosOffset;
			uniform float _Alpha;
			uniform float _Fresnel1_Power;
			uniform float _Fresnel1_Mul;
			uniform float _AlphaAdd;
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				// o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord3 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				float mulTime15 = _Time.y * _Panner.z;
				float2 appendResult16 = (float2(_Panner.x , _Panner.y));
				float4 screenPos = i.ase_texcoord;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult7 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				float2 appendResult11 = (float2(_ScreenTexTlingOffset.x , _ScreenTexTlingOffset.y));
				float2 appendResult12 = (float2(_ScreenTexTlingOffset.z , _ScreenTexTlingOffset.w));
				float2 panner13 = ( mulTime15 * appendResult16 + (appendResult7*appendResult11 + appendResult12));
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float fresnelNdotV17 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode17 = ( 0.0 + _FresnelMask.x * pow( 1.0 - fresnelNdotV17, _FresnelMask.y ) );
				float temp_output_20_0 = saturate( ( fresnelNode17 * _FresnelMask.z ) );
				float4 lerpResult21 = lerp( ( tex2D( _ScreenTexture, panner13 ).r * _ScreenColor * _Panner.w ) , _AldeboColor , temp_output_20_0);
				float fresnelNdotV38 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode38 = ( 0.0 + _OutLineFresnel.x * pow( 1.0 - fresnelNdotV38, _OutLineFresnel.y ) );
				float smoothstepResult40 = smoothstep( _OutLineFresnel.z , _OutLineFresnel.w , fresnelNode38);
				float fresnelNdotV56 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode56 = ( 0.0 + _VertexPosMaskSmooth.z * pow( 1.0 - fresnelNdotV56, _VertexPosMaskSmooth.w ) );
				float smoothstepResult48 = smoothstep( _VertexPosMaskSmooth.x , _VertexPosMaskSmooth.y , ( ( ( _VertexPosXYZ_Scale.x * i.ase_texcoord3.xyz.x ) + ( _VertexPosXYZ_Scale.y * i.ase_texcoord3.xyz.y ) + ( _VertexPosXYZ_Scale.z * i.ase_texcoord3.xyz.z ) ) + _VertexPosOffset ));
				float dotResult29 = dot( ase_worldNormal , ase_worldViewDir );
				float4 appendResult4 = (float4(( lerpResult21 + ( saturate( smoothstepResult40 ) * _OutLineFresnelColor * _OutLineFresnelScale ) + ( fresnelNode56 * _VertexPosMaskColor * saturate( smoothstepResult48 ) ) ).rgb , saturate( ( _Alpha * ( ( temp_output_20_0 + ( pow( dotResult29 , _Fresnel1_Power ) * _Fresnel1_Mul ) ) + _AlphaAdd ) ) )));
				
				
				finalColor = appendResult4;
				return finalColor;
			}
			ENDCG
		}

		
		Pass
		{
			Name "Second"
			
			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Front
			ColorMask RGBA
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
				
			};

			uniform float _OutLineVertexOffset;
			uniform float4 _OutLineVertexColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				
				v.vertex.xyz += ( v.ase_normal * _OutLineVertexOffset );
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				
				
				finalColor = _OutLineVertexColor;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
595;72;1939;1115;-26.53882;1.877502;1;True;True
Node;AmplifyShaderEditor.NormalVertexDataNode;62;874.5388,578.1225;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;64;869.5388,717.1225;Inherit;False;Property;_OutLineVertexOffset;OutLineVertexOffset;18;0;Create;True;0;0;False;0;0;0.0001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-1289.5,-121;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;17;-990.6769,233.0547;Inherit;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1041.212,676.9828;Inherit;False;Property;_Fresnel1_Power;Fresnel1_Power;8;0;Create;True;0;0;False;0;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1277.5,82;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-792.6167,682.5208;Inherit;False;Property;_Fresnel1_Mul;Fresnel1_Mul;9;0;Create;True;0;0;False;0;0.5;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;-552.6769,-392.9453;Inherit;False;Property;_AldeboColor;AldeboColor;6;0;Create;True;0;0;False;0;0,0,0,0;0.1244175,0.009656467,0.2924527,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-636.6769,289.0547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;10;-1525.5,19;Inherit;False;Property;_ScreenTexTlingOffset;ScreenTexTlingOffset;2;0;Create;True;0;0;False;0;1,1,0,0;3,2,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;9;-1108.5,-119;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;39;-1142.59,895.189;Inherit;False;Property;_OutLineFresnel;OutLineFresnel;10;0;Create;True;0;0;False;0;1,5,0,1;1,11.45,0.005,0.015;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-937.5,13;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;20;-494.6769,293.0547;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;38;-914.876,850.0785;Inherit;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;13;-803.5,-79;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;40;-572.2131,849.2682;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;3;-569.5,-214;Inherit;False;Property;_ScreenColor;ScreenColor;3;0;Create;True;0;0;False;0;0.3468875,0.25,1,0;0.701084,0.6941177,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-300.5898,344.4601;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-579.5,-58;Inherit;True;Property;_ScreenTexture;ScreenTexture;1;0;Create;True;0;0;False;0;-1;None;d421d1641cc271042bd4d2ff77e72191;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;43;-350.2131,1057.268;Inherit;False;Property;_OutLineFresnelColor;OutLineFresnelColor;11;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;31;-815.9113,467.8831;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;28;-1295.412,467.083;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;15;-928.5,102;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;29;-1060.112,464.4831;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-69.17688,-182.7452;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-544.0114,472.283;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;14;-1106.5,5;Inherit;False;Property;_Panner;Panner;4;0;Create;True;0;0;False;0;0,0,1,1;0,0.02,1,26.94;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;11;-1283.5,-4;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-97.21313,845.2682;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GrabScreenPosition;6;-1527.5,-145;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;327.1831,-93.40002;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;54;-1601.957,-1119.225;Inherit;False;Property;_VertexPosXYZ_Scale;VertexPosXYZ_Scale;14;0;Create;True;0;0;False;0;0,1,0,0;-0.24,0,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1234.957,-1002.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1231.957,-881.2252;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1240.957,-1122.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1232.957,-780.2252;Inherit;False;Property;_VertexPosOffset;VertexPosOffset;15;0;Create;True;0;0;False;0;0;-0.998;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-1046.957,-1024.225;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;49;-845.4351,-972.762;Inherit;False;Property;_VertexPosMaskSmooth;VertexPosMaskSmooth;16;0;Create;True;0;0;False;0;-0.9,-1,1,5;-0.995,-1,1,0.65;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-834.4351,-1192.762;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;48;-575.4349,-1203.762;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;56;-523.435,-945.7619;Inherit;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;59;-327.435,-1195.762;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;65;879.539,409.1225;Inherit;False;Property;_OutLineVertexColor;OutLineVertexColor;17;0;Create;True;0;0;False;0;1,0.2311321,0.2311321,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-141.4352,-938.7619;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;155.7088,242.2896;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;203.3163,166.2818;Inherit;False;Property;_Alpha;Alpha;0;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;385.8085,198.0898;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;885.5793,177.7182;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;27;669.8717,193.9259;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1102.539,576.1225;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-400.2131,758.2682;Inherit;False;Property;_OutLineFresnelScale;OutLineFresnelScale;12;0;Create;True;0;0;False;0;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;19;-1213.877,276.4546;Inherit;False;Property;_FresnelMask;FresnelMask;5;0;Create;True;0;0;False;0;1,5,1,0;1,1.5,1,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;41;-319.2131,845.2682;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-261.5,-150;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;58;-486.9969,-705.9855;Inherit;False;Property;_VertexPosMaskColor;VertexPosMaskColor;13;0;Create;True;0;0;False;0;1,0.2028302,0.2028302,0;0.2774376,0.1937966,0.6320754,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;46;-1584.956,-950.2253;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-22.39114,329.3894;Inherit;False;Property;_AlphaAdd;AlphaAdd;7;0;Create;True;0;0;False;0;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-1290.212,652.9829;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;61;1337.781,553.4772;Float;False;False;-1;2;ASEMaterialInspector;0;14;New Amplify Shader;003dfa9c16768d048b74f75c088119d8;True;Second;0;1;Second;2;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;False;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;1;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;True;2;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;60;1102.781,182.4771;Float;False;True;-1;2;ASEMaterialInspector;0;14;LiangZi;003dfa9c16768d048b74f75c088119d8;True;First;0;0;First;2;False;False;False;False;False;False;False;False;False;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;False;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;True;2;0;;0;0;Standard;0;0;2;True;True;False;;0
WireConnection;7;0;6;1
WireConnection;7;1;6;2
WireConnection;17;2;19;1
WireConnection;17;3;19;2
WireConnection;12;0;10;3
WireConnection;12;1;10;4
WireConnection;18;0;17;0
WireConnection;18;1;19;3
WireConnection;9;0;7;0
WireConnection;9;1;11;0
WireConnection;9;2;12;0
WireConnection;16;0;14;1
WireConnection;16;1;14;2
WireConnection;20;0;18;0
WireConnection;38;2;39;1
WireConnection;38;3;39;2
WireConnection;13;0;9;0
WireConnection;13;2;16;0
WireConnection;13;1;15;0
WireConnection;40;0;38;0
WireConnection;40;1;39;3
WireConnection;40;2;39;4
WireConnection;37;0;20;0
WireConnection;37;1;32;0
WireConnection;1;1;13;0
WireConnection;31;0;29;0
WireConnection;31;1;33;0
WireConnection;15;0;14;3
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;21;0;2;0
WireConnection;21;1;22;0
WireConnection;21;2;20;0
WireConnection;32;0;31;0
WireConnection;32;1;36;0
WireConnection;11;0;10;1
WireConnection;11;1;10;2
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;42;2;44;0
WireConnection;45;0;21;0
WireConnection;45;1;42;0
WireConnection;45;2;57;0
WireConnection;52;0;54;2
WireConnection;52;1;46;2
WireConnection;53;0;54;3
WireConnection;53;1;46;3
WireConnection;51;0;54;1
WireConnection;51;1;46;1
WireConnection;55;0;51;0
WireConnection;55;1;52;0
WireConnection;55;2;53;0
WireConnection;47;0;55;0
WireConnection;47;1;50;0
WireConnection;48;0;47;0
WireConnection;48;1;49;1
WireConnection;48;2;49;2
WireConnection;56;2;49;3
WireConnection;56;3;49;4
WireConnection;59;0;48;0
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;57;2;59;0
WireConnection;25;0;37;0
WireConnection;25;1;26;0
WireConnection;24;0;5;0
WireConnection;24;1;25;0
WireConnection;4;0;45;0
WireConnection;4;3;27;0
WireConnection;27;0;24;0
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;41;0;40;0
WireConnection;2;0;1;1
WireConnection;2;1;3;0
WireConnection;2;2;14;4
WireConnection;61;0;65;0
WireConnection;61;1;63;0
WireConnection;60;0;4;0
ASEEND*/
//CHKSM=D2DFF85C1BAD7FC1C0CEF529DF29ED6D8169E71B