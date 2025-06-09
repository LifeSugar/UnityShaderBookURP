Shader"Unity Shader Book/Chapter8/Blend Mode"
{
    Properties
    {
        _Color("Color", Color) = (0.5, 0.5, 1, 1)
        [HideInInspector]_BlendMode("BlendMode", Float) = 1
        [HideInInspector]_SurfaceType("SurfaceType", Float) = 1
        [HideInInspector]_SrcBlend("SrcBlend", Float) = 0.0
        [HideInInspector]_DstBlend("DstBlend", Float) = 0.0
        [HideInInspector]_BlendOp("BlendOp", Float) = 0.0
        [HideInInspector]_ZWrite("ZWrite", Float) = 0

    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            
            HLSLPROGRAM

            #pragma shader_feature _ZWRITE_OFF

            #ifdef _ZWRITE_OFF

            #endif

            ENDHLSL

            
            ZTest LEqual
            Cull Off
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
            };


            struct v2f
            {
                float4 positionHCS : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _BlendMode;
                float _SurfaceType;
                float _ZWrite;
            CBUFFER_END

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                return _Color;
            }
            
            ENDHLSL
        }
    }

    CustomEditor "ShaderBook.Chapter8.URPBlendModeShaderGUI"
}