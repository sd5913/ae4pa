# 一楼分层源文件

floor_1_layers.ora：OpenRaster，3840×548，含有名称的独立图层，可用 Krita / GIMP 编辑。

导出包及坐标见 ../../assets/final/floor_1_layers/README.md。prompts.json 保存本次实际使用的内置 imagegen 提示词。

## 再导出

安装 Python 3 和 Pillow 后，在仓库根目录运行：

```sh
python art_sources/floor_1/export_layers.py --output exported_floor_1
```

从 ORA 图层直接导出 43 张游戏 PNG 和重组预览；不依赖 AI 服务、原扁平图或本机路径。光效母版另存在默认隐藏的 reusable_masters 组；可见光效实例可各自编辑。共 61 个图层，七个层栈对应五类逻辑层。验证见 validation.json；未实际打开 Krita / GIMP GUI。
