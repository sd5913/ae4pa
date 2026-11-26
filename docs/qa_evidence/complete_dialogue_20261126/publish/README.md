# 发布候选复核 · 2026-11-26

用户明确授权同步 main、提交、推送并合入 main。已抓取远端；远端 main 为 `4ae5577b2e6455372366b21e21a12b08fb0d96a7`，与开发基线相同，`git merge --ff-only origin/main` 返回 Already up to date，无合并冲突。

审查范围：上述基线至 `c895c0a3e3d566e1127d98c6c01cf6ef198a58dc`，199 个变更文件，包括23张人物原图及导入描述、170段完整清单、正式场景接线、表情解析、英文、本次及历史QA证据。检查了A/D跨模块调用、任务模态交接、输入释放、CG单次救援、真实EXIT后结尾、未标立绘的旁白、存读重试、导出include及UID。未发现有证据支持的阻断缺陷。Windows导出包校验脚本补充检查新增的第四份运行时剧情JSON；工作流YAML未改变。

在独立的干净 detached worktree 检出 `c895c0a` 后，以 Windows Godot `4.7.2.stable.official.ed1daf0bf` 重新导入，完成后逐项运行：

| 命令（均带独立 APPDATA 及绝对 --log-file） | 退出码 |
| --- | --- |
| `godot --headless --path . --editor --import --quit` | 0 |
| `godot --headless --path . --script res://scenes/tests/ui/complete_dialogue_smoke.gd -- --ui-smoke` | 0 |
| `godot --headless --path . --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | 0 |
| `godot --headless --path . --script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke` | 0 |

日志和[结果](results.json)保存在本目录。[Git提交内容指纹](commit_manifest.json)按提交对象计算，避免Windows文本换行转换造成误判。干净检出确认28张人物及怪物图的SHA-256与用户来源一致，原始txt按字节一致，170段JSON语义与开发工作区一致。原始txt通过精确的`.gitattributes`规则保留换行和空白；源码及导入日志的`git diff --check`通过。未提交的457个既有导入描述/无关UID保留在原工作区，未加入本次提交。

最初试跑早于干净导入完成而缺少`.ctex`缓存，已停止；等待导入退出0后重新运行三项检查均通过，初始日志保留为`before_import_complete_*.log`。既有Windows编辑器safe-save与203/205 TASK_INACTIVE诊断不改变最终通过结论。

前次中英三尺寸、全部23种表情/5怪物、309CG、真实窗口输入及跨进程存读证据见[接入验证](../README.md)，本轮没有修改其运行时代码或原图。真人连续试玩、macOS和导出包实机验收仍未验证；GitHub CI及最终合并状态以合并请求记录为准。
