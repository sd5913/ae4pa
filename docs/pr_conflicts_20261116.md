# PR #22／#24 冲突处理检查

2026-11-16，Asia/Hong_Kong。此次为冲突专项检查；没有修改远端 PR、提交、推送或合入 main。保留 A 工作区已有修改，合并重放和运行验证均在临时克隆进行。

## 当前版本与结论

| 对象 | 本轮 fetch 后版本 | 实际重放结果 |
|---|---|---|
| main | `158818c74d334cf19e2f44d8010666be4bfc611f` | 已包含 #23 的任务 UI、#28 的 201 主入口修复、#29 的对白布局及救援立绘 |
| [PR #24](https://github.com/sd5913/ae4pa/pull/24) | `7af4af1483f2ebca2848822f286e0785cfc97513` | 仅 `docs/progress.md` 冲突；代码自动合并 |
| [PR #22](https://github.com/sd5913/ae4pa/pull/22) | `eb39714d19d6568ca519155f768899e02e5a7804` | 14 个文件冲突；旧对白及任务面板不能覆盖 main |

建议先解决 #24 的进度记录冲突，再处理 #22。两者都是各自分支与 main 冲突，不代表 B 与 D 的全部代码互相冲突。#24 已获批准仍会被冲突阻挡，批准不会自动解决冲突。

## #24：双方记录都保留

冲突发生在文件末尾：B 分支追加了“B-V4-04／05 工作交互与巡房文件交付”和“B→D 统一交互进度接口”；main 追加了 C 的门素材、二楼布景及 201 修复记录。

保留完整 C 记录和两个 B 记录，删除 `<<<<<<<`、`=======`、`>>>>>>>` 三类标记。不要整份选 B 或 main；也不要修改历史验证结论。

GitHub 上可打开 #24 的 Resolve conflicts，手动保留两侧段落，Mark as resolved，再 Commit merge。这一步更新 PR 的来源分支；最后的 Merge pull request 才是合入 main。本轮未执行这些远端操作。

本轮已在临时克隆实际解决这一处冲突，保留 main 原顺序并追加 B 两段；未解决文件数为零。相对最新 main，候选仍只有原 PR 的 12 个改动文件、712 行新增／12 行删除，未额外改游戏代码。

## #22：按功能合并 14 个冲突文件

| 冲突文件 | 修改方式 |
|---|---|
| `scenes/ui/dialogue.gd`、`dialogue.tscn`、`dialogue.gd.uid` | 三件套保留最新 main。#29 已加入新版布局和救援立绘；无需为保留立绘换回旧对白。 |
| `scenes/ui/mission_board.gd` | 以 main 为基础，保留模态登记、停表、输入保护、换层前隐藏／拒绝后恢复、按钮校验及楼层刷新；将 PR 主题单独加入。 |
| `scenes/ui/failure.gd`、`failure.tscn` | 保留 main 的模态与现有接口行为，合入需要的样式；检查控件路径。不能把 A 候选的重试适配写成共享 main 已实现。 |
| `scenes/ui/hud.gd`、`hud.tscn` | 保留 main 从 GameManager 读取真实任务／时间的逻辑，合入 CardDisplay、主题并核对布局。 |
| `scenes/tests/ui/ui_test.gd`、`ui_test.tscn`、`ui_test.gd.uid` | 保留 main 的输入锁定、换层拒绝后恢复、HUD 和按钮断言，再加入新组件检查；脚本、场景和 UID 一致。 |
| `README.md`、`docs/progress.md`、`docs/qa.md` | 当前说明以最新 V4 为准，历史记录与实际测试证据保留双方；不能用旧 PR 的整份文档覆盖。 |

“Current／Incoming”随合并方向变化，必须按明确的 main／D 分支内容判断。本轮临时克隆是在 D 分支上 merge main，因此 main 对应 incoming；这不是所有操作场景的通用标签。

### 必须避免的功能回退

1. **高：旧对白不支持 V4 主入口。** #22 `dialogue.gd:55` 的入口只接受 `INTRO`、`RESCUE_309`；最新 main 主入口调用 `V4_INTRO`、`V4_MANAGER_TALK` 并先锁定故事模态。整份采用旧对白会无对白且无法继续。最新 main 已有 V4 TSV、对应节点和 UID，作为整体保留。静态证据明确，置信度 10/10。
2. **高：旧任务面板缺停表与输入保护。** #22 `mission_board.gd:143` 直接请求换层，缺少 main 的 visibility_changed→set_modal_open，以及换层前关闭／拒绝后恢复流程。旧版会丢失保护；只补模态而不合入换层流程又会被世界输入校验拒绝。以 main 行为为基础加入主题。静态证据明确，置信度 10/10。
3. **中：新增玩家材料沿用 V3。** `docs/player-guide.md:27` 要求 1F 偷齐三卡；`docs/room-monster-table.md:15` 起把 201／202／204／205 写成 EYE／NOSE／HAT／CHECKER。应改为 NOSE／EYE／CHECKER／HAT，经理交谈后即可上楼，卡片按任务取得。顺带核对录屏清单和帮助页是否仍沿用旧流程。静态证据明确，置信度 10/10。

### 已被取代与仍有价值的内容

`friend_expressions.png` 及 `.import` 在 #22 与最新 main 中逐 blob 相同。main `dialogue.gd` 的 RESCUE_309 已调用 `_display_portrait("闺蜜", "relieved")`，由 #29 实现。

main 尚无 #22 的 bag、help、main_menu、win、CardDisplay、staff_ui_theme 组件，因此不建议仅因对白重复就把整个 #22 当作无用。可继续在 D 分支处理冲突，收敛成这些剩余组件、样式和更新后的 V4 说明；不要将旧对白重新带回。

## 实际验证与范围

Godot 实际版本 `4.7.2.stable.official.ed1daf0bf`。验证对象为 **#24 + main 158818c + 保留双方记录的冲突处理候选**，不是 A 当前工作区，也不是 #22 的修复候选。

首次运行 `--headless --editor --path <候选> --import --quit` 完成资源及全局类型扫描。随后使用 `--headless --path <候选> --max-fps 120 --log-file <独立临时日志>` 加以下入口，六项均退出 0：

| 入口 | 实际结果 |
|---|---|
| `scenes/tests/staff/work_items_smoke.tscn` | PASS：PICKUP／AUTHORIZE、一次性／恢复、PATROL_RECORD、只读进度 |
| `scenes/tests/staff/staff_core_smoke.tscn` | PASS：员工／卡片、输入、信号及边界 |
| `scenes/tests/staff/cleaner_v4_smoke.tscn` | PASS：偷卡资格、快照、201 清理与一次性结果 |
| `--script res://scenes/tests/core/foundation_smoke.gd` | PASS |
| `--script res://scenes/tests/core/world_interaction_smoke.gd` | PASS |
| `--script res://scenes/tests/core/task_01_main_flow_smoke.gd` | TASK_01_MAIN_FLOW: PASS |

结果与日志索引：`/private/tmp/ae4pa-pr24-merge-results.json`；进度冲突处理补丁：`/private/tmp/ae4pa-pr24-progress-resolution.patch`。临时克隆路径索引为 `/private/tmp/ae4pa-pr22-conflict-path`、`/private/tmp/ae4pa-pr24-conflict-path`。

headless 存在既有 macOS 系统证书诊断，编辑器导入存在用户设置目录保存受限诊断。没有将自动测试代记真人试玩或 Windows 验收。#22 本轮仅核对冲突及回退风险，没有生成完整修复候选或重跑其 F5；修复后仍需验证序章、经理、任务页停表和全部新增 UI。

独立同宿主 adversarial 子代理复核了以上冲突策略；测试／夹具仅按变更摘要读取，其结论不是独立运行证据。此次不构成两个 PR 的完整代码审计；Gate edits: partial，#22 已定位需保留的保护性测试，未执行完整自动 gate 扫描。

## 给 D 的处理说明

```text
请在自己的干净工作区，把最新 main 合进 work/member-D-caizhichun，修复 PR #22 的 14 个冲突。不要整批选 Current 或 Incoming。
dialogue.gd／tscn／uid 保留 main（已含 #29 新布局和救援立绘）；mission_board 保留 main 的模态停表、输入保护、换层隐藏及拒绝恢复，再加主题。HUD／failure 保留真实数据和模态逻辑，再合样式。ui_test 保留 main 的保护断言并补新组件。
保留 bag／help／main_menu／win／CardDisplay 等剩余增量；玩家说明和房号表按 V4 修订：201 NOSE、202 EYE、204 CHECKER、205 HAT，经理交谈后上楼，卡随任务取得。progress／QA 保留双方真实记录。
修复后运行 UI 独立检查、foundation、intro_flow、task_01_main_flow、world_interaction，并实际检查 F5 序章／经理／任务页停表，给出实际结果后再审。
```
