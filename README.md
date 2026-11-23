# 怪物员工通道 · Monster Staff Access

四人协作开发的单人 2D 潜行解谜游戏。Carol 潜入五层怪物旅馆，利用员工身份完成住客委托，到 309 救出 Terese，再从五楼逃离。

**[下载《游戏测试.xlsx》](https://github.com/sd5913/ae4pa/raw/refs/heads/main/outputs/game-test-20261121/%E6%B8%B8%E6%88%8F%E6%B5%8B%E8%AF%95.xlsx)** · [在 GitHub 查看文件](outputs/game-test-20261121/游戏测试.xlsx) · [文档目录](docs/README.md)

工作簿收录 23 条试玩反馈和验收事项，可筛选问题分类、BUG 状态、人工验收、负责人及后续动作。填写测试结果时请一并注明本次试玩的提交和平台。见[测试记录说明](docs/qa.md)。

## 开始试玩

1. 克隆仓库或把本地副本同步到 `main`。
2. 用 **Godot 4.7.2 标准版**导入根目录的 `project.godot`，首次打开等待资源导入完成。项目使用 Compatibility 渲染器。
3. 按 **F5** 启动 `scenes/main.tscn`，点击「开始游戏」。macOS 也可双击根目录的 `play.command` 启动，需先安装 Godot。

用 **A／D** 或方向键移动，**E** 交互，**Q** 切换当前身份，**I** 打开背包，**H** 查看笔记，**Esc** 暂停。查看[中文玩家指南](docs/player-guide.md)或 [English quick start](docs/quick_start_en.md)。

### Windows VM download

1. Sign in to GitHub and open the [Godot Windows build workflow](https://github.com/sd5913/ae4pa/actions/workflows/godot-build.yml). Choose the run for the branch or pull request you want to test.
2. Download the `monster-hotel-windows-x64-<commit>` artifact from the run summary. Artifacts are retained for 14 days.
3. In an x64 Windows VM, extract the entire ZIP to one folder. Keep `MonsterHotel.exe` and `MonsterHotel.pck` together, then double-click `MonsterHotel.exe` and choose Start Game. Godot does not need to be installed. Record the SHA in `commit.txt` with your test results.

The workflow checks the package and starts the downloaded executable headlessly on a hosted Windows runner. Test graphics, input, and the full route in the VM. The full-playthrough automation runs as a separate, non-blocking check and reports its own result in the run summary. The [recorded gameplay failure](docs/qa_evidence/d_delivery_closeout_20261122/README.md) is tracked separately.

## 当前项目状态

从[当前项目状态](docs/CURRENT_STATUS.md)查看已接通的主线、自动验证结果、真人待验项和下一项负责人。

## 组员入口

| 要做什么 | 从这里开始 |
| --- | --- |
| 开发或提交改动 | [组员接入](docs/onboarding.md) · [GitHub 协作](docs/github-collaboration-guide.md) · [A/B/C/D 分工](docs/team-plan.md) |
| 查实际机制或接口 | [游戏机制](docs/current_game_mechanics_for_gpt_20261121.md) · [公共接口](docs/interfaces.md) |
| 查里程碑、交接和历史 | [执行清单](PLANS.md) · [进度记录](docs/progress.md) · [文档目录](docs/README.md) |
