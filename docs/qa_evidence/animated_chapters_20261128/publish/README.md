# 报幕发布候选复核 · 2026-11-28

当前用户已明确授权本次报幕改动 commit、push 并合入 main。基线和最新远端 main 均为 `bcf13b15dc0874d9509cf7b97d74f29f05aeddf1`，发布分支 `work/animated-chapter-cards-20261128`。最终远端状态以 PR 为准。

## 提交范围与复核

只包含六处报幕代码、正式中英文透明素材、纸纹材质、测试与证据。未提交的 Carol/Terese/经理放大 8% 增量、其独立 QA、员工重绘、终章候选 CG 和其他历史导入文件仍保留在本机工作区，不属于此候选。较早的本地验证记录含人物尺寸增量；本次已将该增量从独立验证副本移除，再验证下面的确切发布候选。

最终罩层保留场景 RGB，暖棕染层边缘 35%、中心最高 45%。入场 2.8 秒、点击/E 后退场 0.85 秒，原五处替换并新增「终章 · 共赴长夜」。不替换真实场景底图，不新增报幕跳过按钮，不改变救援/EXIT结算、任务和存档数据。

按项目 PR 风险审查技能核对了暂存代码、17份正式纹理导入描述、Shader UID、12份双语文字图集、共用装饰/提示/纸纹、翻译、测试与交接。调用链仍由 Dialogue / Reunion 宿主管理输入、历史与完成；可选 card_id 不破坏原 present(heading, location) 调用。没有发现本轮范围内可复现的阻断问题。Windows实机/跨设备/导出范围仍见下方限制。

## 发布候选验证

沿用最初由 git archive 构建且干净导入的独立 `runtime_verify`，替换为暂存区确切代码（已移除人物尺寸增量），四项功能和实际图形复测全部退出 0。运行文件指纹见 `runtime_sha256.json`。

环境：Windows，Godot `4.7.2.stable.official.ed1daf0bf`；图形为 NVIDIA RTX 3070 Laptop GPU，OpenGL 3.3 Compatibility。每项单独 APPDATA。

| 命令（省略 --path 与绝对日志参数） | 结果 |
| --- | --- |
| `godot --headless --script res://scenes/tests/core/foundation_smoke.gd` | 0，正式 main 底座 |
| `godot --headless --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | 0，开场、模态和输入 |
| `godot --headless --script res://scenes/tests/core/localization_smoke.gd -- --ui-smoke` | 0 |
| `godot --headless --script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke` | 0，八项真实任务、309和原 EXIT 断言保留 |
| `godot --script res://scenes/tests/ui/chapter_narration_review.gd` | 0，中英三尺寸84幅，实际入退场、首句保护和取消 |

日志为 `release_*.log`，清除行尾空白以便 diff 检查；未删改诊断内容。203/205的既有 TASK_INACTIVE诊断保留，完整路线仍PASS。没有重复宣称真人通关、macOS或导出验收；本次未运行这些项目。PR远端CI另行观察。
