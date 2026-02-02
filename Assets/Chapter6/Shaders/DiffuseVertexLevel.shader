Shader "Unity Shader Book/Chapter6/ Diffuse Vertex Level"
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
                float4 positonHCS : POSITION;
                float3 color : COLOR0;
            };

            CBUFFER_START(UnityPerMaMaterial)
                float4 _Diffuse;
            CBUFFER_END

            v2f vert (appdata IN)
            {
                v2f OUT;
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);

                //法线的变换要乘逆转置矩阵，以下是Unity的内置函数
                // Transforms normal from object to world space
                // float3 TransformObjectToWorldNormal(float3 normalOS, bool doNormalize = true)
                // {
                // #ifdef UNITY_ASSUME_UNIFORM_SCALING
                //     return TransformObjectToWorldDir(normalOS, doNormalize);
                // #else
                //     // Normal need to be multiply by inverse transpose
                //     float3 normalWS = mul(normalOS, (float3x3)GetWorldToObjectMatrix());
                //     if (doNormalize)
                //         return SafeNormalize(normalWS);
                //
                //     return normalWS;
                // #endif
                // }
                OUT.color = PhongDiffuse(normalWS, _Diffuse.rgb);
                OUT.positonHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                return float4(IN.color, 1);
            }
            
            ENDHLSL
        }
    }
    
    
}