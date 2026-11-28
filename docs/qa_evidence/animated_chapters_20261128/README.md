# 已确认动效报幕接入 · 2026-11-28

基线 `bcf13b1`，分支 `work/animated-chapter-cards-20261128`，本次为未提交本地改动。获取远端 `main` 后确认仍为该基线。保留原有 `dialogue.gd` 的人物放大 8% 及三份文档中的原交接；没有提交、推送、合并或导出游戏。

## 改动

- 原五处报幕统一替换为用户确认的棕金纸纹、衬线标题、暗色英文、圆环羽毛和菱形；新增第六处「终章／共赴长夜」。
- 罩层用屏幕采样材质将下层原场景转成低对比棕色纸纹。没有使用设计预览中生成的场景图替换游戏背景；309 的原无人背景与 CG 交叉淡入保留。
- 入场 2.8 秒：罩层淡入，章节浮现，细线展开，圆环羽毛与标题显现，继续提示出现并轻微呼吸。点击/E 后文字先淡出、罩层随后淡出，总计 0.85 秒。
- 原跳过按钮不属于报幕层，报幕期间隐藏，回到原剧情后按原已读条件恢复。长英文标题的两侧菱形外移，避免相压。
- `LATE_ENDING` 的首拍之前显示终章；关闭只显示首句，不消费首句或提前记录历史。实际 EXIT 资格、WON、救援完成和任务数据仍沿用宿主；取消不等于完成。
- 中英六页文字预渲染为透明 PNG，不携带系统字体文件；原旧 `present(heading, location)` 签名仍兼容，正式入口传稳定的可选素材 ID。新增两条英文翻译。

## 验证方法与结果

Windows，Godot `4.7.2.stable.official.ed1daf0bf`。将 `git archive HEAD` 解到当前聊天的 `work/runtime_verify`，覆盖本次生产代码、原有立绘尺寸增量和新正式素材，不复制 `.godot`。先干净导入，退出 0，然后运行以下命令（每项独立 APPDATA，日志绝对路径）。

| 检查 | 命令 | 结果 |
| --- | --- | --- |
| 干净导入 | `godot --headless --path . --editor --import --quit` | 0，最终无脚本解析错误 |
| F5 主入口与底座 | `godot --headless --path . --script res://scenes/tests/core/foundation_smoke.gd` | 0 |
| 原开场与模态 | `godot --headless --path . --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | 0 |
| 本地化 | `godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --ui-smoke` | 0 |
| 完整新局至 EXIT | `godot --headless --path . --script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke` | 0，保留八任务、真实 309 和原最终 EXIT 断言 |
| 实际报幕／旁白画面 | `godot --path . --script res://scenes/tests/ui/chapter_narration_review.gd` | 0，最终 `CHAPTER_NARRATION: PASS; 84 captures` |

图形检查为 NVIDIA RTX 3070 Laptop GPU／OpenGL 3.3 Compatibility。不带 `--ui-smoke`，实际等入场、鼠标／E 退场、验证首句不被吞、取消清理。覆盖中文／英文 × 960×540、1280×720、1920×1080，六处报幕及八种旁白共 84 张。逐图校验实际尺寸及已有文字边界，查看全部六张汇总图和长标题原尺寸截图。最终未见截字、标题与装饰重叠、报幕时人物或跳过按钮残留。

完整主线中的 `--ui-smoke` 快速路径不证明动效节奏，因此门控与新终章另由上述实际图形夹具覆盖。首次检查发现英文长标题与菱形接近，修正后重跑完整图形矩阵。首次受沙箱影响的导入曾出现 safe-save 错误；换为允许本地文件保存的验证进程后，干净导入退出 0。主线日志保留原 203／205 `TASK_INACTIVE` 测试诊断，本次最终仍 PASS。

实际工程的新增资源导入另以 headless editor 执行并退出 0，见 `source_import.log`；运行文件与验证副本逐字节一致。

完整 84 张 PNG 保存在本机当前聊天 `work/runtime_captures`；此目录保留六张尺寸／语言汇总、代表性原尺寸报幕、实际日志和生产文件指纹。源码／素材一致性按 `source_sha256.json` 核对。

未测：真人连续通关、macOS／另一设备、Windows 导出包及专项存读档。没有把自动化或图形夹具结果记为真人试玩。
