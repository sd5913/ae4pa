# PR #22 审查记录

2026-11-15，Asia/Shanghai。审查对象为 [PR #22](https://github.com/sd5913/ae4pa/pull/22)，D 分支 `work/member-D-caizhichun`，提交 `eb39714d19d6568ca519155f768899e02e5a7804`。当前 main 为 `007437a`，已包含较新的 D M1 UI PR #23。

结论为请求修改。GitHub 当前显示 CONFLICTING／DIRTY，实际重放合并产生 14 个冲突文件，46 个 PR 改动文件。当前没有自动 CI 检查记录。合并前需要保留 V4 主入口与模态保护，修正过时说明，并在合并候选上运行检查。

## 上传检查

A 的 56 个整合文件已全部存在于远端 `work/member-A-liuling` 的 `ef8a2f7`，本地逐字节核对一致。本地与该远端分支无领先或落后提交。

| 本地剩余内容 | 核对结果 |
|---|---|
| AGENTS.md | 仅增加 A 接力阅读规则，不是 B/C/D 的运行接口 |
| project.godot | 仅删除显式 stretch/aspect=keep 行，已发布入口与输入映射齐全 |
| .vscode/settings.json | 指向本机 Godot 路径的编辑器配置 |
| hotel_floors_4k.zip | 五张图片与已跟踪的 assets/backgrounds/floor_1.png 至 floor_5.png 哈希一致 |

未发现 B/C/D 必需的游戏源码遗漏上传。协作版本的缺口是 A 整合仍在个人分支，尚未进入 main；当前开放 PR 列表中没有 A → main 的 PR。队友应先明确使用 A 候选，后续将 A 与最新 main 整合并审查后再共享主线版本。

## 需要修正的内容

### P1 旧对白不接受主入口使用的 V4 ID

PR 的 dialogue.gd 只接受 INTRO 和 RESCUE_309。现有主入口会请求 V4_INTRO 和 V4_MANAGER_TALK。保留旧脚本会让 show_dialogue 静默返回，A 的故事模态仍保持打开，玩家进入无对白且不能操作的状态。当前 main 的 V4 对白脚本、场景与 UID 应作为一组保留，救援立绘变化应单独适配到这个版本。

[PR 对白入口第 55 行](https://github.com/sd5913/ae4pa/blob/eb39714d19d6568ca519155f768899e02e5a7804/scenes/ui/dialogue.gd#L55)

### P1 旧任务面板缺失停表和世界输入保护

PR 版本缺少 main 已有的 visibility_changed 模态登记，且直接在面板可见时请求换层。实测采用这份旧实现后，面板打开仍允许世界输入，手动推进一秒会从 210 扣到 209。

应保留 main 的模态登记、换层前隐藏／拒绝后恢复、楼层刷新与按钮校验，合入 D 的主题和确实新增的表现。只补模态登记而保留旧换层调用，会因 A 的世界输入校验而导致换层被拒绝。

[PR 面板实现](https://github.com/sd5913/ae4pa/blob/eb39714d19d6568ca519155f768899e02e5a7804/scenes/ui/mission_board.gd#L15)

### P2 玩家说明与门表沿用 V3

新玩家说明仍要求 1F 偷齐三卡，房号表把 201 标为 EYE、202 标为 NOSE、204 标为 HAT、205 标为 CHECKER。当前 V4 对应 NOSE、EYE、CHECKER、HAT，保安卡在 2F，经理对白完成即可无卡上楼。上述材料需要按 V4 修订，或明确归档其旧版本用途。

[玩家说明第 27 行](https://github.com/sd5913/ae4pa/blob/eb39714d19d6568ca519155f768899e02e5a7804/docs/player-guide.md#L27) · [房号表第 15 行](https://github.com/sd5913/ae4pa/blob/eb39714d19d6568ca519155f768899e02e5a7804/docs/room-monster-table.md#L15)

### P2 独立 UI 检查缺少主入口与模态回归

PR 的 UI 检查覆盖旧 INTRO／RESCUE_309 和背包等演示，遗漏 main 已有的模态停表、换层拒绝后恢复，以及主入口 V4 ID。实测错误选取 PR 版本的副本中，独立 UI 检查依然通过，主入口和停表检查则失败。合并测试时应保留 main 的保护性检查，并补合并后的 F5 开场／经理链路。

## 14 个冲突文件的处理建议

| 文件 | 处理方式 |
|---|---|
| scenes/ui/dialogue.gd、dialogue.tscn、dialogue.gd.uid | 保留 main 的 V4 三件套，按新版节点和表现移植救援立绘 |
| scenes/ui/mission_board.gd | 以 main 的模态和换层流程为基础加入主题 |
| scenes/ui/failure.gd、failure.tscn | 保留 main 的模态登记，核对 A 当前任务重试适配。当前 main 的缺恢复接口状态不应被当作最终游戏接口 |
| scenes/ui/hud.gd、hud.tscn | 可合入 CardDisplay／主题，保留真实任务／时间读取和可读布局 |
| scenes/tests/ui/ui_test.gd、ui_test.tscn、ui_test.gd.uid | 合并有效测试覆盖，场景、脚本、UID 一致，保留 main 的保护性断言 |
| README.md、docs/progress.md、docs/qa.md | 当前说明按 V4 更新，双方历史与真实验证记录按时间追加 |

冲突处理应按明确的版本和功能选择。Current／Incoming 标签随合并方向变化，不能单凭标签决定保留哪一边。

菜单、背包、帮助、CardDisplay、主题和 HUD 的若干组件与 A 已上传候选重复。Win 组件及 D 的历史截图／交付材料可以保留，但文字内容需要复核 V4。两分支整棵树的差异有 172 个文件，其中包含分叉后 main 的新增成果；这不等于 PR 要删除 172 个文件。审查文件范围使用 PR 的 46 文件差异。

## 实际验证

真实冲突重放目录为 `/private/tmp/ae4pa-pr22-review-owj3l15w`。本轮未切换或合并用户当前工作区。

用相同 Godot 4.7.2 探针比较两个临时源码副本。对照为 main `007437a`，错误合并示例为将 14 个冲突全部选用 PR 版本。

| 验证 | 当前 main | 错误合并示例 |
|---|---|---|
| editor --import --quit | 退出 0 | 退出 0 |
| D 独立 ui_test -- --ui-smoke | 退出 0 | 退出 0 |
| 任务面板打开后世界输入被锁 | true | false |
| 面板内推进一秒后的任务余量 | 210 | 209 |
| F5 的 V4_INTRO 显示 | true | false |
| 主入口／停表探针退出码 | 0 | 1 |

探针为 `/private/tmp/ae4pa_pr22_probe.gd`，日志为 `/private/tmp/ae4pa-pr22-{good,bad}-probe.log` 和对应的 ui.log。headless 保留已知 macOS 系统证书诊断。此错误合并示例用于说明版本选错的后果，不能作为实际修复后的验收。

## 可直接转发给 D 的审查意见

```text
PR #22 暂需修改。当前 main 已包含 PR #23 的 M1 UI，A 的完整 201 候选在 work/member-A-liuling／ef8a2f7。

请以当前 V4 版本处理 14 个冲突。保留 main 的 V4_INTRO／V4_MANAGER_TALK 对白脚本、场景、UID，以及任务面板的模态停表、换层前隐藏／拒绝后恢复和输入保护。救援立绘与主题单独移植到新版。

请将 player-guide 和 room-monster-table 改为 V4。201=NOSE、202=EYE、204=CHECKER、205=HAT，经理交谈即可上 2F，卡片按任务获得。

请合并有效测试，保留 main 的模态／换层／HUD 检查，并在合并候选上实际验证 F5 序章、经理、任务面板停表。当前旧 UI 独立检查通过，但错误选用旧版本会导致 F5 无对白且被锁、面板内继续扣时。

完成后提供合并候选版本、准确测试结果和未验项目，再进行审查。
```

GitHub 上可从 Files changed 逐文件查看并留言，最后在 Review changes 提交 Request changes；自己的 PR 可通过普通评论向作者说明。具体入口见 [GitHub 审查文档](https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/reviewing-proposed-changes-in-a-pull-request)。本轮审查意见保存在本地，PR 仍维持原状态。
