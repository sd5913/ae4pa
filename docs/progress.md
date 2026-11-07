# 怪物员工通道开发进度记录

本文件保存实际工作、观察证据、决定及限制。任务顺序与当前状态以 [PLANS.md](../PLANS.md) 为准；玩法以 [游戏规则](game-design.md) 为准，测试用例以 [QA](qa.md) 为准。

已发生记录按时间追加；发现错误时追加更正并引用原记录。计划、文件存在和真实运行通过分别记录。

本文件日期均按 `Asia/Hong_Kong`（UTC+08:00）记录。

## 2026年11月5日 任务01 资料整理

- 完成：阅读策划案 V3、三周执行手册 V2 及工作流文章；创建 `PLANS.md`、`docs/game-design.md`。
- 观察：源项目没有 `.tscn` 或 `.gd`；README 仍为商场旧设定。当前分支为 `ling/identity-shift-prototype`，`project.godot` 已有未提交修改。
- 验证：Godot MCP 项目查询成功，返回版本 `4.7.2.stable.official.ed1daf0bf`。`git diff --check` 无诊断；新增文档的空白检查无诊断。
- 限制：未运行游戏，未验证导出或其他成员电脑。资料冲突和未定规则已标记，未当作已实现功能。

## 2026年11月5日 用户调整执行安排

- 用户明确本轮执行任务 02；继续按编号逐项完成。
- Windows/macOS 的分别试玩放在公共底座完成后，最终导出平台在对应阶段验证。
- 背包和详细交互方式稍后边做边确认。任务 03 先整理必要基础接口，详细规则延后到相关功能阶段，不阻塞公共环境。
- 本轮之前的环境检查：MCP 与本机 Godot 命令行均返回 `4.7.2.stable.official.ed1daf0bf`；其他成员版本未核对。

## 2026年11月5日 任务02 团队开发文档

- 工作范围：更新 `README.md`；创建 `AGENTS.md`、`docs/qa.md` 和本文件；同步执行清单和游戏规则中的最新安排。
- 内容：修正旧设定，说明真实运行现状，登记文件归属、AI 工作边界、协作流程、T01—T14、基础环境检查和 BUG 模板。
- 规则处理：具体交互延后确认；不把待定暂停方案写成默认规则。
- 验证：一次性 Markdown 检查覆盖 6 份文件、17 个本地相对链接及 T01—T14 编号，退出码 0；无行末空白或缺失链接。`git diff --check` 无诊断。
- 范围核对：`git status --short` 显示本轮仅新增／更新文档；`git diff -- project.godot` 与任务开始时一致，保留既有项目名称删除改动。
- 结果：任务 02 的文档交付已完成；任务 03 尚未开始。
- 游戏验证：本轮为文档任务，没有可运行场景；QA 用例均保持未执行。
- 下一项：任务 03 的最小公共接口文档；背包、暂停和详细交互留待功能阶段补充。

## 2026年11月5日 任务03 公共接口文档

- 授权：用户要求创建 `docs/interfaces.md`，按三周执行手册 V2 的分工编写。
- 来源核对：重新读取 V2 的协作、公共底座、A/B/C/D 工作步骤；沿用 A 管流程／主角、B 管员工／卡片、C 管门／五怪、D 管 UI／剧情／测试。
- 完成内容：起草两个 Autoload、Player、员工、房门和 UI 的数据、函数、信号、输入归属、场景注入和独立测试约定；标记基础骨架与后续功能阶段。
- 技术约定：为降低跨脚本依赖，公共 ID 使用字符串；主角类型名定为 HotelPlayer；B/C 通过 `setup(player)` 接收 A 的主角实例。V2 未固定的这些命名为本次协作草案，成员接入确认仍待进行。
- 用户约束：背包、暂停、交互优先级、装备快照和救援重试细节仍留到对应功能阶段。
- 配套更新：README 添加接口入口，AGENTS 去掉“接口文档未建立”的旧说明，游戏规则添加链接，PLANS 记录本项进度。
- 验证：7 份 Markdown、21 个本地相对链接及 T01—T14 编号检查通过，`git diff --check` 无诊断；逐项核对 V2 分工以及六条跨模块调用链的名称和参数。
- 范围：`project.godot` 的差异与本轮开始一致；本次仅创建／更新文档，没有实现游戏代码或执行游戏验收。
- 结果：任务 03 文档交付完成；七份基础文档现已齐全。接口实现、B/C/D 确认和实际接入仍待后续阶段。
- 下一项：任务 04，配置 Godot 公共环境。

## 2026年11月5日 任务04 Godot 公共环境

- 开始状态：项目已使用 Compatibility；项目名称为空，没有分辨率和约定输入映射。已有用户修改及前期文档保持在当前功能分支。
- 完成配置：名称设为“怪物员工通道 Monster Staff Access”；逻辑视口和初始窗口为 1280×720；使用 `canvas_items`、`keep` 保持比例；保留 Compatibility。
- 输入：建立七个约定动作、九个物理按键绑定，未实现游戏输入处理脚本。
- 版本：本机命令行及 MCP 均返回 `4.7.2.stable.official.ed1daf0bf`，将 Godot 4.7.2 标准版作为团队安装基准；其他成员安装待任务 07 核对。
- 文件：修改 `project.godot`、`.gitignore`，新增 `docs/environment.md`；同步 README、AGENTS、游戏规则、PLANS 和 QA B03。
- Git 配置：新增 `/builds/` 忽略导出成品；核对 `.godot/`、`android/` 已忽略，`.gitattributes` 已统一文本 LF；没有新增对源素材或 UID 的忽略。
- 配置验证：Godot 独立进程重新读取九项设置和 InputMap，七个动作／九个绑定全部匹配；用键盘事件逐个验证按下激活和松开释放，最终退出码 0。
- 检查命令：本机 Godot 使用 `--headless --path <仓库> --log-file /tmp/ae4pa-verify-environment.log --script /tmp/ae4pa-verify-environment.gd`；临时脚本在仓库外，成员可按环境文档中的编辑器路径复核。
- 环境诊断：沙箱内无法创建标准用户数据目录并出现系统证书读取错误；同一检查在正常权限下重跑后消失。输入检查脚本曾误用非键盘设备 ID 和过早的初始化时机，按引擎键盘常量及事件处理时序修正后全部通过；没有因此更改项目输入规则。
- 文档检查：8 份 Markdown、25 个本地相对链接检查通过；`git diff --check` 无诊断；`git check-ignore` 确认三个生成目录被忽略。
- 结果：任务 04 在 A 本机配置完成，QA B03 标记本机配置通过。
- 限制：没有主场景或管理器实现，没有执行游戏验收、窗口画面试玩或 Windows/macOS 双端试玩；导出模板留到导出阶段。
- 下一项：任务 05，建立主场景、GameManager 和 CardManager 最小骨架。

## 2026年11月5日 后续公共底座执行范围

- 用户要求继续完成后面的任务，本轮按编号继续公共底座：04 配置、05 框架、06 主角与走廊、07 本机可准备的接入材料。
- 保留 V2 分工：B/C/D 的实际组件由各成员负责；人工跨机器验收和接入尚不存在的模块不记为完成。
- 沿用当前功能分支及现有工作区，不切换分支，不提交或推送；每项完成后记录证据再继续。

## 2026年11月5日 任务05 公共框架

- 创建 `scenes/main.tscn`、相邻入口脚本、`scripts/game_manager.gd`、`scripts/card_manager.gd`；设置主场景和两个 Autoload，CardManager 先加载。
- GameManager 实现 MENU／PLAYING／FAILED、开始新局、失败去重和状态／失败通知。
- CardManager 只实现空数据读取、查询副本和新局重置；收集、Q 切换和装备仍交给 B。
- 检查入口：`scenes/tests/core/foundation_smoke.gd`。实现前观察到缺管理器、缺主场景的预期失败；实现后用 Godot 执行通过，退出码 0。
- 已验证：主场景可实例化，管理器加载、新局重置、数组查询不泄漏可写数据、失败监听顺序、重复失败只报告一次。
- 后续：任务 06 增加移动和相机验证；窗口实际画面将在公共走廊建立后检查。

## 2026年11月5日 任务06 主角与测试走廊

- 创建 `scenes/player/player.tscn`、`player.gd`、`scenes/levels/test_corridor.tscn` 及脚本，接入主场景 World。
- 实现：HotelPlayer、player 分组、160 像素／秒水平移动、松手停止、两端边界、移动锁、非 PLAYING 禁止移动、横向 Camera2D；走廊为 2800×720 的占位场景。
- 原型决定：左右同时按抵消；`is_moving` 按本帧实际位移计算。相关怪物边界行为仍可在 A/C 接入时共同确认。
- 验证：先观察到“主场景缺少共享主角”的预期失败；实现后基础回归通过，覆盖左右、停止、固定 y、反向键抵消、锁定、两端边界、失败后的移动禁止及相机范围。
- 命令：Godot `--headless --path <仓库> --script res://scenes/tests/core/foundation_smoke.gd`，退出码 0。
- 实际渲染：Mac 原生窗口以 OpenGL 4.1 Metal / Compatibility 渲染主场景，保存预览并人工查看；1280×720，中文、主角、走廊和开发提示清楚，无重叠。预览为临时 QA 产物，不属于正式美术。
- 结果：任务 06 在 A 本机完成，QA B04/B06 通过对应本机检查；未执行游戏主线 T01—T14。

## 2026年11月5日 任务07 本机接入准备

- 创建 A/B/C/D 四个独立测试场景骨架，以及员工、房门、UI 和五类正式素材目录；B/C/D 组件本身仍为空。
- 新增 `docs/onboarding.md`，说明当前可用接口、F5/F6 入口、slot 和主角引用、个人分支、第一份交付与 PR 验收。
- 当前卡片数据为空，尚不能测试有卡安全或背包装备；接入说明要求等待 B 的接口，不能制造第二份假数据。
- 验证：底座回归加载四个独立测试骨架，各只有一个共享 Player，依赖可用。
- 干净源码检查：复制 runtime 源文件、UID 与资源到新的临时目录，不含 `.git` 或 `.godot`；Godot 重新导入及同一底座回归均通过，退出码 0。该检查不代表 Windows 或组员电脑已经验证。
- 独立代码检查：一位只读审阅者检查当前底座，未发现当前场景下的严重或重要问题；指出整体偏移走廊时边界／相机仍假定世界原点。当前场景不受影响，已在接入说明记录摆放约束，整体偏移支持延后。
- 待人工／外部完成：A 确认可交接版本并提交／推送；B/C/D 取得底座、分别运行和最小 PR；Windows 试玩；安装对应模板并验证导出包。没有把这些项目标记通过。
- 进度：任务 07 为“进行中，本机准备完成”。任务 08 需要 B/C/D 交付组件后再接入；当前未代写其员工、门或正式 UI。

## 2026年11月5日 公共底座收尾检查

- Godot MCP 实际启动主项目，返回 Compatibility 的 Mac 原生图形输出；项目查询识别 7 个场景、6 个脚本。
- CardManager 的换卡信号按接口预留，尚待 B 实现发出行为；对该处明确标注 `unused_signal` 注解，避免把预留接口显示为未使用警告，不添加虚假换卡事件。
- 重新通过 MCP 启动后读取调试输出，`errors` 为空；保留测试窗口供 A 试玩。
- 文档与格式核对：9 份 Markdown、31 个本地相对链接、T01—T14 编号和 `git diff --check` 均通过。
- 交接限制：测试走廊按世界原点摆放，整体偏移后的边界支持延后；底座未提交／推送，组员尚未取得新文件。后续先由 A 确认可交接版本，再进行成员本机验收和模块接入。

## 2026年11月5日 GitHub 协作讲解与分享指南

- 用户要求结合 `sd5913/ae4pa` 讲解新手协作、仓库管理与合并流程，并制作共享文档。
- 远端只读检查：仓库为组织 sd5913 下的公开仓库；main 和四个 work/member 分支均指向 4192a1a；无打开的 PR，main 未保护，规则集列表为空。
- 对照本机：当前分支 ling/identity-shift-prototype，公共底座仍有未提交文件，远端 main 尚无这些场景、脚本和文档。
- 创建 `docs/github-collaboration-guide.md`，包含术语、当前仓库快照、A 首次发布、成员同步／提交／提 PR、A 本地测试与合并、权限建议、冲突和 Codex 任务模板。
- 分支建议：沿用实际已有的 work/member 分支，人员对应关系由 A 确认；长期个人分支采用普通 merge commit，避免未经说明引入另一套命名和合并方式。同步 README 与组员接入说明。
- 操作边界：本次只读取远端并修改本地文档，未替仓库提交、推送、创建 PR、合并或修改权限／保护规则，也未向组员发消息。
- 验证：10 份 Markdown、36 个本地相对链接、代码块闭合及空白格式检查通过，`git diff --check` 无诊断；重新核对仓库允许普通 merge commit、当前未启用合并后自动删除分支。
- 交付：本地 Markdown 指南和 README／组员接入入口已准备。指南上传后才可通过仓库网页共享，当前可直接共享本地文件；没有执行游戏测试，因为本轮只修改文档。

## 2026年11月5日 公共底座发布准备

- 用户明确授权把本机新搭建的公共底座上传到 `sd5913/ae4pa` 的云端 main，本轮执行提交、上传功能分支、创建 PR 和普通 merge commit 合并。
- 目标核对：origin 指向 github.com 的 sd5913/ae4pa；获取远端后，main 仍在 4192a1a，无打开 PR 或阻止本次合并的保护规则。
- 发布前重新运行完整底座回归，启动、管理器、卡片查询隔离、失败去重、移动、边界和相机均通过，退出码 0。
- 待提交清单为 39 个源文件／文档，总计约 121 KB；不含 `.godot/` 缓存、导出包或原始 AI 候选素材。
- 更新 README、组员接入和协作指南的发布状态入口，保留此前检查记录作为历史快照。
- 后续验收：核对 PR 合并状态、main 的提交和文件树；组员分支同步、人员对应关系及跨机器运行仍由后续交接完成。

## 2026年11月5日 公共底座远端发布记录

- 源码提交：`422c43aa2dfb7ff7bed487de8a0f18fc1fac315a`，包含 39 个文件的公共底座与团队文档，已上传 `origin/ling/identity-shift-prototype`。
- 发布 PR：[建立可运行的 Godot 公共底座和四人协作文档 #2](https://github.com/sd5913/ae4pa/pull/2)，目标为 main，采用普通 merge commit；最终合并状态和 main 合并提交以该 PR 页面为准。
- 此次追加为发布记录和 README 入口，未变更已经通过回归的游戏代码。
- 成员交接：取得云端 main 的底座后，分别同步到自己工作分支并验证 F5/F6。现有四个 work/member 分支的人员对应关系、成员电脑运行及导出仍待后续确认。

## 2026年11月5日 主策划与分工文档 1.0 整合

- 用户要求将两份 Word 与现有 Markdown 整合为仓库主要策划／分工文档，并上传 GitHub；分工采用独立版本号 1.0，后续变化继续更新。
- 将 `docs/game-design.md` 扩展为项目主策划整合版 1.0，集中维护故事、三卡五怪、偷窃、门时序、公平规则、五层房号、救援、重试、UI、共享美术和范围。
- 新建 `docs/team-plan.md` 四人开发分工文档 1.0，保留 V2 的公共底座四项、A/B/D 各 12 项与 C 的 13 项、周末小样、三周安排、组件依赖与交付验收；文件路径固定，后续用版本栏和变更表升级。
- 统一资料：V3 旧人员分工采用 V2 的四功能岗位；HTML／Canvas 示例转换为 Godot 目标；沿用现有工作分支而不猜测成员对应；背包／暂停、3F 本层救援恢复等细节继续待确认。
- 更新 README、AGENTS、PLANS、公共接口和组员接入入口；补充 QA 对跨层救援保留与 3F 待定边界的说明。旧进度记录保留为历史，不将文档目标当作完成状态。
- 本次仅修改 Markdown，未修改游戏代码、场景或项目设置；游戏运行结果沿用公共底座既有证据，未重新执行功能测试。
- 验证：11 份 Markdown 的 61 个本地链接、空白／结尾换行／代码块检查通过；BASE 四项、A/B/D 各 12 项、C 的 13 项编号连续，20 个怪物房号对应及 T01—T14 编号核对通过，`git diff --check` 无诊断。

## 2026年11月6日 A 第1周复核与接入准备

- 用户授权完成 A 本周任务；按分工文档确定为 11/5—11/11 的底座、主角、测试走廊和首次整合，沿用个人分支，开始时工作区干净。
- 本机基线 `cfd0efbc04814f4f17b99822c74589252f1ed9dc`。通过 GitHub 连接器只读查询 main 完整文件树，返回 `2d250fe0ffda5af209a9748a1e062be080b3091f`，员工／门／UI 功能目录仅有 `.gitkeep`；打开的 PR 查询为空。未据此推断其他分支或成员电脑的开发状态。
- 执行本机 `Downloads/Godot.app/Contents/MacOS/Godot --version`，返回 `4.7.2.stable.official.ed1daf0bf`；用该可执行文件运行 `--headless --path . --log-file /tmp/ae4pa-week1-foundation.log --script res://scenes/tests/core/foundation_smoke.gd`，断言通过、退出码 0。
- 将 git 跟踪的源码复制到临时目录，不复制 `.git`／`.godot`；执行 `--headless --editor --path <副本> --import` 后执行同一回归，均退出码 0，回归打印 PASS。副本与日志位于本机临时目录 `ae4pa-week1-vb0l1xb_`，不提交。
- 限制：上述运行出现 macOS 系统证书读取错误；导入还出现受限用户目录的编辑器设置保存失败。未观察到脚本／资源加载失败，不能报告零错误。本轮未重新做原生画面检查、成员电脑或 Windows 验收，也未执行 T01—T14。
- 修改 `docs/a_week_1.md`、PLANS 与组员接入说明：集中记录 A-01—04、本周组件交付清单、B→C→D 接入顺序、验收回报格式及待测项；未修改游戏代码或代写成员模块。
- 文档检查：4 份改动 Markdown（含新增文件）的 18 个本地链接、行尾空白、结尾换行和代码块闭合检查通过；`git diff --check` 无诊断。
- 当前缺少可接入的 B/C/D 业务组件；任务 07 保持进行中、08 保持未开始。导出模板目录为空，未制作导出包；本轮未提交、推送、合并或向成员发送消息。

## 2026年11月6日 A-07 五层占位与独立切换

- 用户明确授权在等待 B/C/D 交付期间提前开发 A-07，指定自己的分支。实际远端名称为 `work/member-A-liuling`；fetch 后发现该分支仍在 `4192a1a`，本地从最新 `origin/main` 的 `2d250fe` 建立同名分支并设置对应 upstream，保留此前 4 份未提交文档。没有强推、重置、提交或更新远端分支。
- 实现文件：`scenes/levels/floor_base.tscn`、`floor.gd`、`floor_1.tscn`—`floor_5.tscn`、`scripts/game_manager.gd`、`scenes/tests/core/floors_test.tscn`／`.gd`，以及 Godot 生成的新增脚本 UID。F5 主场景、Player、CardManager 和 B/C/D 模块保持原状。
- 五层原型均为 3600×720，出生点 `(192, 560)`，边界 64—3536；1F 三员工接入位、2F—5F 按主策划的 20 个房号／怪物标记、309 救援位与五楼 EXIT 均为占位。默认门间隔 450，按半径 90 预留 270 像素安全空间，真实门接入后再实测节奏。
- GameManager 支持可选楼层宿主、顺序换层、LOADING 期间禁止游玩和完成后的 floor_changed；换层不重置卡片或 has_friend。正式 E 只在出口 70 像素内请求下一层，1F 依赖真实三卡、3F 依赖 has_friend；5F 暂不实现结局。F6 预览的开发跳转必须显式启用并使用 editor 可执行程序，不授予假卡、不标记救援，导出禁用防护已代码核对，实际导出包尚未验证。
- 验证先后：新增 `floor_flow_smoke.gd` 首次运行因五层资源／方法缺失而失败（退出码 1）；实现后通过。检查覆盖顺序／越界／重复请求、缺卡／未救援拦截、失败后禁止跳转、场景释放、单主角、入口、相机、边界、远处 E 无效及近处 E 换层、一次成功只通知一次、开发按钮不伪造状态、4F／5F 保留已救援状态夹具、新局回 1F。修正了测试监听器捕获已释放宿主的问题，最终日志没有该脚本错误。
- 本机命令使用 `Downloads/Godot.app/Contents/MacOS/Godot`：`--headless --path . --log-file /tmp/ae4pa-a07-green.log --script res://scenes/tests/core/floor_flow_smoke.gd` 与 `--headless --path . --log-file /tmp/ae4pa-a07-foundation.log --script res://scenes/tests/core/foundation_smoke.gd` 均打印 PASS、退出码 0。
- 干净源码：复制当前跟踪及新增源文件到临时目录 `ae4pa-a07-clean-ute5ys7g`，不含 `.godot`／`.git`；编辑器重新导入和上述两项回归均退出码 0，日志为 `/tmp/ae4pa-a07-clean-import.log`、`ae4pa-a07-clean-flow.log`、`ae4pa-a07-clean-foundation.log`。受限回归仍打印已知 macOS 系统证书读取错误，不宣称零错误；原工作区编辑器导入曾提示无法启动用户配置的外部文本编辑器，随后退回内置编辑器，干净副本未出现此提示。
- 实际渲染：Mac OpenGL 4.1 Metal／Compatibility 渲染 F6 预览，检查 1F 入口、2F 中段、3F 309／出口及 5F EXIT 的 1280×720 临时截图，中文、房号、状态、按钮和角色无重叠；截图位于 `/tmp/ae4pa-a07-floor-1.png` 等，不属于正式素材。该检查未进行鼠标人工试玩。
- 最终只读审阅者核对本次代码与主策划，未报告 Critical／Important／Minor 问题，并独立运行两项回归通过；未修改源文件。文档同步 README、接口、PLANS、组员接入、分工文档当前状态及 A 周清单，实施细节见 `docs/a07_floor_plan.md`。
- 文档／范围检查：22 份改动或新增文本文件（含前轮文档）的行尾空白、结尾换行及 Markdown 代码块检查通过，57 个本地链接存在，`git diff --check` 无诊断；未修改 B/C/D 业务文件、CardManager、主场景、项目设置或 Player。
- 限制：B/C/D 组件、真实三卡获得后的通行、309 实际救援、重试、淡入淡出、正式入口／UI／结局、Windows 与导出仍未验收。任务 10 只进入“A-07 占位／切换已验证”，没有把 T01—T14 或完整主线标记通过。

## 后续记录填写要求

每项记录日期与 `Asia/Hong_Kong` 时区、当前任务、实际修改文件、关键决定、执行过的检查及结果、未测事项、阻塞和下一步。只有确实执行并观察到结果的检查才能写通过。

成员提供的测试结果标记为“成员报告”，与当前操作者亲自观察的结果区分。涉及其他系统时写明 Windows/macOS、准确版本和目标机器。

## 2026年11月7日 C-01 通用房门（Windows，UTC+08:00）

- 分支：work/member-C-yinshiqi；开工无未提交改动，fetch 后将 origin/main 的 8882f0e 快进同步到个人分支。
- 文件：scenes/doors/monster_door.tscn、monster_door.gd 及 UID、模块 README；更新 scenes/tests/doors/doors_test.tscn，新增相邻脚本及 UID。
- 实现：一套 Node2D 通用门，门底中央为原点；room_id 可在检查器及运行时更新；Polygon2D 独眼占位图；独立场景同时展示 201、202 两个同源实例。
- 底座验证：Godot 4.7.2.stable.official.ed1daf0bf 控制台导入成功；foundation_smoke.gd 输出 PASS（启动、管理器、卡片查询隔离、失败、移动、边界、相机）。MCP 启动主场景，Compatibility/NVIDIA 渲染，errors 为空，随后停止测试进程。
- C-01 验证：本机临时 SceneTree 检查加载独立场景，确认初始房号 201/202；将第二扇改为 309 后第一扇仍为 201。实际 OpenGL 渲染并查看 1280×720 截图，两个门号和占位图均清楚。检查输出 PASS，退出码 0。临时检查脚本和截图保留本机，不进入源码。
- F6 入口：res://scenes/tests/doors/doors_test.tscn。A/D 或方向键移动；起点设在门旁便于检查。
- 限制：只完成 C-01 静态组件，未实现 C-02 起的计时、状态切换、检测、setup/reset_cycle 和五怪；占位怪物当前持续可见，不代表开门状态。未接入 main，未做主线验收、导出或其他电脑试玩。
- 交接：A 可复用场景并配置 room_id，完整说明在 scenes/doors/README.md；后续实现 C-02，再补预警和危险规则。

## 2026年11月7日 C-02 三状态循环（Windows，UTC+08:00）

- 开工：工作区干净，fetch 后个人远端及 origin/main 均已同步，无新增合并。
- 修改：monster_door.gd/.tscn、模块 README、doors_test.tscn；新增 door_cycle_smoke.gd 及 UID。
- 实现：CLOSED 5.5s → WARNING 1.4s → OPEN 2.8s 重复循环，保留帧间余量；时长可配置且最小为 0.01s；每门独立计时。非 PLAYING 冻结，编辑器不自动播放，reset_cycle 回到关闭；开门显示占位怪物，关闭/预警隐藏，附状态文字。
- 验证：Godot 4.7.2 控制台执行 door_cycle_smoke.gd 输出 PASS，覆盖默认时长边界、20 轮、长帧余量、实例独立、失败冻结、重置和引擎真实帧两轮循环。测试脚本首次类型推断错误已修正后重跑通过。
- 回归：重新导入和 foundation_smoke.gd 通过；MCP 启动 doors_test.tscn，Compatibility/NVIDIA 图形输出，errors 为空。
- F6 入口仍为 scenes/tests/doors/doors_test.tscn；自动检查为 --headless --path . --script res://scenes/tests/doors/door_cycle_smoke.gd。
- 限制：醒目预警为 C-03，检测区及五怪判定、相位和主游戏接入尚未完成；没有把状态文字当成最终视觉预警。未做导出、跨电脑或主线验收。

## 2026年11月7日 C-03/C-04/C-05 独眼门（Windows，UTC+08:00）

- 开工：工作区干净，fetch 后确认 origin/main 和个人分支已同步。沿用同一组件，不改主场景或 B 的卡片管理器。
- 修改：monster_door.gd/.tscn、门 README、doors_test.gd/.tscn；新增 eye_door_smoke.gd 及 UID。
- C-03：预警门框交替变色并显示“! 即将开门 !”；只有开启显示怪物。实际 OpenGL 截图核对预警文字、隐藏和开启显示无重叠；截图保留本机 outputs，不作为游戏素材。
- C-04：setup(player) 注入主角，在 PLAYING/OPEN 且主角有效时按 global_position.x 比较，默认半径 90；正负边界包含，外侧安全。水平游戏不额外限定 y；未绑定/已释放主角时不检测。
- C-05：仅 EYE 规则读取真实 CardManager.active_card，SECURITY 安全，其他卡或 NONE 调用 GameManager.fail("WRONG_CARD")。其他 monster_type 只预留，不宣称已完成。
- F6：scenes/tests/doors/doors_test.tscn，1 获取并佩戴保安卡、2 获取并佩戴保洁卡、R 重开；调试准备调用 B 的 collect_card/equip_card，屏幕显示真实当前卡、状态和失败原因。
- 验证：Godot 4.7.2 执行 eye_door_smoke.gd，60 组（三状态×五个水平距离×四种卡）通过，覆盖 ±90 边界及 ±90.1 外侧、平移父节点后的世界坐标、预警闪动、怪物显隐、缺失/重复绑定主角。door_cycle_smoke.gd 和 foundation_smoke.gd 均输出 PASS；资源导入成功。
- 限制：尚未实现 C-06 起的其他怪物、offset、多门节奏和平衡；未接入主游戏、未导出或跨电脑试玩。自动用例通过不等于完整主线通过。

## 2026年11月7日 A-07 发布准备与后续任务检查（Asia/Shanghai）

- 用户澄清本轮 Git 操作为“把本地 A-07 上传，并通过 PR 合入云端 main”，不是单纯拉取更新；保留 A 分支和全部成员历史，不直接推送 main。
- 开始时 A 分支位于 `2d250fe`，本地 A-07 尚未提交。fetch 后云端 main 为 `466620a`，已包含 B 两份交付 PR 和 C 的独眼门 PR。将本地全部未提交／新增文件保存为安全 stash `57e8f42f78ef3bd9bed0e0050aa722b521457f32`，A 分支快进 main 后应用快照成功，无合并冲突；该快照保留用于恢复。
- 本机 `project.godot` 被编辑器改为 `core_test.tscn` 默认入口并移除显式 keep 设置；按保留已有改动规则留在本地，不纳入本次提交。发布候选源码副本采用 git 中的 `scenes/main.tscn` 正式入口；下述验证针对发布源码，不将本地未提交设置冒充已测试发布配置。
- 在 A-07 流程检查中补充使用 B 的真实 collect_card／equip_card：三卡满足后可从 1F 正常上 2F，拥有卡片与佩戴槽保持。其余 A-07 生产逻辑没有为发布另加功能，未代写或更改 B/C/D 模块。
- 干净候选副本 `ae4pa-a07-publish-eajdnl4r` 不含 `.godot`／`.git`，导入完成、退出码 0；同一副本分别运行 `floor_flow_smoke.gd`、`foundation_smoke.gd`、`staff_core_smoke.tscn`、`door_cycle_smoke.gd`（--max-fps 60）和 `eye_door_smoke.gd`，5 项均打印 PASS、退出码 0。真实可执行文件为本机 Downloads 下的 Godot.app，准确版本沿用 `4.7.2.stable.official.ed1daf0bf`。日志保存在 `/tmp/ae4pa-a07-publish-*.log`。
- 限制：受限运行仍有 macOS CA 证书读取错误，导入还报告用户目录编辑器设置保存失败；未见脚本解析或场景加载错误，不报告零错误。此次未新增人工／跨机器／导出／完整主线验收。
- 已更新 README、PLANS、接口和接入说明中的实际状态，区分 B/C 已交付与 A 尚未组装。B 实际长按参数为 steal_hold_time，C 实际门参数为 room_id／closed_time／warning_time／open_time／radius，接入时不能直接使用旧文档中的计划字段。
- 后续优先顺序：A-05 在测试走廊接入 B 员工及卡片 → A-06 接入 C 独眼门 → A 的本层重试与 D 失败页连接（D 正式界面仍待交付）。之后推进 A-08 的 309 与跟随。需要先协调的现有差异：B 正面偷窃只拒绝操作，主策划要求立即 STAFF_CAUGHT；B 的现有测试也明确期待正面尝试后继续 PLAYING，不能据此给 T01 记通过。
- 本条为发布前记录；提交 SHA、PR 及最终 main 状态由本轮发布后核实，不在操作前预写成功。

## 2026年11月7日 C-06/C-07/C-08 其余四怪规则（Windows，Asia/Shanghai）

- 开工：个人分支工作区干净；fetch 后从 cf0a01d 快进同步 origin/main 的 51507f2，保留 A/B/C 全部已合并内容。PR #6 已合并，本轮作为新的功能 PR 交付。
- 修改：scenes/doors/monster_door.gd、模块 README、doors_test.gd/.tscn；新增 monster_rules_smoke.gd 及 UID；补充 docs/interfaces.md 的 C 实现状态，不变更公共签名。
- C-06：EYE/NOSE/HAT 共享当前卡对照表，分别要求 SECURITY/CLEANER/MANAGER；错误或 NONE 上报 WRONG_CARD。未复制门脚本，也未修改 B 的卡片数据。
- C-07：EAR 在 OPEN/PLAYING/水平范围内读取 HotelPlayer.is_moving，上报 MOVED_NEAR_EAR；卡片无保护。门物理处理优先级 1，在默认 Player 后读取本帧位移，沿用 A 的边界与反向键抵消约定。
- C-08：CHECKER 同步监听真实 identity_changed，SWITCH_ACTIVE/EQUIP_CARD（包括备用槽）在危险区上报 SWITCHED_NEAR_CHECKER；普通行走、cards_changed、收集、重复或无效装备不触发。setup 重复调用仅一个连接，移出树即解绑，无有效主角/暂停/非游玩安全。空槽切换按 B 当前发出的真实信号处理，不另定规则。
- F6：scenes/tests/doors/doors_test.tscn，F1～F5 选择五怪并重置；1/2/3 配三卡，4 测备用槽装备，Q 调 B 切卡，R 重开。正式图仍用既有占位图，类型文字用于明确区分，没有把美术候选自动采用。
- 验证：Godot 4.7.2 导入成功；monster_rules_smoke.gd 输出 PASS，600 组五怪状态/距离/卡片/移动组合、30 组真实切卡/装备事件、刷新隔离、暂停、重复/空绑定、真实移动处理顺序、移出树解绑通过；door_cycle_smoke.gd、eye_door_smoke.gd、foundation_smoke.gd 回归均通过，退出码均为 0。git diff --check 无诊断。
- 限制：C-09 的 offset、C-10 多门相位与安全区、C-12 完整人工回归、C-13 最终交接仍待后续；未将独立组件测试当作主游戏接入、跨电脑试玩或导出通过。
