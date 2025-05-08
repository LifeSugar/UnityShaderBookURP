Shader "Unity Shader Book/Chapter6/PhongSpecularPerVertex"
{
    Properties
    {
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
                float3 color : COLOR0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _SpecularColor;
                float _Gloss;
            CBUFFER_END

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positonOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                float3 positionWS = TransformObjectToWorld(IN.positonOS.xyz);
                OUT.color = PhongSpecular(normalWS, positionWS, _SpecularColor.xyz, _Gloss);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                return float4(IN.color, 1.0);
            }

            ENDHLSL
        }
    }
}