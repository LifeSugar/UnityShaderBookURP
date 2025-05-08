Shader"Unity Shader Book/Chapter7/Normal Map In World Space"
{
    Properties
    {
        _ColorTint ("ColorTint", Color) = (1,1,1,1)
        _MainTex   ("MainTex"  , 2D)   = "white" {}
        _BumpMap   ("BumpMap"  , 2D)   = "bump"  {}
        _BumpScale ("BumpScale", Float) = 1
        _Specular  ("Specular" , Color) = (1,1,1,1)
        _Gloss     ("Gloss"    , Float) = 20
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalRenderPipeline"
            "Queue" = "Geometry"
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
                float4 positonHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _ColorTint;
                float4 _Specular;
                float  _Gloss;
                float4 _MainTex_ST;
                float4 _BumpMap_ST;
                float  _BumpScale;
            CBUFFER_END

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap);

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.positonHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv0, _MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv0, _BumpMap);

                VertexNormalInputs nrm = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS = nrm.normalWS;
                OUT.tangentWS = float4(nrm.tangentWS, IN.tangentOS.w);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                half3 albedo  = SAMPLE_TEXTURE2D(_MainTex , sampler_MainTex , IN.uv.xy).rgb
                                * _ColorTint.rgb;

                
                float flip = IN.tangentWS.w * unity_WorldTransformParams.w;
                float3x3 T2W = CreateTangentToWorld(IN.normalWS, IN.tangentWS.xyz, flip);
                float3 normalTS = UnpackNormalScale(
                    SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv.zw), _BumpScale);
                float3 N = normalize(mul(T2W, normalTS));
                Light mainlight = GetMainLight();
                float3 V = normalize(GetWorldSpaceViewDir(IN.positionWS));
                float3 L = normalize(mainlight.direction);
                float3 H = normalize(V + L);

                half  diff = saturate(dot(N, L));
                half  spec = pow(saturate(dot(N, H)), _Gloss);

                Light mainLight = GetMainLight();
                half3 color = albedo * diff * mainLight.color
                            + _Specular.rgb * spec * mainLight.color;

                return half4(color, 1);
            }


            
            ENDHLSL
        }
    }
}