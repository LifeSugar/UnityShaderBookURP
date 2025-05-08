#ifndef BLINNPHONG_HLSL
#define BLINNPHONG_HLSL


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 PhongDiffuse(float3 normalWS, float3 diffuseColor)
{
    Light main_light = GetMainLight();
    float3 main_light_color = main_light.color;
    float3 main_light_direction = main_light.direction;

    float3 diffuse;
    diffuse = diffuseColor * main_light_color * saturate(dot(normalWS, main_light_direction));
    return diffuse;
}

float3 HalfLambertDiffuse(float3 normalWS, float3 diffuseColor)
{
    Light main_light = GetMainLight();
    float3 main_light_color = main_light.color;
    float3 main_light_direction = main_light.direction;

    float3 diffuse;
    diffuse = diffuseColor * main_light_color * (0.5 * dot(normalWS, main_light_direction) + 0.5);
    return diffuse;
}

float3 PhongSpecular(float3 normalWS,float3 positionWS, float3 specularColor, float gloss)
{
    Light main_light = GetMainLight();
    float3 main_light_direction = main_light.direction;

    float3 v = normalize(_WorldSpaceCameraPos - positionWS );
    float3 r = -reflect(v, normalWS); //注意 - 
    float3 specular = specularColor * pow(saturate(dot(r, main_light_direction)), gloss);
    return specular;
}

float3 BlinnPhongSpecular(float3 normalWS, float3 positionWS, float3 specularColor, float gloss)
{
    Light main_light = GetMainLight();
    float3 main_light_direction = main_light.direction;

    float3 v = normalize(_WorldSpaceCameraPos - positionWS );
    float3 h = normalize(v + main_light_direction);
    float3 specular = specularColor * pow(saturate(dot(normalWS, h)), gloss);
    return specular;
}

#endif