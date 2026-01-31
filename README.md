# my-solder项目的3D建模文件

这个仓库包含了My-Solder便携式烙铁项目的OpenSCAD建模文件。主要用于生成3d打印外壳。模型参数化设计，便于修改尺寸和形状。完整项目请参阅主仓库：[maoabc/my-solder](https://github.com/maoabc/my-solder)。

## 项目结构
- **scad文件**：核心建模脚本，例如烙铁主体外壳和顶部盖子以及按键帽等。
- 关键元素：
  - 依赖BOSL2库进行高级建模（如圆角、螺纹等）。
  - 参数在文件顶部注释中定义，可直接修改。

如果不需要自定义可以使用右边的releases直接下载生成的stl文件用于3d打印。
