Shader "Unity Shader Book/Chapter7/RampTexture"
{
    Properties
    {
        _ColorTint("ColorTint", Color) = (1, 1, 1, 1)
        _RampTex("RampTex", 2D) = "white" { }
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Float) = 20
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }
        LOD 200
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull Back
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float4 positonHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorTint;
                float4 _Specular;
                float4 _RampTex_ST;
                float _Gloss;
            CBUFFER_END

            TEXTURE2D(_RampTex); SAMPLER(sampler_RampTex);

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positonHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                float3 L = GetMainLight().direction;
                float3 V = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                float3 N = normalize(IN.normalWS);
                float3 H = normalize(L + V);

                float diffuse = (dot(L, N) * 0.5 + 0.5);
                float spec = pow(saturate(dot(H, N)), _Gloss);

                float2 texCoord = float2 (diffuse, diffuse);
                texCoord = TRANSFORM_TEX(texCoord, _RampTex);

                float3 diffuseColor = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex,
                    texCoord).rgb * _ColorTint.rgb;

                float3 specularColor = spec * _Specular.rgb;

                return float4(diffuseColor + specularColor, 1);


                
            }
            
            
            ENDHLSL
        }
    }
}