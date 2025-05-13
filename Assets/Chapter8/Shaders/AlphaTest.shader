Shader"Unity Shader Book/Chapter8/Alpha Test"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" { }
        _Color("Color", Color) = (1, 1, 1, 1)
        _Cutoff("Cutoff", Float) = 0.5
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipeline"
            "Queue" = "AlphaTest"
            "IgnoreProjector" = "True"
        }//这里不用写rendertype，那个只对Build-in RP有用
        LOD 200
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull Off
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _Cutoff;
                float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv0, _MainTex);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float diffuse = saturate(dot(IN.normalWS, GetMainLight().direction) * 0.5 + 0.5);
                float3 diffuseColor = texColor.rgb * _Color.rgb * diffuse;
                float3 ambient = SampleSH(IN.normalWS);
                clip(texColor.a - _Cutoff);

                return float4(ambient + diffuseColor, 1.0);
            }
            
            ENDHLSL
            
        }
    }
}