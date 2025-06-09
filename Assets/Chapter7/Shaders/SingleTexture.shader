Shader "Unity Shader Book/Chapter7/SingleTexture"
{
    Properties
    {
        _ColorTint("ColorTint", Color) = (1, 1, 1, 1)
        _MainTex("Main_Tex", 2D) = "white" { }
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Float) = 20
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Geometry"
        }
        LOD 200
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            ZTest LEqual
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Chapter6/Shaders/BlinnPhong.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorTint;
                float4 _Specular;
                float _Gloss;
                float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata IN )
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                
                float2 uv = TRANSFORM_TEX(IN.uv, _MainTex);
                float3 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
                float3 diffuse = HalfLambertDiffuse(IN.normalWS, c);
                float3 ambient = SampleSH(IN.normalWS);
                float3 specular = BlinnPhongSpecular(IN.normalWS, IN.positionWS, _Specular.xyz, _Gloss );
                float3 color = _ColorTint.rgb * diffuse + ambient + specular;
                return float4(color ,1);
            }

            

            ENDHLSL
        }
    }
}