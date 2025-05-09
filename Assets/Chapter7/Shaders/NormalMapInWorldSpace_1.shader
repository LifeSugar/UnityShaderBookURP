Shader"Unity Shader Book/Chapter7/Normal Map In World Space TBN"
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

            //TBN矩阵 [T B N], 将TBN分别存在TEXCOORD中，w分量来存PositionWS
            struct v2f
            {
                float4 positonHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 T : TEXCOORD1;
                float4 B : TEXCOORD2;
                float4 N : TEXCOORD3;
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
                // float flip = IN.tangentOS.w * unity_WorldTransformParams.w;
                float flip = IN.tangentOS.w;
                VertexNormalInputs nrm = GetVertexNormalInputs(IN.normalOS, IN.positionOS);
                float3x3 TBN = CreateTangentToWorld(nrm.normalWS, nrm.tangentWS, flip);
                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.T = float4(TBN[0], positionWS.x);
                OUT.B = float4(TBN[1], positionWS.y);
                OUT.N = float4(TBN[2], positionWS.z);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv0, _MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv0, _BumpMap);
                
                return OUT;
            }

            float4 frag (v2f IN) : SV_Target
            {
                half3 albedo  = SAMPLE_TEXTURE2D(_MainTex , sampler_MainTex , IN.uv.xy).rgb
                                * _ColorTint.rgb;

                
                float3 positonWS = float3(IN.T.w, IN.B.w, IN.N.w);
                float3 nrmFromNM = UnpackNormalScale(
                    SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, IN.uv.zw), _BumpScale);
                float3x3 TBN = float3x3(IN.T.xyz, IN.B.xyz, IN.N.xyz);
                float3 N = mul(TBN, nrmFromNM);
                Light mainlight = GetMainLight();
                float3 L = mainlight.direction;
                float3 V = GetWorldSpaceNormalizeViewDir(positonWS);
                float3 H = normalize(V + L);

                half  diff = saturate(dot(N, L));
                half  spec = pow(saturate(dot(N, H)), _Gloss);

                Light mainLight = GetMainLight();
                half3 color = albedo * diff * mainLight.color
                            + _Specular.rgb * spec * mainLight.color;

                return half4(positonWS, 1);
            }


            
            ENDHLSL
        }
    }
}