Shader"Unity Shader Book/Debug"
{
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipeline"
            "Queue" = "Geometry"
        }
        LOD 100
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
                
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
                

                return float4(IN.positonHCS.xyz, 1);
            }


            ENDHLSL
        }
    }
}