Shader "Unity Shader Book/Chapter8/AlphaBlend"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("MainTex", 2D) = "white" {}
        _AlphaParams("Alpha Scale", Vector) = (1, 0, 0, 0) // .x 用作实际的 alpha 缩放
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue"          = "Transparent"
        }
        LOD 200
        
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 uv0        : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float3 positionWS  : TEXCOORD1;
                float2 uv          : TEXCOORD2;
            };

            // 与 URP 内置 UnityPerMaterial 完全一致的布局：3 个 float4
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
                float4 _AlphaParams;   // x 分量即 _AlphaScale
            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            v2f vert(appdata IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv          = TRANSFORM_TEX(IN.uv0, _MainTex);
                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                // 采样贴图
                float4 texCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float3 albedo = texCol.rgb;

                // 漫反射光照
                float nl = saturate(dot(IN.normalWS, GetMainLight().direction) * 0.5 + 0.5);
                float3 diff = nl * albedo * _Color.rgb;

                // 环境光
                float3 amb = SampleSH(IN.normalWS);

                // alpha = 用户在面板里调的 x 分量 * 贴图的 alpha
                float alpha = _AlphaParams.x * texCol.a;

                return float4(diff + amb, alpha);
            }
            ENDHLSL
        }
    }
}
