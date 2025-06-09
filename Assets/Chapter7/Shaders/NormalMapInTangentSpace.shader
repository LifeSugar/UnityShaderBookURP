Shader "Unity Shader Book/Chapter7/Normal Map In Tangent Space"
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
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Geometry" }
        LOD 200

        Pass
        {
            Tags { "LightMode"="UniversalForward" }

            ZWrite On  ZTest LEqual  Cull Back

            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            // #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 positionOS : POSITION;
                float4 tangent    : TANGENT;   // xyz=T, w=±1
                float3 normalOS   : NORMAL;
                float2 uv0        : TEXCOORD0;
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float2 uvMain      : TEXCOORD0;
                float2 uvBump      : TEXCOORD1;
                float3 lightDirTS  : TEXCOORD2;
                float3 viewDirTS   : TEXCOORD3;
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


            v2f vert(appdata IN)
            {
                v2f OUT;


                // 1. 变换位置
                float3 positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS    = TransformWorldToHClip(positionWS);


                // 2. 计算 TBN → 世界
                VertexNormalInputs nrm = GetVertexNormalInputs(IN.normalOS, IN.tangent);
                // 处理模型负缩放：tangent.w * unity_WorldTransformParams.w
                float  flip      = IN.tangent.w;
                float3x3 T2W     = CreateTangentToWorld(nrm.normalWS, nrm.tangentWS, flip); //行主序
                float3x3 W2T     = transpose(T2W);          // 世界 → 切线 

                // 3. 主光 / 视线转到切线
                Light mainLight    = GetMainLight();        // 世界空间方向
                OUT.lightDirTS     = mul(mainLight.direction, W2T);
                float3 viewDirWS   = GetWorldSpaceViewDir(positionWS);
                OUT.viewDirTS      = mul(viewDirWS, W2T);

                // 4. 传 UV
                OUT.uvMain = TRANSFORM_TEX(IN.uv0, _MainTex);
                OUT.uvBump = TRANSFORM_TEX(IN.uv0, _BumpMap);

                return OUT;
            }

            half4 frag(v2f IN) : SV_Target
            {

                half3 albedo  = SAMPLE_TEXTURE2D(_MainTex , sampler_MainTex , IN.uvMain).rgb
                                * _ColorTint.rgb;

                // 切线空间法线
                half3 normalTS = UnpackNormalScale(
                                    SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uvBump),
                                    _BumpScale);

                //----------------- 光照计算（切线空间） -----
                half3 N = normalize(normalTS);
                half3 L = normalize(IN.lightDirTS);
                half3 V = normalize(IN.viewDirTS);
                half3 H = normalize(L + V);

                half  diff = saturate(dot(N, L) * 0.5 + 0.5);
                half  spec = pow(saturate(dot(N, H)), _Gloss);

                //----------------- 合成输出 -----------------
                Light mainLight = GetMainLight();
                half3 color = albedo * diff * mainLight.color
                            + _Specular.rgb * spec * mainLight.color;

                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
