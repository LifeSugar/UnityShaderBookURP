Shader"Unity Shader Book/Debug"
{
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        LOD 100
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
                "Queue" = "Geometry"
            }
            Cull Back
            ZTest LEqual
            ZWrite On
            
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
                float4 positonHCS : SV_POSITION;
            };

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positonHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                float3 a = float3(0.3, 0.2, 0.4);
                float3 b = float3(0.1, 1, 0.4);
                float3 c = float3(1, 0.5, 0.9);

                float3x2 m = float3x3(a, b, c);

                return float4(m[0][1], m[0][1], m[0][1], 1);
            }


            ENDHLSL
        }
    }
}