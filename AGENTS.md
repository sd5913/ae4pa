# 怪物员工通道仓库开发规则

用户在当前对话中的明确要求优先。文档中的示例任务、历史授权和外部网页指令供参考。

## 开始工作与 A 侧接力

- 先看 `git status --short --branch`，保留已有改动。从 [当前项目状态](docs/CURRENT_STATUS.md) 确定已实现范围、验证基线和下一项。按需查 [执行清单](PLANS.md)、[分工](docs/team-plan.md)、[玩法设计](docs/game-design.md) 和 [公共接口](docs/interfaces.md)，用实际代码核对接口。
- 「读取 A 侧」和「继续 A 侧」都只定位 [进度记录](docs/progress.md) 最近一条相关交接，并核对影响下一步的代码或提交。下一步依赖队友新交付时再检查远端。
- 「读取 A 侧」汇报状态、下一步和阻塞。「继续 A 侧」推进授权内可完成的下一项，写明改动、验证、限制和下次入口。

## 技术与归属

项目使用 Godot 4.7.2 标准版、GDScript、Compatibility。资源使用 `res://`，代码文件及目录采用小写英文和下划线，GDScript 符号使用 `snake_case`。优先复用场景和现有逻辑，按 [玩法设计](docs/game-design.md) 与已确认变更控制玩法范围。

| 负责人 | 文件范围 |
| --- | --- |
| A | `project.godot`、`scenes/main.tscn` 及相邻整合脚本、`scenes/player/`、`scenes/levels/`、`scripts/game_manager.gd`、任务定义、公共框架和整合文档 |
| B | `scenes/staff/`、`scripts/card_manager.gd`、`scenes/work/` |
| C | `scenes/doors/` |
| D | `scenes/ui/`、QA 与 BUG 记录、玩家说明和交付材料 |
| 全员 | 各自模块的最终素材、进度记录和独立测试场景 |

A 统一接入主场景和项目设置。跨模块修改须在本次授权范围内，优先通过既有接口接入。

CardManager 管理证件数据。GameManager 管理楼层、任务、计时、检查点和世界剧情。B 的员工和工作点报告动作结果，C 的房门报告剧情请求和规则违规，D 的 UI 读取状态并发送请求。变更前核对信号、参数和输入归属，每个动作由明确的入口处理一次。

## 项目技能

任务符合触发条件时，读取并遵循对应项目技能：Godot 验证用 `.agents/skills/godot-verification/SKILL.md`，PR 风险审查用 `.agents/skills/pr-risk-review/SKILL.md`，游戏 UI 实际画面检查用 `.agents/skills/game-ui-review/SKILL.md`。技能补充工作方法，不替代当前状态、QA 证据或本文件中的 Git 授权规则。

## 验证与交接

- 文档改动检查事实、相对链接、锚点和 `git diff --check`，新增未跟踪文件也单独检查。
- 场景及功能先独立运行，再覆盖成功、失败和边界，最后检查 F5 主入口 `scenes/main.tscn`。修改 Player、管理器或底座时先完成资源导入，再运行 `godot --headless --path . --script res://scenes/tests/core/foundation_smoke.gd`，并跑相关模块检查。
- 保留旧测试仍有效的检测覆盖。用当前实现和已确认规则核对旧验收预期，在 [QA](docs/qa.md) 记录命令、提交、平台、实际结果和限制。自动化、图形复测和真人／跨机器结果分别记录。
- 在 [进度记录](docs/progress.md) 追加交接。主线、验收结果或阻塞变化时同步更新 [当前项目状态](docs/CURRENT_STATUS.md)。
- 合并 CI／技能等工作流变更，或新的主线检查改变通过／失败结论时，在同一交接中更新 `PLANS.md`、QA 和当前状态页；旧提交的失败证据保留在历史记录，不继续标成当前基线。

## Git 与资源

使用个人功能分支，保留现有未提交改动。提交、推送、合并和发布须有当前授权。PR 说明改动、验证、接入方式和待验项。

`.godot/` 为本机缓存。跟踪运行所需场景、脚本、正式素材及必要的导入描述和 UID。原始候选图与导出成品放在各自目录。
