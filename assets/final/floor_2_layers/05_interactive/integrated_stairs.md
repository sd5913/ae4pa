# 二楼整体楼梯间（含栏杆）

当前二楼使用 `stairs_left_integrated.png` / `stairs_right_integrated.png`，每侧为一张887×1774真实Alpha PNG。台阶、扶手、竖栏、吊灯、拱门和黑框均在同图中，不含人物或楼层牌。

源图由内置imagegen分别生成，以原二楼入口为朝向／色彩参考，以一楼楼梯为栏杆一体化风格参考。左侧向右上方、右侧向左上方延伸，生成原文件完整保留且未缩小。实际提示词见 integrated_stairs_prompts.json，原画布、SHA、可见范围、缩放与落地校准见 integrated_stairs_manifest.json。

`floor_2_art.tscn` 的 Travel/LeftStairs、RightStairs 分别直接引用两张PNG，整个楼梯间z=0，玩家z=1，栏杆随楼梯在角色后方显示；旧 Foreground/LeftRail、RightRail 及其独立纹理引用已移除。原PNG保留备选，不再由当前场景使用。其他前景柱／绳栏层级保持。

以最下方金色踏步对齐源坐标y394／世界y560。两侧交互点仍为 ReturnPoint(192,560)、ExitPoint(3400,560)，玩家移动、楼层选择、任务门锁与其他交互脚本未修改。新PNG仅是背景，不增加碰撞或输入节点。

验证：Godot4.7.2导入通过；floor_2_layout_smoke检查一体PNG、删除独立栏杆、背景层级、左右通行、门三态与原坐标；floor_flow、world_interaction、task_01_main_flow均PASS。原生Compatibility左右截图目视检查，截图使用静止位置夹具，不代表右端剧情路线提前解锁。存在既有user://日志／shader缓存／编辑器设置保存诊断，无资源导入或脚本错误。

本次为本地C分支修改，未推送或合并main。
