Shader"Unity Shader Book/Chapter7/MaskMap"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("MainTex", 2D) = "white"{}
        _BumpMap("BumpMap", 2D) = "bump" { }
        _BumpScale("BumpScale", Float) = 1.0
        _MaskMap("SpecularMask", 2D) = "white" {}
        _SpecularScale("SpecularScale", Float) = 1.0
        _Specular("specular", Color) = (1, 1, 1, 1)
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
            ZTest LEqual
            ZWrite On
            Cull Back
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float4 normalWS : TEXCOORD0;
                float4 tangentWS : TEXCOORD1;
                float4 uv : TEXCOORD2;
                float4 positionWS : TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _Specular;
                float _SpecularScale;
                float _Gloss;
                float _BumpScale;
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float4 _MaskMap_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap);
            TEXTURE2D(_MaskMap); SAMPLER(sampler_MaskMap);

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS.xyz = TransformObjectToWorldNormal(IN.normalOS);
                VertexNormalInputs nrm = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS.xyz = nrm.normalWS;
                float flip = IN.tangentOS.w;
                OUT.tangentWS = float4(nrm.tangentWS, flip);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv0, _MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv0, _BumpMap);
                OUT.positionWS.xyz = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionWS.w = TRANSFORM_TEX(IN.uv0, _MaskMap).x;
                OUT.normalWS.w = TRANSFORM_TEX(IN.uv0, _MaskMap).y;

                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv.zw), _BumpScale);
                float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv.xy).rgb;

                float mask = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, float2(IN.positionWS.w, IN.normalWS.w)).r;

                float3x3 T2W = CreateTangentToWorld(IN.normalWS.xyz, IN.tangentWS.xyz, IN.tangentWS.w);
                // float3 N = normalize(mul( normalTS, T2W));
                float3 N = TransformTangentToWorld(normalTS, T2W);
                float3 L = GetMainLight().direction;
                float3 V = GetWorldSpaceNormalizeViewDir(IN.positionWS.xyz);
                float3 H = normalize(L + V);

                float diffuse = dot(N, L) * 0.5 + 0.5;
                float specular = pow(saturate(dot(N, H)), _Gloss) * mask * _SpecularScale;
                // return float4(normalTS * 0.5 + 0.5, 1);

                return float4 (diffuse * albedo * _Color.rgb + specular * _Specular.xyz, 1);
                
                
            }
                

            ENDHLSL
            
        }
    }
}