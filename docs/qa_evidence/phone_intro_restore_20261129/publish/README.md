# PR #90 发布候选复核

2026-11-29，Windows / Godot `4.7.2.stable.official.ed1daf0bf`，新建且无 `.godot` 的工作树，基于 `main@9d8a09a`；运行改动为 `e8c31757245a76cb2a825a4f595f09be2fe2bb34`。保留背景音乐，排除另一工作树的人物放大 8%。后续提交只修订本地化测试退出清理、截图测试隔离和本证据，游戏运行代码与 e8c3175 相同，见 `runtime_sha256.json`。

## 结果

命令均带 `--path <发布工作树>`、独立 APPDATA。以下所有最终命令退出 0：

| 参数 | 日志 | 结果 |
| --- | --- | --- |
| `--headless --editor --import --quit` | `import.log` | 无缓存导入完成；Windows safe-save 诊断仍保留，未见脚本解析错误 |
| `--headless --script res://scenes/tests/ui/complete_dialogue_smoke.gd -- --ui-smoke` | `dialogue.log` | 194 段、23 表情、英文、原剧情接线与完成隔离 |
| `--headless --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | `intro.log` | 正式 main.tscn 的开始按钮、真实输入分发、经理／楼层门控和重开 |
| `--headless --script res://scenes/tests/core/localization_smoke.gd` | `localization_final.log` | 完整翻译断言；结束前释放主场景并等待四帧，无退出资源错误 |
| `--headless --script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke` | `full_escape.log` | 正常新局、八项真实任务、actual309 CG、最终 EXIT 断言全部保留并通过；203／205 TASK_INACTIVE 为测试预期诊断 |
| `--script res://scenes/tests/ui/phone_intro_review.gd` | `graphics_controlled.log` | Compatibility / RTX 3070 Laptop GPU，中英 × 960×540／1280×720／1920×1080，54 张实际截图；原摇晃、完整聊天、取消／重开和门控通过 |

已查看 [最终 54 状态总览](matrix.png)，与历史原窗口尺寸的通知、长气泡及接回 Carol 画面比较，未见新增裁切、气泡溢出或界面样式改变。本目录保存最终六种语言／尺寸的首条聊天及接回 Carol 原尺寸示例；完整 54 张保留于本次运行目录，其文件指纹记入 `capture_sha256.json`。

## 首轮失败与处理

- 首个 PR head 的 Windows 构建工作流（运行 46165817438）在 Linux 主机执行翻译检查时输出 PASS，但进程退出有「1 resources still in use」错误，严格检查按既有规则失败。修订仅让测试释放实际主场景并等待四帧后退出，保留全部内容、存档及状态断言，不放宽 CI 的错误检查。
- 发布候选最初图形矩阵复现额外推进，见 `graphics_initial.log`。临时诊断标记脚本输入 device=77 并跟踪调用栈：如 zh_CN_1280×720 的第 2101 帧脚本推进后，第 2102 帧又从没有测试 helper 的 `_input` 分发进入 `_advance`。见 `input_dispatch_trace.log`；额外事件具体类型未在该日志记录，不能据此声称游戏内部重复推进。
- 截图夹具现关闭该节点的自动输入接收，仍通过原 `_input` 方法注入键盘／指针事件并执行原全部断言；正式输入分发由独立 intro_flow_smoke 继续覆盖。显式 `RenderingServer.force_draw(false)` 避免隐藏验证窗口等待 `frame_post_draw` 停顿。临时诊断已从运行代码移除，复跑 54 张全部通过。

未新增真人连续试玩、存读迁移、跨平台实机或导出验收；远端导出与合并状态以 PR #90 最新 head 的 GitHub Actions 为准。历史证据和失败均保留。

2026-11-29 最终退出修订：详见 ci_audio_leak_excerpt.log。远端残留确认为旅馆背景音乐的 AudioStreamMP3／AudioStreamPlaybackMP3。固定四帧未保证音频线程已混音释放；现在以 WeakRef 观察停止后的播放实例，在一秒上限内等待并断言释放，不更改音乐播放或 CI 失败条件。本地无 --ui-smoke 的 localization_audio_release.log 退出 0。runtime_sha256.json 已更新对应测试文件散列；游戏运行代码仍为 e8c3175。