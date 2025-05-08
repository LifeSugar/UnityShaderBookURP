Shader "Unity Shader Book/Chapter6/BlinnPhongShading"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _SpecularColor("SpecularColor", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Float) = 3.0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipelne"
            "Queue" = "Geometry"
        }
        LOD 200
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            ZWrite On
            ZTest LEqual
            Cull Back
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "BlinnPhong.hlsl"

            struct appdata
            {
                float4 positonOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float4 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Diffuse;
                float4 _SpecularColor;
                float _Gloss;
            CBUFFER_END

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positonOS.xyz);
                OUT.positionWS = float4(TransformObjectToWorld(IN.positonOS.xyz), 1);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                float3 diffuse;
                diffuse = HalfLambertDiffuse(IN.normalWS, _Diffuse);
                float3 specular;
                specular = PhongSpecular(IN.normalWS, IN.positionWS.xyz, _SpecularColor.xyz, _Gloss);
                float3 ambient = SampleSH(IN.normalWS);
                return float4(diffuse + specular + ambient, 1.0);
            }

            ENDHLSL
        }
    }
}