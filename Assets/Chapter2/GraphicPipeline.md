# 第二章：渲染流水线 (The Rendering Pipeline) —— URP 适配版

## 2.1 综述：从 RTR3 到 RTR4 的演变
在原书中，作者引用的是《Real-Time Rendering 3rd Edition》(RTR3) 的三阶段模型。为了适应 Unity URP 和现代 GPU 架构，我们采用《Real-Time Rendering 4th Edition》(RTR4) 的**四阶段模型**。

这一改变的核心在于：**将“光栅化”与“像素处理”剥离**。这对于理解 URP 的性能优化（如 Early-Z 和 Overdraw）至关重要。

### 核心流水平行阶段
1.  **应用阶段 (Application Stage)**：CPU 负责，驱动渲染。
2.  **几何阶段 (Geometry Stage)**：GPU 负责，处理顶点与多边形。
3.  **光栅化阶段 (Rasterization Stage)**：GPU 固定管线，决定像素覆盖。
4.  **像素处理阶段 (Pixel Processing Stage)**：GPU 负责，计算颜色与合并。

---

## 2.2 阶段一：应用阶段 (Application Stage) —— CPU 的主场

在 Built-in 管线中，这部分几乎是黑盒。但在 URP 中，开发者拥有极大的控制权。

* **1. 数据准备**：
    * 加载模型网格、纹理到显存。
    * **SRP Batcher (关键)**：将材质参数打包上传至 GPU 的 `UnityPerMaterial` 常量缓冲区 (CBuffer)。这也是为什么我们在写 Shader 时必须使用 `CBUFFER_START` 宏的原因。
* **2. 粗粒度剔除 (Culling)**：
    * Unity 自动处理视锥体剔除 (Frustum Culling)。
    * URP 允许通过 `Camera.cullingMask` 和代码干预剔除逻辑。
* **3. 渲染状态设置 (SetPass)**：
    * CPU 告诉 GPU：“接下来用这个 Shader，开启深度测试，关闭混合”。
    * SRP Batcher 的作用就是尽可能减少这一步的开销。
* **4. 发送 Draw Call**：
    * 命令 GPU 渲染图元列表。

---

## 2.3 阶段二：几何阶段 (Geometry Stage) —— 顶点的旅程

GPU 接收到数据后，首先处理的是顶点。

* **1. 顶点着色 (Vertex Shading)**：
    * **对应代码**：HLSL 中的 `#pragma vertex Vert` 函数。
    * **核心任务**：坐标变换。将顶点从 **模型空间 (Model Space)** 变换到 **齐次裁剪空间 (Homogeneous Clip Space)**。
    * **URP API**：使用 `TransformObjectToHClip(v.positionOS)` 替代旧的矩阵乘法。
* **2. 裁剪 (Clipping)**：
    * 将不在摄像机视野内的图元裁掉。
* **3. 屏幕映射 (Screen Mapping)**：
    * 将图元坐标转换到屏幕像素坐标系。

---

## 2.4 阶段三：光栅化阶段 (Rasterization Stage) —— 寻找像素

**注意**：此阶段是硬件固定的 (Fixed-Function)，不执行任何开发者编写的 Shader 代码。

* **1. 三角形设置 (Triangle Setup)**：
    * 计算三角形边界的方程。
* **2. 三角形遍历 (Triangle Traversal)**：
    * 检查屏幕上的每个像素中心是否被三角形覆盖。
    * **产物**：如果覆盖，生成一个 **片元 (Fragment)**。
* **3. Early-Z (提前深度测试)**：
    * *现代 GPU 优化*：在此阶段结束后，GPU 通常会通过 Z-Cull 或 Early-Z 技术，提前丢弃被遮挡的片元。这意味着这些片元**不会**进入繁重的像素处理阶段。

---

## 2.5 阶段四：像素处理阶段 (Pixel Processing Stage) —— 颜色的诞生

这是 Shader 开发者的主战场。

* **1. 像素着色 (Pixel Shading)**：
    * **对应代码**：HLSL 中的 `#pragma fragment Frag` 函数。
    * **核心任务**：纹理采样、PBR 光照计算 (调用 `Lighting.hlsl`)。
    * **数据流**：接收从几何阶段插值传来的数据 (UV, Normal)。
* **2. 合并 (Merging / ROP)**：
    * **测试**：深度测试 (Depth Test) 和 模板测试 (Stencil Test)。
    * **混合 (Blending)**：处理透明物体。
    * **写入**：将最终颜色写入 **帧缓冲区 (Frame Buffer)**。

