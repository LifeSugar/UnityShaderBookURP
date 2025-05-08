Shader "Unity Shader Book/Chapter6/ Diffuse Pixel Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "Universal"
            "Queue" = "Geometry"
            "PreviewType" = "Sphere"
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
            #pragma fragment  frag
            #include "BlinnPhong.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positonHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaMaterial)
                float4 _Diffuse;
            CBUFFER_END

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positonHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                float3 diffuse = PhongDiffuse(IN.normalWS, _Diffuse);
                return float4(diffuse, 1);
            }
            
            ENDHLSL
        }
    }
    
    
}