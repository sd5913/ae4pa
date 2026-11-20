# 老师形成性评审对照检查 · 2026-11-17

结论：老师指出的首个 F5 任务闭环、真实任务 UI 和任务 01 检查点恢复，当前共享 main 已有实现，本轮也重新运行通过。尚不能宣布 M1 完成人工验收或整个项目可通关。当前需要收尾的是玩家反馈、回归检查与说明一致性，以及带版本的新玩家验收记录。

本轮为 qa-only 检查，没有修复产品、修改产品测试、切换分支、合并或推送。

## 版本、环境与证据口径

| 项目 | 本轮实际情况 |
|---|---|
| 老师原审阅版本 | main `007437a`；对照 A `02be618`、B `7af4af1` 和旧 D 候选；老师明确为静态评审 |
| 本轮测试版本 | 共享 main `c7365533be026bcea41f9178d139151579de71bb`，最新提交为 PR #33；测试时固定该 SHA |
| 本机工作区 | A `35d6d018b3ad053050575cdbf90bdbaba1a7ded1`，与远端 A 一致；相对最新 main 落后 20 个提交。原有未提交改动保留 |
| 隔离方式 | 从 main 的 Git archive 解出独立源码快照到本轮临时目录，未把当前 A 的未提交修正混进 main 测试 |
| 源码一致性 | 导入及检查后，119 个已跟踪 `.gd`／`.tscn`／`.tres`／项目配置与该 main 提交逐字节一致；缓存和临时诊断夹具另存 |
| 引擎／平台 | Godot `4.7.2.stable.official.ed1daf0bf`；macOS / Darwin arm64；原生 Compatibility、OpenGL 4.1 Metal、Apple M5 |
| 时限 | 单次功能命令 60 秒，首次导入 120 秒；没有设置总探测倒计时；各捕获跨度合计 165.676 秒，总会话耗时未测量 |
| 证据根目录 | `/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie`；路径索引 `/private/tmp/ae4pa-teacher-review-current-path` |
| 总体结果 | **非全绿**：8 项不同的功能检查通过；一楼美术回归检查失败；另有接受后提示不更新的体验缺陷。原生首轮通过，第二轮超时未计通过 |

完整命令、stdout／stderr、退出码及检查点保存在[证据汇总](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/evidence.json)。该汇总的最终 verdict 为 `fail`，不以功能链路通过掩盖其他失败。

## 检查目标（Charters）

1. 从真实 F5 菜单、序章、经理、201 面板到偷卡、换卡、清理、交付、解锁，检查真实 UI 和业务信号；明确既有位置、转场、确定朝向及手动时钟夹具。
2. 检查超时／被抓恢复卡、装备、任务、世界、位置和模态；错误快照不得改变失败现场。
3. 检查背包、帮助、暂停、楼层选择、对白在门边及超时两种先后顺序中的输入／停表行为；接受页与失败页另由现有 F5 检查覆盖。
4. 检查 B 工作权限和一次性结果、C 门位／美术与真实交互；原生截图检查文字和布局，不替代新玩家观察。
5. 对照 PR、README、计划和验收材料，明确已发布、未同步、未验收及下一负责人。

允许写入仅为报告、证据及本轮临时夹具。退出条件为上述范围检查完成或明确阻塞；不扩大玩法、不创建并行实现。所有测试进程均在结束或超时后退出，临时快照与证据保留以便复核。

## 对老师五项重点的回答

| 老师关注点 | 现在的项目情况 | 仍需完成／负责人 |
|---|---|---|
| 一个完整 F5 循环 | **实现及自动运行通过**。真实菜单／序章／经理／201 接受／B 偷保洁卡／切卡／清理／C 门交付／解锁，由真实任务面板和 HUD 驱动，不依赖开发完成按钮 | A 固定演示 SHA，D 记录新玩家正式 F5；不能把位置、时钟夹具当真人走完 |
| 明确且可测的失败恢复 | **任务 01 实现及自动运行通过**。超时、正面被抓、回头发现、跨层失败、错误快照、连续重试及模态恢复已有检查 | 真实等待倒计时、人工重试和前序任务状态仍按实际流程补记录；任务 02—05 恢复未验证，A 负责 |
| 经审核整合 A／B／D | A 已经 #30 进入 main，旧 D #22 已合，D 新 UI／进度／楼层选择／暂停也已在 main；本轮 F5 检查确认没有丢掉 V4 对白、模态和输入保护 | 本机 A 尚未同步这一批新 main；B #24 仍开放，需要 A/B 对照剩余差异收尾，不重复实现已存在组件 |
| 门、员工与污渍的视觉校准 | 一楼采用无静态人物的分层资产与真实角色，二楼采用分层门美术；二楼检测／门槛检查通过。原生面板、HUD、背包、失败页已查看 | **缺新玩家理解度证据**；本轮发现接受提示与已接受状态矛盾，先由 A/D 修正，再由 D 观察第一个误解；C/B 分别复核门／员工提示 |
| 版本、平台、结果、阻塞和下一负责人 | 本报告提供本轮准确版本、平台、实际运行结果和缺口；历史 PASS 未当作本轮复现 | D/A 补一位新玩家用自己的话说明任务、当前卡和剩余时间，并保留原话、错误及视频／截图；Windows、独立导出与完整通关仍待验证 |

老师没有要求新机制，本轮也没有把后四任务、309 或结局扩大为新开发任务。当前合适的里程碑仍是先完成任务 01 的可展示验收。

## 本轮实际运行结果

以下入口都在固定的 main 快照运行。公共前缀为 Godot `--headless --path <快照> --max-fps 120 --log-file <本轮独立日志>`；脚本入口再加 `--script res://…`，场景入口直接传 `.tscn`。完整原生命令可从证据汇总各行读取。

| 检查 | 实际结果 | 证明与限制 |
|---|---|---|
| `core/task_ui_smoke.gd` | PASS，退出 0 | 真实 F5 接受／HUD／偷卡清理交付、失败页和重试、普通退回、暂停和楼层选择；含位置／转场／时钟／朝向夹具 |
| `core/task_checkpoint_smoke.gd` | PASS，退出 0 | 卡／装备／世界／位置回滚、非法快照拒绝、超时和被抓、连续恢复；不证明任务 02—05 |
| `core/world_interaction_smoke.gd` | PASS，退出 0 | 唯一 E、任务资格、取消、模态、回访与通路 |
| 本轮临时 `modal_probe.gd` | PASS，退出 0 | 五种页面的门边冻结、关闭恢复真实普通门退回、页面先开／超时先发生两种顺序；不是产品新增测试 |
| `doors/floor_2_layout_smoke.gd` | PASS，退出 0 | 三态变换、检测中心、门槛与层级一致；不证明新玩家能理解 |
| `staff/work_items_smoke.tscn` | PASS，退出 0 | PICKUP／AUTHORIZE 权限、一次性／恢复、PATROL_RECORD 与只读进度；后段主线尚未接通 |
| `core/intro_flow_smoke.gd` | PASS，退出 0 | 真实序章、经理输入、无卡上楼、模态和新局清理 |
| `core/foundation_smoke.gd` | PASS，退出 0 | 共享管理器、卡片隔离、移动边界和生命周期 |
| `core/floor_1_art_smoke.gd` | **FAIL，退出 1** | 原命令两次复现；使用本轮可写 TEMP 隔离后仍失败。失败点见 ISSUE-02，不能继续沿用此前 PASS |
| 原生 `modal_probe.gd -- --visual-probe` | 首轮退出 0；复跑超时 124 | 首轮完成同一模态检查并生成五张截图；第二轮捕获不完整，不推断超时根因，也不计通过 |
| 本轮临时 `notice_probe.gd` | 两次退出 1，确认缺陷 | 实际接受按钮后状态 ACTIVE、面板已关，但通知仍要求确认接受，见 ISSUE-01 |

## 发现的问题

### ISSUE-01 · P2：接受任务后，上方仍要求玩家确认接受

- **Observed：** 接受任务后，HUD 已进入进行中并开始扣时，上方通知仍写“请在面板中确认接受，接受后开始 210 秒计时”。
- **Expected：** 已接受状态应明确指向回 1F 取得保洁卡，不能继续要求接受；这是老师要求玩家能解释当前任务的直接前提。
- **复现：** 从 F5 点击开始；本轮用序章／经理完成及位置夹具到 201，点击真实“接受任务”按钮。未代记接受、清理或交付结果。
- **Evidence：** [原生 HUD 截图](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/screenshots/capture-013/hud.png)，以及[最小探针结果](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/.qa-evidence/017/observation.json)。状态 `ACTIVE`，`board_visible=false`，余量约 `209.8667`，`stale_acceptance_instruction=true`。
- **Confirmation：** 首轮原生截图发现；独立 headless 最小命令两次确认。第二次原生复跑超时，不用它加强确认次数。
- **源码依据：** main 的 [main.gd:144](https://github.com/sd5913/ae4pa/blob/c7365533be026bcea41f9178d139151579de71bb/scenes/main.gd#L144) 写入 offer 通知；[task_ui.gd:86](https://github.com/sd5913/ae4pa/blob/c7365533be026bcea41f9178d139151579de71bb/scenes/task_ui.gd#L86) 接受后只隐藏面板。当前目标标签会刷新，旧通知没有同步刷新。
- **影响／下一负责人：** A 主修状态反馈、D 复核展示。在开始后续房间前先修此误导，并让新玩家验证；没有证据表明它阻止交付，不能写成流程卡死。

### ISSUE-02 · P2：一楼美术回归仍按旧楼梯行为断言

- **Observed：** `floor_1_art_smoke.gd` 在“Real stair E still reaches 2F”处退出 1。
- **Expected：** 当前 main 按 E 打开楼层选择，选择 2F 后才上楼；回归应通过真实选择按钮后断言到达二楼，保留其原有经理和美术覆盖。
- **Evidence：** [隔离缓存后的失败结果](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/.qa-evidence/010/observation.json)；[原测试第 95 行](https://github.com/sd5913/ae4pa/blob/c7365533be026bcea41f9178d139151579de71bb/scenes/tests/core/floor_1_art_smoke.gd#L95) 仍直接检查 `current_floor == 2`。真实新版楼梯选择及目的地已经由本轮 task_ui 检查通过。
- **Confirmation：** 原命令两次失败；仅将测试支持的 TEMP 指向自有可写目录后再跑，缓存写入诊断消失，楼梯断言仍失败。
- **分类／下一负责人：** 这是整合后测试与现行交互约定不一致，不能据此宣称游戏上不了楼。A/C 更新既有检查、D 确认新选择页约定；本轮没有修改测试或回退玩法。

### ISSUE-03 · P2：当前说明仍混有“未接入／未发布”的旧状态

- **Observed：** main [README 第 69 行](https://github.com/sd5913/ae4pa/blob/c7365533be026bcea41f9178d139151579de71bb/README.md#L69) 仍称正式背包／说明／暂停待接入；第 78 行仍称 H 的 UI 待接入，和当前 F5 实现／本轮运行不符。
- **Expected：** 当前入口说明以固定版本的真实实现为准；历史记录保留日期并追加更正，不把全部历史 PASS 或旧“待接入”直接当现状。
- **Evidence／Confirmation：** main README 与本轮通过的 task_ui、modal_probe 直接对照；为静态文档一致性确认，没有伪装为运行故障。
- **关联材料：** `docs/qa.md` 的历史 FB-02／03 表仍出现“未发布”；`PLANS.md` 的当前状态还保留旧 D 待交付描述。`docs/demo-recording-checklist.md` 的任务 01 试玩行也统一标为“被主线阻塞”，需要区别任务 01 已可验收与后四任务尚未接通。
- **下一负责人：** A 统一版本与入口；D 更新当前玩家说明、验收模板和当前状态摘要；保留历史证据，不整篇覆盖进度文档。

## PR 与工作区状态

| 工作 | 本轮核对结果 |
|---|---|
| [A #30](https://github.com/sd5913/ae4pa/pull/30) | 已合入，包含 `35d6d01`，老师提到的 A 候选已不再只是个人分支工作 |
| [D #22](https://github.com/sd5913/ae4pa/pull/22) | 已合入；旧冲突状态不能继续当当前结论。V4 序章和模态由本轮运行核对 |
| [C #31](https://github.com/sd5913/ae4pa/pull/31) | 已合入一楼分层美术；其原检查需随新版楼梯流程维护 |
| [D #32](https://github.com/sd5913/ae4pa/pull/32)／[D #33](https://github.com/sd5913/ae4pa/pull/33) | 已合入角色美术、卡图、任务／暂停／楼梯／进度等 UI |
| [B #24](https://github.com/sd5913/ae4pa/pull/24) | PR 仍开放。其工作组件与进度已随 A 整合进入 main；当前 `cleaning_spot.gd`／`work_point.tscn` 与 B 候选一致，Staff 又增加角色表现。A/B 应核对剩余文档／提交差异并收尾 PR，不能重复实现或笼统说 B 功能尚未进入 main |
| 本机 A | 保持 `35d6d01`；本轮只 fetch，没有把更新的 main 合入当前工作区。直接运行现有 `play.command` 仍是本机 A，不是本报告测试的 main 快照 |

## 下次演示前的最小验收安排

| 顺序 | 具体交付 | 下一负责人 |
|---|---|---|
| 1 | 选择同一个明确 main 提交，保留本地修改后同步演示工作区；写清运行来源和 Godot 版本 | A |
| 2 | 修 ISSUE-01、更新 ISSUE-02，清理当前说明中的旧状态；重跑相关原检查，记录失败到修复后的结果 | A 主修，C/D 分别复核 |
| 3 | 由一位未熟悉路线的玩家从正式菜单走完任务 01。**不要先告诉他路线答案**，记录第一个误解、卡住位置和原因 | D 观察并记录，A 在场定位 |
| 4 | 在接受后、获得卡后和清理后，分别记录玩家原话：“现在要做什么、当前哪张卡生效、还剩多久” | D／玩家 |
| 5 | 真人实测成功、被抓重试、实际等超时重试、普通门退回；检查页面开关与时间／门边行为，记录墙钟和暂停时间 | D／玩家，A/C/B 分别复核各模块 |
| 6 | 附任务 01 的短视频或验收记录：SHA／构建、Godot、平台、步骤、观察结果、阻塞、下一负责人。后四任务和平台导出继续明确未验 | A 汇总，D 交付材料 |

当前仓库已有试玩表模板，但模板不等于实际试玩结果。任务 01 的短演示不应等待五层全部完成，也不能剪成“五层已通关”。本轮没有独立导出包或 Windows 运行证据；`play.command` 仍依赖本机 Godot。

## 提议的回归补充（未写入产品测试）

- 扩展已有 `task_ui_smoke.gd` 的接受后断言，检查上方通知与 ACTIVE 阶段一致，而不是另建一套 UI 测试。
  - Value: protects=post-acceptance player guidance; fails_when=offer notice stays after acceptance; why_new=current test checks objective/HUD only; seam=none; no_claim=new-player comprehension.
- 更新已有 `floor_1_art_smoke.gd`，通过真实楼层选择按钮再检查二楼，保留经理、柱子穿越和资源约束；不要删掉失败断言充当通过。
  - Value: protects=first-floor art plus current stair route; fails_when=selector cannot reach 2F; why_new=existing test assumes immediate travel; seam=none; no_claim=full five-floor gameplay.

本轮两个诊断脚本只在临时证据目录，不进入游戏源码或正式测试目录；没有为文档增加测试框架。

## 原生画面和覆盖限制

- 首轮原生截图： [任务接受页](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/screenshots/capture-013/offer.png)、[HUD](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/screenshots/capture-013/hud.png)、[背包](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/screenshots/capture-013/bag.png)、[超时重试页](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/screenshots/capture-013/timeout.png)。任务、当前卡、时间和重试控件可见；另有 ISSUE-01 的矛盾通知。
- 截图使用位置、卡片与手动时间夹具；完整真实偷卡和清理证据来自 task_ui／checkpoint，不能把截图算玩家通关。
- 五种页面的边界检查采用实际输入／模态和真实门退回；任务介绍与对白前置、卡片、位置、门相位及时间是明确夹具。楼层页从真实楼梯 E 打开后才将位置夹具移到门边；普通玩家不能在门边直接打开楼层列表。
- 任务接受页／失败页生命周期由现有 F5 检查覆盖。任务 01 以外的故事和所有模态组合没有穷举；没有将其记为通过。
- 初次导入存在既有 macOS 系统证书和编辑器设置保存受限诊断。首轮一楼检查还有测试缓存写入受限；使用其既有 TEMP 入口隔离后该诊断消失，测试失败仍保留。
- 捕获 014 的原生复跑超过 60 秒，未获得完整观察，原因未确定，不计通过；捕获 015 是本轮自有夹具的类型错误，修正夹具后用同一命令 016／017 重跑，未改产品。
- 新玩家理解度、正式录像、Windows、独立导出、后四任务、309 和结局未验。未对这些项目沿用历史 PASS。
- 没有写入外部学习库或项目状态库：本轮只在许可的临时证据目录和本地报告文件保存结果。

## 探测检查点与复核入口

所有检查点在下一次探测前保留；包含失败、超时和被后续结果取代的历史。原始证据未以摘要替换。

- [002](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-002.json)：导入 → 完整 F5。
- [003](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-003.json)：完整 F5 → 检查点。
- [004](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-004.json)：检查点 → 世界 E。
- [005](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-005.json)：世界 E → 模态边界。
- [006](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-006.json)：模态 → 一楼美术。
- [007](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-007.json)：一楼结果 → 二楼布局。
- [008](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-008.json)：二楼 → 一楼原命令复跑。
- [009](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-009.json)：原命令复跑 → 工作组件。
- [010](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-010.json)：工作组件 → 一楼隔离缓存复跑。
- [011](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-011.json)：一楼失败 → 独立序章。
- [012](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-012.json)：序章 → 基础检查。
- [013](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-013.json)：基础 → 原生画面。
- [014](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-014.json)：原生发现 → 原命令复跑，复跑超时。
- [015](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-015.json)：原生发现 → 最小提示探针，夹具错误，后续取代。
- [016](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-016.json)：修正自有夹具后，同一命令确认提示缺陷。
- [017](/private/tmp/ae4pa-teacher-review-20261117-dzdp_gie/exploration-017.json)：最小提示探针原命令复跑确认。

状态：**检查完成，存在待处理问题；不标整体验收通过。** 建议先收尾任务 01 的提示、测试和真人验收，再开启任务 02。
