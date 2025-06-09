Shader "Unity Shader Book/Chapter5/Simple Shader"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex("MainTex", 2D) = "white" { }
    }
    
    SubShader
    {
        LOD 100
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
            "PreviewType" = "Sphere"
        }
        Pass
        {
            //注意build-in rp的lightmode和URP的区别，并不通用
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);


            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.pos = TransformObjectToHClip(IN.vertex.xyz);
                float3 c = IN.normal * 0.5f + float3(0.5f, 0.5f, 0.5f);
                OUT.color = float4(c, 1.0f);
                return OUT;
            }

            float4 frag(v2f IN): SV_Target
            {
                float4 c = IN.color;
                c *= _Color;
                return c;
            }
            ENDHLSL
        }
    }
}