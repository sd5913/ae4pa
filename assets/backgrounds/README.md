# 五层走廊占位素材

floor_1.png 至 floor_5.png 来自用户提供的 hotel_floors_4k.zip，保留原始图像字节。具体生成工具／许可信息由成员补充。

五个实际楼层场景现已分别引用对应图片。floor_base.tscn 的 FloorBackground 为最先绘制的子节点，各层使用 AtlasTexture 取透明内容区域，按 0.9375 等比缩放到走廊宽 3600，图中地面线对齐主角脚底 y560。F5 序章结束后可看到 1F 占位背景，F6 floors_test.tscn 可逐层查看五层。

图片含静态人物、门扇和灯光状态。3F 缺 305，5F 缺 504／505，图中门位与现有交互坐标也有差异。正式素材接入需要拆动态层、补门号并校准交互和安全路线。独立 floor_art_preview.tscn 继续提供背景与接入点对照。运行方法见 [项目 README](../../README.md)。
