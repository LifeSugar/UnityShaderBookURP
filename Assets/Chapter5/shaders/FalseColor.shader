Shader "Unity Shader Book/Chapter 5/False Color"
{
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
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            ZWrite On
            Cull Back
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //Core.hlsl中并不存在UnityCG.cginc中的appdata_full，也不建议这样做

            struct Attributes
            {
                float4 postionOS : POSITION;
                float4 tangent : TANGENT; //w分量为+1/-1，代表TBN坐标的手性
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 texcoord2 : TEXCOORD2;
                float4 texcoord3 : TEXCOORD3;
                float4 texcoord4 : TEXCOORD4;
                //略过567

                float4 color : COLOR0;
                
            };

            struct v2f
            {
                float4 positionHCS : SV_POSITION;
                float4 color : COLOR0;
            };

            v2f vert (Attributes IN)
            {
                v2f OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.postionOS.xyz);

                // //可视化法线方向
                // OUT.color = float4(IN.normal * 0.5 + float3(0.5, 0.5, 0.5), 1.0);
                // //可视化切线方向
                // OUT.color = float4(IN.tangent * 0.5 + float3(0.5, 0.5, 0.5), 1.0);
                // //可视化副切线方向
                // float3 bionormal = cross(IN.normal, IN.tangent.xyz) * IN.tangent.w;
                // OUT.color = float4(bionormal * 0.5 + float3(0.5, 0.5, 0.5), 1.0);
                
                // //可视化第一组纹理坐标
                // OUT.color = float4(IN.texcoord.xy, 0.0, 1.0);
                //可视化第一组纹理坐标的小数部分
                OUT.color = frac(IN.texcoord);
                if (any(saturate(IN.texcoord) - IN.texcoord))
                {
                    OUT.color = float4(0.0, 0.0, 0.0, 1.0);
                }
                OUT.color.a = 1.0;

                return OUT;
                
                
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 c = i.color;
                return c;
            }

            ENDHLSL
        }
    }
}