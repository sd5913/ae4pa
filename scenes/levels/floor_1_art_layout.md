# 一楼：用独立生成的高清资产按参考图布局组装

当前实际场景为 `floor_1.tscn` → `floor_1_art.tscn`，全部 Sprite 引用 `assets/final/floor_1_layers/hd_generated/`。**原图只提供布局坐标，不提供运行时像素。** 不再使用此前的原图裁片 `reference_aligned`，也不使用旧整张 floor_1 背景。

## 清晰度与来源

- 32 张此前独立生成原文件完整保留；补齐高清横梁、细黑柱、紫色远景、地毯，并局部修复已有高清楼梯底部缺口，合计 37 PNG（其中未修复楼梯原稿保留备份，实际使用 36 张不同纹理、67 个独立 Sprite）。
- PNG 文件与选定 imagegen 原文件逐字节一致，保留各自完整高清画布，没有先缩到原图裁片尺寸再放大。比如独立家具原文件多为约 1000—2200 像素。透明背景保持真实 Alpha；远景为完整不透明面板。
- 3840×548 仅是布局坐标系。场景中的 region_rect 明确选择物件可见范围，scale 决定显示尺寸；PNG 本体和导入画布不改变。贴图无损、size_limit=0、无 mipmaps，使用 linear 采样。
- 再次确认：这里的“按原图”指区域、家具、屋顶、柱子的位置与占用范围；独立生成素材自身的造型、雕花、窗框和纹样保留，不追求原图像素一致。

## 场景层级

FarSky / Architecture / Floor / ContactShadows / BackFurniture / Lighting / Foreground。补齐连续黑屋顶、完整柱头柱脚、两端天空、地面支撑和楼梯缺口。横梁、地毯的重复单元通过明确的内部区域衔接，避免外沿造成黑缝。

整体沿用 `(0,106.25)`、缩放 `0.9375`、3600 宽走廊及脚底 `y=560`。玩家和员工 z=1，Foreground z=2，交互提示 z=3。

| 指定前景柱 | 布局中心 X | 游戏中心 X | 行为 |
|---|---:|---:|---|
| 休息区 ↔ 保洁间 lounge_utility_column | 2768 | 2595 | 遮挡角色、无碰撞、左右可穿过 |
| 保洁间 ↔ 楼梯 utility_stairs_column | 3374 | 3163.125 | 遮挡角色、无碰撞、左右可穿过 |

Art 内只有 Node2D / Sprite2D / Polygon2D，没有脚本、Control、Area2D 或碰撞体。保安800、保洁1600、经理2400、出生192、上楼3400及 y560 坐标保留；Player、Staff、GameManager、CardManager、floor.gd 和 main 源码未改变。静态画中人物不入布景，实际游戏角色继续参与交互。

## 可编辑源文件

`art_sources/floor_1/floor_1_generated_hd.ora` 是 7680×1096、67 图层的整体布景源文件，可用 Krita/GIMP 编辑。原始高清 PNG 则在 hd_generated 中完整保留，游戏直接引用它们；游戏不会加载整体预览或 ORA 烘焙图。提示词、原文件 SHA、区域和缩放见对应 JSON。旧的 ORA／reference_aligned 仅保留历史备选，不是当前运行资源。

## 实际验证

- FLOOR_1_HD_FULL_SIZE：Godot 4.7.2 实际加载全部37纹理，尺寸与生成原文件一致，PASS。
- floor_1_art_smoke：所有 Sprite 路径均属于 hd_generated、两柱有真实遮挡且能双向实际移动穿过、真实经理 E／对白完成／楼梯 E，PASS。
- world_interaction_smoke（真实保洁偷卡、唯一 E、模态取消、楼层回访）、task_01_main_flow_smoke、foundation_smoke 均 PASS。序章有显式测试夹具，不代记真人完整游玩。
- Compatibility 实际渲染整层、7200×1440 高分辨率整层及两柱显示／隐藏对照；37 原 PNG 字节和尺寸核对、导入设置、ORA 重组检查通过。
- 环境仍有既有 user:// 日志、shader 缓存和编辑器设置保存诊断；无资源导入／脚本错误。未用 Krita/GIMP GUI 验证源文件。

本轮本地 C 分支修正，尚未提交／推送／合并 main。
