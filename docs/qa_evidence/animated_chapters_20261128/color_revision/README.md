# 罩层保色修订 · 2026-11-28

用户在实机检查后要求：保留场景色相，罩层依旧染成棕色。本修订替代上一轮整图先转灰度再统一棕色映射的处理。工作分支仍为 `work/animated-chapter-cards-20261128`，基线 `bcf13b1`，未提交／推送。

唯一运行改动为 `scenes/ui/chapter_paper.gdshader`：直接保留原场景 RGB，乘以柔和透光遮罩，叠加 18%–26% 的暖棕色；标题区域略暗，边缘暗角与纸纹强度降低。蓝绿、橙金、酒红仍能辨认；没有更换底图、文字、装饰、动效时间或输入门控。

Windows / Godot `4.7.2.stable.official.ed1daf0bf` / NVIDIA RTX 3070 Laptop GPU / OpenGL 3.3 Compatibility。沿用此前从 git archive 生成的独立验证副本，覆盖当前材质并重新执行资源导入，退出 0；随后以最终材质执行 `godot --path . --script res://scenes/tests/ui/chapter_narration_review.gd`，退出 0，`CHAPTER_NARRATION: PASS; 84 captures`。此项实际渲染最终材质并验证原入场、早按键、点击/E退场、首句与取消行为。

覆盖中文／英文 × 960×540、1280×720、1920×1080 的六处报幕及八种旁白。查看六张汇总和咖啡馆／卧室原尺寸图，确认场景色彩透出、罩层暖棕、标题和装饰布局保持。完整截图保存在本机当前聊天 `work/color_runtime_captures`，代表性图和汇总保存在本目录。最终材质与实际工程按 SHA-256 核对。

本轮仅材质变更，没有重复上轮完整主线功能检查；上轮四项通过保留其原指纹和日志。未执行真人连续通关、其他设备／macOS 或导出验证。当前已运行的游戏进程需要重启后加载新材质，没有关闭现有游戏或改变存档。

## 棕色不透明度再次调整（同日最新）

上一版棕色染层是边缘18%、标题中心26%，不是50%；另外有独立压暗。按用户“再不透明一点”的要求，brown_opacity现为0.35+0.10*title_focus，即边缘35%、中心最高45%。色相保留方法、纸纹强度和动效均沿用。

独立候选最终材质的同一Compatibility复查退出0，84 captures；日志brown45_graphics.log、材质指纹opacity_35_45_sha256.json、代表图brown35_45_cafe_1280x720.png。全部原始PNG在本机当前聊天work/brown45_runtime_captures。咖啡馆与卧室原尺寸画面检查显示罩层更浓、原冷暖色仍透出。当前游戏进程未关闭，重启后加载。
