using UnityEditor;
using UnityEngine;
using UnityEditor.Rendering.Universal;

namespace ShaderBook.Chapter8
{
    public class URPBlendModeShaderGUI : ShaderGUI
    {
        MaterialEditor materialEditor;
        Material material;
        private MaterialProperty blendMode;
        private MaterialProperty surfaceType;
        private MaterialProperty baseColor;
        
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.materialEditor = materialEditor;
            this.material = materialEditor.target as Material;
            this.blendMode = FindProperty("_BlendMode", properties);
            this.surfaceType = FindProperty("_SurfaceType", properties);
            this.baseColor = FindProperty("_Color", properties);
            
            EditorGUI.BeginChangeCheck();
            var surf = (SurfaceType) this.surfaceType.floatValue;
            surf = (SurfaceType) EditorGUILayout.EnumPopup("Surface Type", surf);
            if (EditorGUI.EndChangeCheck())
            {
                materialEditor.RegisterPropertyChangeUndo("Surface Type");
                this.surfaceType.floatValue = (float) surf;
                SetSurfaceType(material, surf);
            }

            if (surf == SurfaceType.Transparent)
            {
                EditorGUI.indentLevel++;
                EditorGUI.BeginChangeCheck();
                var blend = (BlendMode) this.blendMode.floatValue;
                blend = (BlendMode) EditorGUILayout.EnumPopup("Blend Mode", blend);
                if (EditorGUI.EndChangeCheck())
                {
                    materialEditor.RegisterPropertyChangeUndo("Blend Mode");
                    this.blendMode.floatValue = (float) blend;
                    SetBlendMode(material, blend);
                }
                EditorGUI.indentLevel--;
            }
            
            materialEditor.RenderQueueField();
            materialEditor.ColorProperty(baseColor, "Base Color");
        }
        
        static void SetSurfaceType(Material material, SurfaceType surf, BlendMode blend = 0)
        {
            if (surf == SurfaceType.Opaque)
            {
                material.SetOverrideTag("RenderType", "Opaque");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
            }
            else if (surf == SurfaceType.Transparent)
            {
                material.SetOverrideTag("RenderType", "Transparent");
                SetBlendMode(material, blend);
                material.SetInt("_ZWrite", 1);
                
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
            }
        }

        static void SetBlendMode(Material material, BlendMode blend)
        {
            switch (blend)
            {
                case BlendMode.Normal: //正常
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    break;
                case BlendMode.SoftAdditive: //柔和相加
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusDstColor);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    break;
                case BlendMode.Multiply: //正片叠底
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    break;
                case BlendMode.Darken: //加深
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Min);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    break;
                case BlendMode.Lighten: //减淡
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Max);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    break;
                case BlendMode.Screen: //滤色
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcColor);
                    break;
                case BlendMode.Multiplyx2: //两倍相乘
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.SrcColor);
                    break;
                case BlendMode.LinearDodge: //线性减淡
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    break;
                default:
                    material.SetInt("_BlendOp", (int)UnityEngine.Rendering.BlendOp.Add);
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    break;
            }
        }
    }
    
    [System.Serializable]
    public enum BlendMode
    {
        NotSet= 0,
        Normal = 1, 
        SoftAdditive = 2,
        Multiply = 3,
        Darken = 4,
        Lighten = 5,
        Screen = 6,
        Multiplyx2 = 7,
        LinearDodge = 8,
        
    }
    [System.Serializable]
    public enum SurfaceType
    {
        Opaque = 0, 
        Transparent = 1, 
        TransparentCutout = 2, 
    }
}