# 第一章：欢迎来到 Shader 的世界 (URP适配版)

## 1.1 程序员的三大浪漫与 URP
图形学依然是程序员的浪漫。在 URP 14 中，这种浪漫不仅是画面的绚丽，更包含了对**可编程管线 (SRP)** 的掌控力。我们不再仅仅是“填空”写 Shader，而是可以通过 C# 脚本控制整个渲染流程（Render Features）。

## 1.2 本书结构重构 (Roadmap)

为了适应 Unity 2022.3 + URP，我们将原书的学习路线进行了如下调整：

### **第一篇：基础篇 (原理通用)**
* **第2章 渲染流水线**：
    * *不变*：GPU 架构、光栅化、数学基础。
    * *变化*：理解 **SRP (Scriptable Render Pipeline)** 的工作流，SRP Batcher 如何改变了 Draw Call 的合并方式。
* **第3章 Unity Shader 基础**：
    * *变化*：从 `CGPROGRAM` 转向 `HLSLPROGRAM`。
    * *变化*：SubShader Tags 中必须包含 `"RenderPipeline" = "UniversalPipeline"`。
* **第4章 数学基础**：
    * *不变*：矩阵、向量、坐标系转换依然是核心。

### **第二篇：初级篇 (从 Unlit 到 PBR)**
* **第5-6章 基础光照**：
    * *重大变化*：**废弃 Surface Shader**。
    * *新路径*：学习编写 URP Unlit Shader 和 Simple Lit Shader。
    * *新路径*：理解 URP 的单次主光照 Pass (UniversalForward) 和多光源处理方式。
* **第7-8章 纹理与透明**：
    * *变化*：透明度混合（Blending）原理不变，但需要注意 URP 中的深度图（Depth Texture）和不透明度图（Opaque Texture）的获取方式有所改变

### **第三篇：中级篇 (光照与阴影)**
* **第9-11章 复杂光照与动画**：
    * *变化*：URP 中的阴影采样使用 `Shadows.hlsl` 库。
    * *变化*：光照衰减不再依赖纹理（Lookup Texture），而是计算公式。

### **第四篇：高级篇 (后处理与优化)**
* **第12-16章 屏幕特效与优化**：
    * *完全重写*：**废弃 `OnRenderImage`**。
    * *新机制*：使用 **Volume 框架** 和 **Scriptable Render Features** 编写后处理。
    * *优化*：利用 SRP Batcher 和 GPU Instancing。

### **第五篇：扩展篇 (SRP 定制)**
* **第17-20章 深入管线**：
    * *替换*：不再研究 Surface Shader 编译原理，转而研究 **URP 源码** 和 **Custom Render Pass**。