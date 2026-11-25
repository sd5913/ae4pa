# 怪物员工通道开发进度记录

本文件保存实际工作、观察证据、决定及限制。任务顺序见[执行清单](../PLANS.md)，当期状态和下一项见[当前项目状态](CURRENT_STATUS.md)。玩法以 [游戏规则](game-design.md) 为准，测试用例以 [QA](qa.md) 为准。

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

## 2026年11月7日 C-09～C-13 参数、错相位与组件交接（Windows，Asia/Shanghai）

- 开工：工作区干净，fetch 后确认个人远端及 origin/main 已同步，无新合并。沿用 work/member-C-yinshiqi；PR #9 尚未合并，后续交付更新该 PR。
- C-09：补齐 offset 检查器参数，表示已走过的周期秒数，支持正负值和跨周期取模；reset_cycle 恢复配置相位，默认 0 从 CLOSED 开始。七个导出字段及自定义时长/偏移/复位由实际 Godot 检查通过。
- C-10：新增 multi_doors_test.tscn，三扇同源门 x=700/1400/2100，类型 EYE/EAR/CHECKER，offset=0/2/4；门间默认安全区 520px。测试专用 range_overlay 标示范围与安全区，不进入正式组件。五种起始时刻下，真实 HotelPlayer 移动方法的无卡等待通过模拟均成功；不是人工试玩结果。
- C-11：沿用统一 GameManager.fail 三种 reason；新增验证持续检测及后续换卡不会重复发出本次失败通知。三种原因已有五怪矩阵核对，未新增另一套失败信号。
- C-12：本机自动回归通过：door_cycle_smoke（20 轮与真实帧）、eye_door_smoke（60 组）、monster_rules_smoke（600 组规则和 30 组真实身份事件）、新增 door_handoff_smoke（参数/相位/安全间距/五条等待通路/失败去重/20 个楼层标记兼容性）。foundation_smoke 和 floor_flow_smoke 也均 PASS，退出码 0。人工操作复核与团队整合验收未代记通过。
- C-13：门 README 补齐参数边界、A 按 Room Marker 元数据实例化的示例、绑定与重试/销毁职责；新增 acceptance.md 验证记录和人工用例。更新 interfaces 的真实状态，修正旧“只有 EYE/尚无 offset”的描述。检查探针在 A 的 2F～5F 共 20 个标记正确实例化同一门，未保存或改动 A 的楼层。
- 画面与环境：Godot 4.7.2.stable.official.ed1daf0bf 导入成功；实际 OpenGL 渲染查看缩放全景下三种状态和安全区色带，截图为暂存阶段的视觉证据，不是试玩。MCP 正常运行 multi_doors_test，errors 为空，验收后停止；git diff --check 无诊断。
- 范围：只改 C 门模块、测试场景/脚本和必要接口/进度文档；没有改主场景、项目设置或 A/B/D 实现。仍用占位图，正式美术、主线装配、团队人工试玩、导出与最终难度调优待 A/D 后续验收。

## 2026年11月7日 A-07 上传与 PR 交接（Asia/Shanghai）

- 已提交源码与文档：`0b4fbd1c37a2afdc36e5c367edd75f2c32b3245e`，22 个文件，已正常推送至 `origin/work/member-A-liuling`，不含本机 project.godot 设置、Godot 缓存或 B/C 模块修改。
- 发布 PR：[A-07：五层占位场景与受条件约束的楼层切换 #7](https://github.com/sd5913/ae4pa/pull/7)，目标 main。用户已授权合入，最终合并状态和 main 提交以该 PR 页面为准；保留长期 A 分支。
- 本轮兼容性只读复核未发现 A-07 新增的 Critical／Important 问题；发布候选代码与已验证的干净源码副本一致。58 个本地 Markdown 链接与空白检查通过，成员原有进度记录完整保留。

## 2026年11月7日 main 合入确认与 A 后续任务检查（Asia/Shanghai）

- GitHub 实时查询确认 PR #7 已合并，main 为 `f8504ae0fa0179bbc58f4611be21da5d1c1cf5cd`。本机 origin/main 已指向同一提交，与原 A 分支 `0b4fbd1` 文件树完全一致，只多出合并记录。
- 本轮 fetch 曾被自动审批服务 HTTP 403 阻止，未执行；通过 GitHub 只读接口核实 main 后，经正常审批执行 `git merge --ff-only f8504ae0fa0179bbc58f4611be21da5d1c1cf5cd` 成功，将当前 `work/member-A-liuling` 快进到该 main 提交。没有改写远端分支或丢弃本地修改。
- 保留此前未提交的 `docs/progress.md` 交接记录和 `project.godot` 编辑器设置。后者仍以 core_test 为本机默认入口，未擅自恢复为仓库 main 入口；它不是新发布配置。
- 对照实际源码确认：main 有三卡／双槽／员工与三状态独眼门，但 floor.gd 仍只放置标记，没有实例化和 setup 员工／门；GameManager 尚无 retry_floor、rescue_friend、win 或返回菜单实现；scenes/ui 无正式组件。
- 推荐依次推进 A-05（1F 放入三员工、绑定 Player、真实偷卡与集齐上楼）→ A-06（测试走廊或 2F 接入独眼门并连接失败反馈）→ A-09（本层重试逻辑及后续 D 按钮连接）。A-08 的救援和跟随也可独立制作逻辑，再接 D 对白；3F 救援后重试／装备恢复细节仍需确认。
- 现有 B 正面偷卡仍只拒绝而不报告 STAFF_CAUGHT，C 其他四怪／offset、D UI 仍待交付或协调；本轮未代改这些模块。只同步合并记录、读源码和更新本记录，没有功能变更；未重复运行 Godot，不把上一轮五项回归结果写成今日新增验收。

## 2026年11月7日 A-05 员工与卡片接入（Asia/Shanghai）

- 用户授权先做 A-05，并明确 B 正面偷卡下一步自行迭代；保留现有拒绝操作，不在 A 端代写失败判定，不记 T01 通过。当前分支 `work/member-A-liuling`，起点 `f8504ae`；已有进度和 project.godot 本机设置原样保留，本轮未提交／推送。
- 代码：`scenes/levels/floor_1.tscn` 在既有三个 Slot 下实例化 B 同一个 staff.tscn，仅配置 card_id；`floor.gd` 绑定同一 Player、连接 card_stolen，显示真实朝向／附近长按／偷取中／已取得文字，转发 notice_requested 临时反馈。移除原员工圆形占位，没有改 B 脚本或复制卡片数据。
- 入口：`scenes/main.tscn`／`.gd` 从原空走廊改为注册楼层宿主并开始真实 1F，读取 CardManager 更新收集数、双槽和当前卡；`floors_test.tscn`／`.gd` 同步获得／失败反馈并保留明确的开发跳层。两者“开发新局”都调用 start_game，重新偷卡，不冒充本层重试。B/C 原 F6 和 test_corridor 保留。
- 新增 `staff_floor_smoke.gd` 及 UID：首次运行因缺少三员工实例而退出 1；实现后使用真实 InputEventAction E／Q、Area2D 检测及正常长按计时完成三卡获取和去重，验证远处 E、提前松键取消、缺卡与两卡不能上楼、第三张留背包、一次 Q、真实 E 上 2F、拥有卡／双槽／当前卡保留、入口重定位、回头失败与开发新局。成功路径固定员工朝向、重新摆放主角以缩短走路；回头失败调用 B 超时处理函数，不能代替自然转身节奏的人工试玩。
- 调试证据：瞬移主角后员工检测区要到第三个物理帧才退出，前两帧仍可能接走 E；用临时诊断脚本观察 overlap 和范围标记后，把自动测试的瞬移准备改为等待 4 个物理帧并确认检测区已退出，没有因此改变实际输入规则。首次加载 B 场景的旧 UID 缓存警告经 Godot 重新导入消失，未改 B 的 UID 文件。
- 回归：foundation_smoke 更新为检查新 3600 宽主楼层及保留的 2800 测试走廊，开始新局后重新取得已重载的 Player，继续检查移动／失败锁定／相机。没有删去既有行为检查来迁就新入口。
- 干净源码副本 `ae4pa-a05-clean-c_m29y4z` 不含 `.git`／`.godot`，project.godot 使用 HEAD 正式入口；重新导入退出码 0。6 项检查均 PASS、退出码 0：staff_floor_smoke（--max-fps 120）、foundation_smoke、floor_flow_smoke、B staff_core_smoke.tscn、C door_cycle_smoke（--max-fps 60）、C eye_door_smoke。真实可执行文件为本机 Downloads 下 Godot.app，日志为 `/tmp/ae4pa-a05-check-*.log`；受限运行仍有已知 macOS 证书和编辑器设置保存错误，不报告零错误。原工作区的自定义默认入口未改写，正式 F5 配置断言在干净源码副本执行。
- 实际画面：Mac OpenGL 4.1 Metal／Compatibility 运行 main，用 E 获得三卡并上楼，查看 1280×720 的靠近、长按、保安卡成功、三卡齐全和 2F 截图（`/tmp/ae4pa-a05-before.png`、`holding.png`、`security.png`、`three_cards.png`、`floor_2.png`，均带相同 ae4pa-a05- 前缀）。中文、角色、临时双槽和获得提示没有重叠；截图不作为正式素材提交。本次未人工鼠标／自然时序完整试玩。
- 只读审查未发现 Critical／Important 问题，指出两条反馈断言可能假通过：初始提示非空、CLEANER 已出现在备用槽。已改为检查实际获得的卡名和明确的当前卡字段；在临时副本断开通知／刷新连接后确实观察到四条预期失败，恢复真实连接后再次 PASS、退出码 0。生产文件未做测试性断连。
- 更新 README、接口、组员接入、分工当前状态、PLANS 和 `a05_staff_plan.md`。A-05 接入部分完成，任务 08 仍进行中；下一步 A-06 接 C 的真实独眼门。房门、正式 UI、背包、重试、救援、结局和 Windows／导出没有在本轮标记通过。

## 2026年11月7日 A 本机 Godot／VS Code 连接修复（Asia/Shanghai）

- 用户报告 VS Code 语言服务器连接失败及 Godot 外部编辑器启动失败。核对本机发现 Godot 已启用外部编辑器但 exec_path 为空，语言服务监听 6005；当前 Godot Tools 插件默认连接 6008。
- 保留用户新建的 `.vscode/settings.json` 中既有 Godot 程序路径，仅加入 godotTools.lsp.serverPort=6005；该文件含本机路径，未提交或当成团队通用配置发布。
- 用户明确同意修正为 VS Code 后，通过正在运行的 Godot 编辑器设置 UI 填入本机 Code 可执行文件和 `{project} --goto {file}:{line}:{col}` 参数，保持使用外部编辑器开启；没有改游戏脚本或共享项目设置。
- 验证：读取保存后的 Godot 设置与工作区 JSON，路径、参数和 6005 端口符合预期；lsof 观察到 Code 与 Godot 在 6005 上双向 ESTABLISHED。Godot 双击脚本后原错误计数仍为 4，没有新增同类外部编辑器错误；未将旧日志计数当成新错误。此次没有重新运行游戏回归。

## 2026年11月9日 A 同步最新 main（Asia/Hong_Kong）

- 用户授权拉取最新内容。先 fetch origin，再在原 work/member-A-liuling 分支从 f8504ae 快进至 origin/main 的 df4a3eb283d8588122c661404771a7aeade10d94；未切换分支、提交、推送或改写远端。新增内容为 B 卡片边界测试及 C 五怪规则、offset、多门测试与组件交接。
- 同步前保存 18 个本地文件的临时字节备份，并建立安全 stash 0540f21c3721efaf743491e89da4ae1bd7f62c59，恢复后保留该快照。进度文档因双方追加而冲突，完整保留 C 与 A 两方记录；接口文档自动合并并检查两方改动。其余 16 个原文件与备份逐字节一致，所有本地修改恢复为未暂存状态。
- 验证：干净临时源码副本 ae4pa-pull-verify-20261109-evic8ywy 使用 HEAD 的正式 project.godot，工作区本机入口与 VS Code 配置不改写。Godot 4.7.2 headless 导入退出码 0；以 --max-fps 120 运行 foundation_smoke.gd、staff_floor_smoke.gd、monster_rules_smoke.gd、door_handoff_smoke.gd，均输出 PASS、退出码 0。日志 /tmp/ae4pa-pull-*.log；受限环境仍有 user:// 日志写入、macOS 证书和导入时编辑器设置保存错误，未报告零错误。git diff --check 通过，无未解决的 Git 冲突。
- 限制：本轮只同步代码及验证兼容性，没有将 C 房门装配进主流程，没有更改员工分布或策划规则，也没有代记人工试玩、Windows 或导出验收。

## 2026年11月10日 V4 策划与 ABCD 分工本地审阅稿（Asia/Hong_Kong）

- 用户要求：按新版 PDF 检查整体改造范围，更新仓库策划与详细 ABCD 分工，先看本地文件再上传 GitHub。本轮进一步确认“按里程碑安排，日期待定”，不沿用原 11 月 25 日交付承诺。
- 开工基线：`work/member-A-liuling`，HEAD `df4a3eb`，相对个人 origin 分支 ahead 6；已有 A-05 源码／文档、project.godot 和 .vscode 本机改动。先将原文档及 89 个已跟踪／非忽略未跟踪文件的 SHA-256 摘要保存在临时目录 `ae4pa_v4_review_baseline`，没有切分支、stash、重置或覆盖游戏文件。
- 来源：读取用户提供的 V4.0 PDF 共 15 页，系统无 Poppler／pypdf，使用本机 Swift PDFKit 提取全部文字并渲染页面，核对卡片、任务、检查点、分工、验收表；临时文字和页面放 `ae4pa_v4_pdf`，不进源码。Swift 默认模块缓存受沙箱限制，改用临时目录缓存后成功，不需要改系统配置。源 PDF 未更改、未复制上传。
- 当前事实核对：阅读 GameManager、CardManager、Staff、Door、Floor 及相关文档；B 员工／三卡、C 五怪／offset 已有，本地 A-05 已接 1F；任务、回访、检查点、工作点、剧情门和正式 UI 仍待实现。GitHub 连接器只读读取 main 的 `docs/team-plan.md`，确认远端仍为分工 1.0；没有执行 fetch 或远端写入。
- 核心文档：`docs/game-design.md` 改为 V4.0 整合审阅稿，包含五任务全流程、工作权限、普通退回／剧情拦截、回访、快照、笔记和门表；`docs/team-plan.md` 升级 2.0，保留 ABCD，分成 28 个成员任务，逐项写前置、步骤、交付与验收，采用 M0—M4；新增 `docs/v4-migration.md` 汇总源码影响、PDF 页码、10 项衔接建议和后续上传范围。
- 配套文档：PLANS 新增 V4-00—08 队列，原 01—12 清单完整归档到 `docs/archive/plans_v3.md`（仅调整相对链接）；接口保留旧兼容事实并新增尚未实现的 §13 提案；QA 保留旧证据／V3 用例，新增 14 项 V4 主线与 14 项边界检查，均未执行。同步 README、AGENTS、onboarding；a_week_1／a05_staff_plan／a07_floor_plan 只增加旧阶段提示，历史正文保留。
- 规则区分：源案明确与整合建议分开。提前偷卡、背包暂停中的核验、双向退回、接受后的工作路线、任务 03 批准即完成、卡片边界、救援后回访、笔记解锁、计时边界等仍待审阅。卡片“永久”按源案检查点例外处理：撤销本任务所得，保留前序已完成成果。
- 独立文档审查：只读 builder check 发现源案 401 在 402 接任务前，无法自然承担任务 04 倒计时教学；已统一改为接取前停步复习并注明原因。其余主策划／ABCD／里程碑与来源未发现重要遗漏或分工冲突；配套文档完成后的第二次定向只读核对也未发现接口 §13、PLANS 与 V4 QA 的显著矛盾。没有把审查当作运行游戏验收。
- 文档验证：`git diff --check` 无诊断；临时脚本检查 16 份 Markdown、95 个本地链接（含 5 个标题锚点）、591 个表格行、ABCD 编号及 V4-T／E 状态，退出码 0。原 PLANS 归档与改稿前内容在调整链接后完全一致，既有 progress 历史完整保留；文件摘要对照显示本轮没有任何非 Markdown 文件变化，原 A-05 脚本／场景、测试、project.godot、.vscode 原样保留。
- 限制与交接：只完成文档稿与静态检查，未运行 Godot、未实现新功能、未新增人工／跨机器／导出／主线通过记录；未暂存、提交、推送、创建 PR 或合并。用户先审阅两份主文档与改造说明；确认后再核对最新远端，准备仅含已审阅文档的提交，避免把当前 ahead 历史和未审阅 A-05 代码混入上传。

## 2026年11月11日 V4 文档上传准备（Asia/Hong_Kong）

- 用户已审阅上一轮文件并明确回复“可以 上传更新一下”，本次只发布 V4 主策划、ABCD 分工及配套 Markdown，不发布本地 A-05 游戏代码、测试脚本或机器设置。
- GitHub 实时读取 main 指向 `df4a3eb283d8588122c661404771a7aeade10d94`，与当前本地 HEAD 一致；没有新的远端成员改动需要合并。原 A 分支、索引和未提交游戏文件保留，发布使用独立文档分支。
- 发布前仅调整文档状态、授权日期及共享运行入口：共享 main 仍是公共测试走廊，A-05 的 1F 员工接入和 staff_floor_smoke 仍仅在 A 本地，避免成员误以为本次文档包含这些代码。28 项分工和里程碑未改变，标注的衔接建议仍按 M0／相应功能阶段确认。
- 验证：`git diff --check` 无诊断；16 份 Markdown、95 个相对链接、5 个锚点、591 个表格行、成员任务编号和 V4 未执行状态检查通过。文件摘要核对无非 Markdown 改动；本轮为纯文档发布，不重跑 Godot，不新增游戏／跨机器验收。
- 本条记录发布准备事实；实际分支、提交和 PR 结果将在上传成功后追加。GitHub 分支／PR 状态为远端发布依据，不预先声称已合入 main。

## 2026年11月11日 V4 文档分支上传与 PR（Asia/Hong_Kong）

- 以 GitHub main 的 `df4a3eb283d8588122c661404771a7aeade10d94` 为基线，在仓库外的干净发布副本建立 `docs/v4-plan-20261111`；提交 `88eb446f384c824b859b293fca56e176826becfb`，仅 14 份 Markdown。
- 文档分支已推送至 `origin/docs/v4-plan-20261111`；创建 [PR #10](https://github.com/sd5913/ae4pa/pull/10)，base `main`、head 为文档分支。GitHub 比较结果：ahead 1、behind 0，变更清单恰为 14 份 Markdown，没有 `.gd`、`.tscn`、`project.godot`、`.vscode` 或素材。
- 干净发布副本执行 `git diff --cached --check` 无诊断，96 个 Markdown 相对链接核对无缺失；源码功能未改动，本轮未跑 Godot。A 原工作分支及未提交 A-05 游戏代码、本机设置未被提交或重置。
- 本记录写入时 PR 仍为 open，尚未把它冒充 main 已合并。实际合并状态和 main SHA 须在远端核实后另记。

## 2026年11月11日 A-V4-01／02／03 首轮本地实现（Asia/Hong_Kong）

- 用户以 A 身份要求依当前 `PLANS.md` 与 ABCD 分工继续任务。开工分支 `work/member-A-liuling`，相对个人远端 ahead 6；原有 A-05 代码、V4 文档和 `project.godot`／`.vscode` 本机改动均保留，未提交、推送或改写成员模块。
- A-V4-01：新增 `docs/a_v4_m0_handoff.md`，列出 D-01／02／03／04／09 首轮实施假设、任务／物件 ID、201 路线、E/Q/I 归属和完整调用链。B/C/D 尚未逐项确认，M0 未标完成；后段 D-05—08／10 仍按里程碑待确认。
- A-V4-02：`scripts/game_manager.gd` 新增任务 01 的 AVAILABLE→ACTIVE→READY_TO_SUBMIT→COMPLETED／FAILED 状态、210 秒计时、多个模态 ID 停表、清洁权限与去重、交付结算、超时及有效任务内被抓通知；`get_task_view` 等返回副本。清洁后继续计时，归零拒绝工作／交付。测试先因不存在 `offer_task` 失败，后又抓到“待交付提前停表”和“待交付被抓未更新任务状态”两处错误，修正后 `task_01_smoke.gd` 通过。
- A-V4-03 的最小范围：GameManager 改为经理对白完成标志开放 2F，移除 1F 三卡门槛；记录已到达层、核对真实楼梯位置，允许 1F↔2F。`floor_base.tscn` 增加左端返程点，`floor.gd` 用同一个 E 请求楼梯、更新提示；回到下层时出生在右端安全楼梯。`scenes/main.tscn`／`.gd` 增加明确标注的开发代记经理对白按钮，以便 D 正式对白交付前测试；不把按钮算正式剧情通过。
- 回归：新增 `floor_return_smoke.gd` 验证无卡上楼、远距离／非法目标拒绝、返程出生点及任务／秒数保留；把旧 `floor_flow_smoke.gd`、`staff_floor_smoke.gd` 中“三卡上楼／不准回退”的过时预期改为 V4。保留三卡／双槽的真实 B 数据检查与开发预览隔离。
- 真实验证：本地 Godot `4.7.2.stable.official.ed1daf0bf`。工作区 `foundation_smoke.gd` 因原有未提交 `project.godot` 的 F5 入口为 `core_test.tscn`，仅“F5 uses the shared main scene”断言失败；未为通过测试改动该本机设置。复制当前源码到 `/private/tmp/ae4pa-v4-verify-1h0HlZ`，仅在临时副本将 F5 入口设为共享 `main.tscn`，完成 Godot 导入后，`foundation_smoke.gd`、`task_01_smoke.gd`、`floor_return_smoke.gd`、`floor_flow_smoke.gd`、`staff_floor_smoke.gd` 均打印 PASS 且退出码 0。运行出现 macOS 系统证书诊断；导入时还出现受限用户目录的编辑器设置保存错误，不能称零错误。
- 文档／格式核对：`git diff --check` 退出码 0；本轮相关 Markdown 的本地相对链接检查通过；新增 M0 文档和两份独立脚本均有结尾换行且无行尾空白。
- 限制：任务 01 目前只在独立测试中走通状态接口。B 卡片深拷贝快照／奖励门控、C 201／普通退回、D 正式对白／面板／楼梯 UI 尚未交付；接受前检查点、失败恢复、世界模态冻结、201 实景、任务 02—05、人工试玩和跨机器验收均未完成。当前 1F 旧员工仍可提前偷三卡，2F／3F 现有门标记仍为旧类型，不能把本次称作 201 可玩闭环。

## 2026年11月12日 B 对 M0 接口的反馈（Asia/Hong_Kong）

- 用户转发 B 的截图反馈：B 表示旧员工偷卡、三卡双槽和测试已完成，建议先统一任务解锁偷卡、E 键交互和任务失败卡片恢复，再开发 B 的 V4 增量；并提醒其正面偷卡修复、转身预告和成功反馈可能仍只在 B 本地，不能覆盖或当作已提交。
- A 只读核对当前工作区：`scenes/staff/staff.gd` 仍自行监听 E、没有任务门控；`scripts/card_manager.gd` 尚无导出／恢复快照。原有 A 分支与未提交文件保留，未改 B/C/D 模块。
- 将三项规则写进 `docs/a_v4_m0_handoff.md` 第 6 节，并在 `docs/interfaces.md` 与 `PLANS.md` 指向同一草案。内容明确任务状态／目标 ID、A 唯一 E 路由、B 快照结构与原子恢复、A 的重试顺序及最小验收；A/B 仍需共同确认后才标为冻结。本轮只改协作文档，没有实现新接口或运行游戏验收。
- GitHub 连接器的 open PR 列表查询返回空列表；随后的 B 分支与 PR #8 读取遭 HTTP 403，无法据此核实 B 最新本地修复或其远端状态。本地 Git 历史显示旧 PR #8 已在此前合并，不能据此推断截图所说的新修复已发布。

## 2026年11月12日 A 确认三项 M0 约定（Asia/Hong_Kong）

- 用户以 A 身份回复“按照你的建议来”，确认：接受对应任务后才允许偷该任务奖励，未接任务 E 只提示；正式楼层由 A 为 E 选唯一目标；B 提供卡片深拷贝快照及原子恢复，A 在接任务前保存并在失败重试时恢复。
- 更新 `docs/a_v4_m0_handoff.md` 为“A 已确认，待 B/C/D 核对接法”，列出 B-V4-01—03 的逐步实施和验收；同步 `docs/interfaces.md`、`docs/v4-migration.md`、`docs/game-design.md` 与 `PLANS.md` 的规则状态。D-01 首次开场跳过及 D-02／03／04／09 的剩余细节仍待确认，V4-01 不标完成。
- 本轮仅更新文档，没有修改 B 的员工／CardManager、本地 A 游戏脚本、项目设置或场景；确认接口不等于已实现。未提交、推送或向成员发送消息，B 的本地修复状态仍以其实际分支／PR 为准。

## 2026年11月12日 A 确认的 M0 文档分支推送（Asia/Hong_Kong）

- 用户明确要求先推送 Git。为避免把 A 分支 ahead 提交、未提交游戏代码和本机配置一起发布，在 `/private/tmp` 的干净副本基于远端 main `3611adc3521c538321885fca36c67af1318d0ccb` 新建 `docs/m0-a-confirm-20261112`。
- 初始提交 `b28204212461f6d54422908371f77d62724ab7db` 只含六份 Markdown：`PLANS.md`、`docs/a_v4_m0_handoff.md`、`docs/game-design.md`、`docs/interfaces.md`、`docs/progress.md`、`docs/v4-migration.md`；`git diff --cached --check`、本地链接和空白检查通过，没有 `.gd`、`.tscn`、`project.godot` 或 B/C/D 模块文件。
- 已推送该独立分支；远端只读核对分支指向初始提交，main 仍为 `3611adc`。本条发布记录由后续文档提交补入同一分支；未创建 PR、未合并 main，A 原工作分支及未提交修改未变。

## 2026年11月12日 A 任务资格查询与远端复核（Asia/Hong_Kong）

- 按用户要求读取 AGENTS、README、PLANS、主策划、分工、接口、M0 交接及最近进度；本地仍在 `work/member-A-liuling`，HEAD `df4a3eb283d8588122c661404771a7aeade10d94`，相对个人远端 ahead 6。修改前将 96 个源码／文档文件的摘要及本轮编辑目标的字节备份保存在 `/private/tmp/ae4pa-qualification-baseline-fq3kl5nj`；既有未提交改动保留。
- 远端实时只读核对：GitHub 插件部分查询返回 HTTP 403，普通沙箱的 `git ls-remote` 无法解析 github.com；随后经允许的只读联网命令 `git ls-remote origin refs/heads/main refs/heads/docs/m0-a-confirm-20261112 refs/heads/work/member-A-liuling` 与 `gh api`／`gh pr list` 核实，main 已是 `9f8cb9eb986c35702497780e360bc21cc5fa2306`，M0 文档分支仍为 `f2f474103c454914601403fe5173ebe7f2168190`。[PR #11](https://github.com/sd5913/ae4pa/pull/11) 为 MERGED，合并时间 2026-11-12 15:48:22（香港）；该合并的文件清单仅六份 Markdown。此为对既有远端操作的核实，本轮没有 fetch／merge／提交／推送／创建 PR，也没有向组员发送消息。
- `scripts/game_manager.gd` 新增真实 `is_interaction_allowed(target_id: String) -> bool`：只允许 PLAYING、任务 01 ACTIVE、剩余时间大于 0、无打开模态时的保洁员工／未清理污渍资格。保洁卡已拥有则拒绝再次偷取；未知、旧 1F 保安及后续任务目标全部拒绝。查询只读，不替 B 判断距离／朝向／长按／当前卡，不限制为任务接取楼层；B 仍须在开始和奖励前调用，工作结果仍由 A 复核。
- 新增 `scenes/tests/core/interaction_allowed_smoke.gd` 与 Godot 生成的 UID，使用真实两个 Autoload。先运行得到 `FAIL: GameManager must provide the real task eligibility query`、退出码 1；实现后打印 PASS、退出码 0。覆盖未接任务、只看介绍、接受后、已取卡、错误目标、四类模态与叠加、非游玩状态、归零边界、待交付、完成、被抓、超时、新局及查询不改变任务／卡片／世界／时间。测试使用明确的楼层／状态夹具，不冒充实际偷窃或正式 201 路线。
- 真实验证程序为 `/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot`，版本 `4.7.2.stable.official.ed1daf0bf`。临时源码副本 `/private/tmp/ae4pa-qualification-verify-lpzbe_l4` 仅将 F5 入口设为共享 `scenes/main.tscn`，完成 `--headless --editor --path <副本> --import --quit` 后，用 `--headless --path <副本> --script res://scenes/tests/core/<脚本>` 运行新资格检查；另加 `--max-fps 120` 跑 `foundation_smoke.gd`、`task_01_smoke.gd`、`floor_return_smoke.gd`、`floor_flow_smoke.gd`、`staff_floor_smoke.gd`。六项均打印 PASS、退出码 0。日志 `/private/tmp/ae4pa-qualification-*.log`；仍有 macOS 系统证书诊断，导入还有受限编辑器设置保存错误，不称零错误。
- 原工作区也实际运行 `foundation_smoke.gd`，退出码 1，仅报 `FAIL: F5 uses the shared main scene`；本机 `project.godot` 仍以 `core_test.tscn` 为入口，未为测试改写。同步 PLANS、接口 §13.8 与 M0 交接 §7；V4-01 保持未完成。自查本轮增量仅 A 的查询、独立检查与整合文档，未修改 B/C/D 内部模块或已有场景。
- 静态验证：`git diff --check` 无诊断；本轮七个相关文件（含新增脚本／UID 和原先未跟踪的 M0 文档）的行尾／结尾换行检查通过，24 个本地相对链接与 5 个标题锚点均有效。摘要对照确认除本轮五个已有编辑目标外，其余 91 个基线文件逐字节不变；新增文件只有资格检查脚本与其 UID。
- 限制与下一步：当前 1F 旧员工仍未调用资格查询，仍自行监听 E；因此正式任务门控、单目标 E、无任务提示／不被抓及跨组件取消尚未验收。等待 B 的目标 ID／可关闭输入适配／开始取消接法及真实奖励门控，再接 A 路由；B 快照尚未交付，A 检查点与失败恢复不提前实现。201、正式 UI、人工试玩、Windows／导出仍未通过，本轮不将任何 V4-T 主线用例改为已通过。

## 2026年11月12日 A-V4-01 接线清单与 A 独立接入增量（Asia/Hong_Kong）

- 开工仍为 `work/member-A-liuling`、HEAD `df4a3eb`、相对个人跟踪分支 ahead 6，98 个现有文件的字节备份与摘要放 `/private/tmp/ae4pa-201-core-baseline-hiwo0rn7`。旧 A-05、Player、主场景、项目设置和所有已有修改保留。本轮没有 git 同步、暂存、提交、推送或合并，GitHub Desktop 操作留给用户，没有向成员发送消息。
- 实时读取 GitHub main 提交、compare 和 V4 文档：main 仍为 `9f8cb9eb986c35702497780e360bc21cc5fa2306`，比本地 HEAD 多六个提交，差异清单仅 15 份 Markdown；main 的 GameManager 仍是旧三卡／单向楼层实现。部分长文档的插件查询返回 403，改以只读 `gh api` 取得固定 SHA 下的两份文档。开工时 AGENTS、主策划、分工、migration、QA 与 main 一致；PLANS／interfaces 有上一轮 A 本地查询增量。本地尚未同步；同名修改文档及 main 已有而本地未跟踪的 a_v4_m0_handoff／archive 等有覆盖／合并风险，未替用户处理同步。
- A-V4-01：`docs/interfaces.md` 新增 §14 201 逐项接线表，写出真实可用与待实现签名、get_task_view 精确载荷、唯一数据归属、B/C/D 下一接线位置、E 优先级、core 入口与正式 F5 门槛。提前偷卡／快照／唯一 E 保持 A 已确认；用户本次重申的工作路线、交付开路、回 2F 待接受及普通退回保任务已列明。安全点具体坐标、完整世界冻结／背包核验、归零与交付同帧统一调度仍待核对，M0 未标完成。
- A-V4-02／03 增量：`scripts/game_manager.gd` 新增 `is_world_input_allowed()`／`modal_changed()`，模态期间拒绝世界工作、交付和楼梯；重复设置模态去重，接受任务须仍在 2F。交付成功写 `passage_201_unlocked`，清理只变待交付并继续计时，往返不清事实。没有添加任务 02—05 或卡数据副本。
- A-V4-05 的独立部分：`scenes/levels/floor.gd` 对正式楼层员工实例关闭自带 E 监听，A 选择唯一员工／楼梯目标，按优先级、水平距离、固定 ID 排序。资格不足只提示，接受长按后锁定，松键／离开／尝试移动／换卡／模态／失败／卸载均取消，换层或 UI 关闭后不得用同一 E 连触。A 调现有 B 开始／取消接口，不改 staff.gd。B 独立 F6 和内部奖励资格复核仍是旧基线；正面失败仍待 B，不把 A 适配当成 B 新组件验收。
- `floor_2.tscn` 将 201 改为 NOSE，202—205 移到 x1550／2000／2450／2900 并按 V4 门表重排。新增污渍接入位 x980、接取安全点占位 x560／右侧占位 x1120、路障 x1250；未交付时沿用 Player 的水平边界限制到 x1226，交付才撤销，回访按 A 状态重建。201 仍是 Marker，没有 C 拦截；污渍尚无 B 组件；两个安全点没有 C 验收，不能算重试或普通退回已实现。
- 新增 `scenes/tests/core/task_01_core_test.tscn`／`.gd`：F6 开发入口复用真实楼层、Player、两个 Autoload 和 B 员工；代记经理对白、任务介绍／接受、工作结果／交付与失败按钮明确标记。清洁仍查当前卡，不自动授卡；**没有假快照，重试禁用**。所有状态读取管理器，不另存计时。README、PLANS、M0 §8 和 QA 入口说明同步，V4-T 用例状态没有改为通过。
- TDD：新 `world_interaction_smoke.gd` 首次以“A floor must expose its unique E target”退出 1，新增路由后通过；新 `task_01_core_smoke.gd` 首次因缺少 core 场景退出 1，创建后通过。旧 staff_floor_smoke 的提前偷三卡断言按预期失败，迁移后保留真实保洁 E／松键／反馈、Q、双槽／第三卡、楼层保留、回头被抓及新局检查；保安／经理卡改为明确的库存夹具，真实三员工旧独立验证另跑 B 原检查，不把夹具当后续任务。
- 最终自动检查：实际 Godot 为 `/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot`，版本 `4.7.2.stable.official.ed1daf0bf`。临时副本 `/private/tmp/ae4pa-201-core-verify-7vuv443z` 仅把 F5 设为共享 main，完成 `--headless --editor --path <副本> --import --quit`，退出码 0。使用 `--headless --path <副本> --max-fps 120 --script res://scenes/tests/core/<脚本>`，八份脚本 foundation_smoke、task_01_smoke、floor_return_smoke、floor_flow_smoke、staff_floor_smoke、interaction_allowed_smoke、world_interaction_smoke、task_01_core_smoke 均 PASS／退出 0；另运行 `res://scenes/tests/staff/staff_core_smoke.tscn`，B 原检查也 PASS／退出 0。最后为旧实例延迟事件风险补测“长按中换层立即取消且旧员工不延迟授卡”，world_interaction_smoke 再次 PASS／退出 0。日志 `/private/tmp/ae4pa-201-final-*.log`；仍有已知 macOS 系统证书诊断，导入有受限编辑器设置保存错误，不称零错误。
- 原工作区 `foundation_smoke.gd` 实际退出 1，仅报 F5 入口断言；本机 `project.godot` 仍指 `core_test.tscn`，未覆盖。新 core 场景首次沙箱内原生图形运行退出 134；经允许的本机图形运行后使用 OpenGL 4.1 Metal／Compatibility，临时截图脚本退出 0，`/private/tmp/ae4pa-201-core-preview.png` 已目视核对，1280×720 中文、按钮和状态显示无重叠。该截图只检查开发入口画面，不代表人工完整路线试玩或 F5 主线验收。
- 自查与限制：本轮未改 B/C/D 内部脚本，Player、主场景与项目设置字节保持不变；只修改 A 管理器、楼层、core 测试及整合文档。B export_snapshot／restore_snapshot、正面任务失败／奖励复查／清洁，C 201／普通退回，D 正式页面仍缺。A 接取前检查点与恢复、普通安全退回、201／工作 E 尚未实现；同帧统一调度和完整世界暂停未冻结。下一步按接口 §14.3 接 B → C → D，再做真实 F5 正常交付、被抓恢复、超时重试、普通退回；本次不能宣称这四条已通过。
- 最终静态检查：`git diff --check` 无诊断；18 个本轮修改／新增文件的行尾和结尾换行通过，51 个本地链接及 10 个标题锚点有效。相对开工备份仅 11 个已有文件变化、7 个新文件（3 份 GDScript、3 份 Godot 生成 UID、1 份 core 场景）；其余 87 个现有文件逐字节一致，包含旧 A-05 场景／主场景、Player、project.godot、.vscode 和 B/C/D 模块。提交、推送和合并继续由用户操作。

## 2026年11月12日 C 交接反馈与 A 版本核对（Asia/Hong_Kong）

- 用户转发 C 的完成报告：独立组件具备 STORY 201、介绍／交付事件、request_interaction、普通违规事件、来向采样／单次保护及 finish_safe_return；下一步由 A 接入和联合验收。按接收评审反馈的流程先核对实际版本，不将报告直接视为已收到组件。
- 本地仍在 work/member-A-liuling、HEAD df4a3eb；保留全部现有修改。`scenes/doors/v4_handoff.md` 不存在，实际 monster_door.gd 仍直接 GameManager.fail，无新增 V4 信号和方法。GitHub 插件返回 HTTP 403，改用只读 gh api 检查已知 C 分支 work/member-C-yinshiqi：HEAD 为 ce95720f63905d3698bf3da0f5715c2d8f535aac；该分支和 main 的 doors 目录内容 SHA 相同，均无 v4_handoff.md。无法据此确认其他分支或 C 本机未发布版本；需 C 提供新版所在分支／提交或 PR、文件与测试结果。
- 布局区分：C 引用的共享旧场景 201/EYE、202/x1150，不是 A 当前未提交布局。本地已有 201/NOSE x700、202/EYE x1550，但 201 确实仍是 Marker。临时 Python 距离计算显示，假设全部半径 90，x560 距 201 为 140，x1120 距 201／202 为 420／430；仅排除该假设下的静态半径重叠，不代表真实 STORY 触发、安全退回或重试安全点通过。
- 更新接口 §14.3 与新增 §14.6，分别记录“C 已报告完成／A 未取得对应代码／未联合验收”；补充 A 接入时必须绑定 rule_violated 的来源门、由唯一 E 调 request_interaction，安全退回恢复时协调 finish_safe_return，具体返回和抑制语义待实际源码。没有给两参数事件虚构 room_id 参数。
- 本轮只更新两份整合 Markdown，未修改 A/B/C/D 游戏脚本、场景或本机设置，未执行 Godot、不新增游戏通过记录；未 fetch／同步／提交／推送／合并或向 C 发送消息。下一步先取得准确组件版本，再进行 A 的场景接入与安全退回实现。

## 2026年11月12日 D 实际接口答复与保洁交付反馈（Asia/Hong_Kong）

- 用户转发 D 的接线问题，核对当前 GameManager、floor 输入和接口 §14 后，新增 §14.7：任务／楼层真实返回、读取时机、HUD 只读刷新、三个操作完整签名／拒绝语义、多模态集合、关闭 E 的 D 消费与 A 松键保护、任务失败与尚未实现的普通警告通知。序章结束与经理对白结束分开，只有经理结束回调调用 complete_manager_intro，PLAYING 与重复调用条件照真实代码说明。
- 在不改变工作区代码的情况下，复制当前源码到 `/private/tmp/ae4pa-d-interface-probe-ivvrdwg0`；Godot `4.7.2.stable.official.ed1daf0bf` 先 `--headless --editor --path <副本> --import --quit`（退出 0），再用临时 `d_interface_probe.gd` 调真实两个 Autoload／楼层（退出 0）。为取得确定的接受瞬间 210 秒，探针关闭自动 process，只通过明确的 _process 调用推进；未伪造管理器返回值。
- 实际输出：新局任务 NONE／0 秒、经理前楼层 []、经理后 [2]；真实楼梯上 2F 后列表 [1]。介绍 AVAILABLE／0 秒；打开 TASK_OFFER 模态时 accept 返回 true，任务快照为 TASK_01_CLEAN／ACTIVE／210.0／CLEAN_STAIN／STAIN_201／CLEANER，面板未关时手动推进 10 秒仍为 210；重复接受 false。关闭后推进 1.2 秒为 208.8；BAG 与 PAUSE 共存后只关 BAG，推进 10 秒仍为 208.8、楼梯请求 false；关 PAUSE 后有效楼梯返回 true，回 1F 列表 [2]。
- 信号枚举实际存在 task_updated、task_failed、game_failed、floor_changed、modal_changed；无 safe_return_started。D 用 task_failed 打开任务失败页，避免兼容 game_failed 重复开页；普通门警告仍待 A 实现安全退回通知，正式重试继续禁用。计时无逐帧更新信号，HUD 仅读 GameManager 的剩余值，不另计时；经理标志完成无专用列表信号，需要结束回调协调刷新／每次开页读取。
- 日志 `/private/tmp/ae4pa-d-interface-probe.log` 和 import 日志；仍有已知 macOS 系统证书诊断，导入还有受限编辑器设置保存错误，不称零错误。仅验证 A 接口返回与边界，没有运行 D 新视觉小说／正式页面、B 新组件或正式 F5 路线，不新增这些通过记录。
- 同次第二段标为 C 但正文属于 B-V4-01～03，记录在接口 §14.8 为“B 模块反馈、发送者标注待核对”。成员报告准备提交 B 分支／PR；本机仍无快照方法、无 scenes/work，Staff 未新增所报信号。等待确切 PR、公开签名、资格／E 适配、工作／失败事件和测试后接入，不假定代码已发布或已取得。
- 本轮只改接口与进度两份 Markdown，保留当前分支和全部已有修改；未改游戏代码／项目设置，未同步 Git、提交、推送、开 PR、合并或向成员发消息。

## 2026年11月12日 五层背景接入预览与 C PR #12 发布核对（Asia/Hong_Kong）

- 用户提供仓库根目录的 hotel_floors_4k.zip，要求查看五层背景如何用于当前游戏，同时转发 C 新版分支／提交／PR。开工检查仍为 work/member-A-liuling、HEAD df4a3eb、相对个人跟踪分支 ahead 6。106 个现有文件摘要与本轮文档编辑目标的字节备份保存在 `/private/tmp/ae4pa-floor-art-baseline-w_foddjq`。
- 压缩包只有五张 PNG，均为 3840×2160。解出明确文件名到 `assets/backgrounds/floor_1.png` 至 floor_5.png，逐字节核对与 ZIP 对应文件一致。使用原 PNG，Godot AtlasTexture 取透明内容范围，区域分别为 `(0,806,3840,548)`、`(0,866,3840,428)`、`(0,866,3840,428)`、`(0,845,3840,470)`、`(0,736,3840,688)`。选用 0.9375 等比缩放到现有 3600 宽，按每层地面线对齐世界 y560；未把 16:9 全画布连同大面积透明区压成走廊。
- 图片审阅发现：1F 已画入经理／保洁，3F 有柜台人物、5F 有经理及两名逃跑人物；2F 的 204 警报与 205 开门是静态绘制。3F 为 301／302／303／304／309，缺 V4 普通门 305；5F 只有 501／502／503，缺 504／505。图中门位与 A 当前 Marker 不完全重合，尤其 202 当前 x1550 位于原图 202 右侧。正式可玩接入需拆出人物、门扇、警报等动态层，补齐门号并按实际工作路线安排门／工作点和路障。
- 为先查看效果，新增 A 独立入口 `scenes/tests/core/floor_art_preview.tscn`／`.gd`，复用 HotelPlayer 和当前移动输入。支持五层按钮／物理数字键切换、横向相机跟随与边界；用“显示当前主线接入点”从现有楼层场景读取门／员工／污渍／楼梯坐标，青色线便于与画面比较。预览主角的 Visual 子图形放大 2.4 倍以观察人物比例，取景与脚底校准是本轮实施选择。正式任务流程、E 行为和安全退回仍由现有 A 主线及后续组件接入负责。
- 验证在干净临时副本 `/private/tmp/ae4pa-floor-art-verify-j6eqqbmf` 完成。实际程序为 `/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot`，4.7.2.stable.official.ed1daf0bf。`--headless --editor --path <副本> --import --quit` 退出 0，临时 `floor_art_probe.gd` 运行全部五层按钮、图片选择／透明取景／等比 3600 宽、主线接入点显示、物理数字键、左右移动及边界，输出 PASS／退出 0。临时辅助分析脚本首次误用不存在的 Image.has_alpha，已改为读取格式与 used_rect；该脚本仅在 /private/tmp，不进入项目。
- 原生图形使用 OpenGL 4.1 Metal／Compatibility，临时捕获脚本渲染五层与接入点覆盖图，保存 `/private/tmp/ae4pa-art-preview-1.png` 至 `-5.png` 和 `-alignment.png`，退出 0。五层图片已逐张目视检查，脚底、比例、取景和预览控件可读。日志 `/private/tmp/ae4pa-floor-art-*.log`；headless 仍有已知 macOS 证书诊断，编辑器导入还有受限设置保存错误。生成的 PNG import 描述与脚本 UID 随源素材保留，资源引用均为 res://。
- C 交付核对：GitHub 插件仍返回 403，首次 gh 查询 TLS 握手超时；只读重试 REST 后确认 [PR #12](https://github.com/sd5913/ae4pa/pull/12) 为 merged=true／closed，head 为 1379a16b7f563783a57a93fe15de82c4be6d468d。已读该提交的 scenes/doors/v4_handoff.md，明确 set_story_state、request_interaction、finish_safe_return、story_radius=120，以及 TEST DOUBLE／未联合验收。接口 §14.3／14.6 更新该发布状态，当前 A 本机仍为旧门代码，正式同步与接入依用户既有 GitHub Desktop 流程推进。
- 本轮新增五张背景及 import 描述、独立预览场景／脚本／UID，共 13 个文件，更新 README、接口和进度。最终摘要核对确认其余 103 个现有文件逐字节保留，含现有任务／Player／楼层／主场景源码、project.godot 和其他成员模块；系统元数据 .DS_Store 单独保留。PNG 与压缩包原文件一致，文本空白检查及 git diff --check 通过。正式主线、C 联调、人工全程和平台导出仍待验证。提交／推送／合并由用户操作。

## 2026年11月12日 A 按三份 CSV 修正与真实门适配（Asia/Hong_Kong）

- 用户授权按功能状态／任务清单／问题与待办三份 v1 CSV 完成 A 部分；CSV 内建议作为待核对资料，不自动扩大 B/C/D 代码或 Git 发布授权。开工仍为 work/member-A-liuling、ahead 6，保留所有已有改动。123 个现有文件的摘要及本轮目标备份在 `/private/tmp/ae4pa-a-list-baseline-dprun7kx`。执行计划及逐项结果为 docs/a_checklist_plan.md／a_checklist_results.md。
- 核对纠正：1F 员工、正式楼层唯一 E、经理标志开 2F 及双向回访已有本地成果，不能按 CSV 当成完全未做；正式对白仍缺。本轮修正 P-09，将 project.godot 的 F5 从 core_test 恢复 main。修改前 foundation 实际退出 1／F5 uses the shared main scene，修改后工作区 PASS／退出 0。
- P-12：新增 scripts/task_definitions.gd，按 V4 定义五项任务的前置／试用时限／地点／来源／步骤／结果；GameManager 增 get_task_definition 深拷贝查询，get_task_view 增 name／location，任务 01 的元数据及接受时限真正读取定义。TASK_02—05 仍不接受／不运行，任务 03 的批准即结算显式标 AUTHORIZE_PROPOSED／D-05 待确认，不越过 M1。
- P-01／05／06／10 的 A 增量：floor.gd 检查真实 V4 能力后在 2F 装配 201/STORY/NOSE 和一扇普通 202/EYE，连接介绍／镜像／进度／交付，ROOM_201 纳入优先级 0 的唯一 E。未接受时限到 x580，接受后能到污渍 x980、锁 x1250 前，交付才开放后段。模态停用门 physics 检测，避免首请求被 UI 吞掉；完整世界冻结和核验暂停继续待定。工作区旧 C 不满足接口时只显示待同步，不实例化旧版整层 fail 门；没有覆盖 C 文件。
- GameManager 实现 request_safe_return／safe_return_started。仅当前楼层登记普通门、合法来向和安全点；拒绝过期／外来来源、未知侧、同帧重复、危险点及跨锁路线。202 左／右点为 x1400／1700；进入 SAFE_RETURN 取消长按、锁输入／检测、移动并重置相机，真实 C finish_safe_return 确认后延迟恢复。普通退回保留任务、卡、世界和余量，恢复原计时；主入口／core 显示临时警告，未接 D 正式页。201 x560／1120 继续是未用于检查点的占位，未代记 C 人工验收。
- TDD：新 task_definitions_smoke 首次退出 1／缺真实查询；safe_return_smoke 首次退出 1／缺 request_safe_return；实现后通过。真实门检查补充“本帧跨过门中心、仍按进入前来向退回”后，曾实际得到两个双向落点 FAIL；根因是 A 错用当前侧否决 C 的进入证据，删除该判断后再跑 PASS，保留回归覆盖。没有修改 C 的来向逻辑。
- 从本机已有 Git 对象读取固定 C 提交 `1379a16b7f563783a57a93fe15de82c4be6d468d`，仅在临时副本 `/private/tmp/ae4pa-a-list-v4-wjyx1076` 还原其 doors／tests。副本实际运行 editor --import --quit，然后真实门集成：201 固定区介绍／E 交付、左右及跨中心来向、任务运行中退回继续扣时、卡／世界保留、剧情区／锁拒绝、同帧去重、旧来源换层隔离全部 PASS。工作结果仍是清晰标注的 A 开发调用，不冒充 B 工作点或完整主线。当前工作区运行该检查实际输出 BLOCKED／退出 2，明确须先同步 C PR #12。
- 实际引擎 `/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot`，`4.7.2.stable.official.ed1daf0bf`。工作区 9 项 core（foundation、task_01、floor_return、floor_flow、staff_floor、interaction_allowed、world_interaction、task_01_core、task_definitions）全部 PASS／退出 0；真实 C 副本相同 9 项及 safe_return、C v4_doors／door_cycle、B staff_core 场景共 13 项 PASS／退出 0。工作区 main 和 task_01_core 场景 --headless --quit-after 3 均退出 0。日志 `/private/tmp/ae4pa-a-local-*.log`、`ae4pa-a-v4-*.log` 及 `ae4pa-a-list-*.log`。
- 新发现并修正导入问题：Godot 默认把根目录三份 CSV 当翻译表，标题中的 `/` 使生成 translation 文件失败。新增三个 `.csv.import`，使用 importer="keep" 保留原文；临时副本再导入退出 0，CSV translation 错误消除。所有 headless 仍有 macOS 系统证书诊断，editor 有沙箱禁止保存用户编辑器设置诊断，不称零错误；未修改系统权限或证书。
- README／PLANS／接口 §15 和逐项结果同步，原 CSV 内容不改。P-02／04／07／08 继续按 B/C/D 分工，B 快照未交付使 A-V4-04 检查点／正式重试仍不可做；后段、人工、两人计时、Windows 与导出留后续里程碑。V4-T／E 状态未代记通过，M1 未标完成。没有 fetch、同步分支、暂存、提交、推送、合并或向成员发消息。
- 最终自查：相对开工摘要仅 10 个既有文件变化、11 个新增文件，无删除；其余 113 个既有文件逐字节不变，包含原 CSV、Player 和 B/C/D 源码。21 个本轮文本文件行尾／结尾换行通过，47 个相对链接与 5 个锚点有效；git diff --check 无诊断。新增 UID 来自 Godot 临时副本真实导入。

## 2026年11月12日 按用户要求拉取最新 main（Asia/Hong_Kong）

- 用户明确要求先 git pull。开工检查 A 分支仍为 df4a3eb、个人远端 ahead 6，存在全部未提交成果。git fetch origin 成功后核对：个人远端无新增，origin/main 比 HEAD 新 10 个提交，且 HEAD 为其祖先；最新为 09bbda9（C PR #12、D 开场 PR #13 已合入）。
- 完整备份到 `/private/tmp/ae4pa-before-pull-7ftgxca4/worktree`，134 个文件摘要及原 HEAD／状态同时保存。执行 git stash push --include-untracked（codex-before-main-pull-20261112），随后 git pull --ff-only origin main，成功快进 df4a3eb→09bbda9，没有新建合并提交或切分支。
- stash apply 出现 PLANS、README、interfaces、onboarding、progress、qa 六份文档冲突及四份已被 main 跟踪的原未跟踪文档重名。逐项比较 main 与拉取前完整备份，确认冲突处本地内容为同一新版文档的 A 后续增量，恢复这些较新内容；a_v4_m0_handoff 同样保留本地后续增量。清除恢复操作产生的暂存／冲突索引，不提交。原始 CSV 的 CRLF 字节也从备份准确恢复；stash 保留作为额外备份。
- 恢复核对：134 个拉取前文件中 132 个逐字节一致，只有原先干净的 C monster_door.gd／README.md 按 main 更新；其余新增的 C／D 文件均来自 main。无意外丢失、无冲突项、无暂存项。HEAD 等于 origin/main；相对个人远端现 ahead 16，未推送。
- 实际在当前工作区用 Godot 4.7.2 运行 foundation_smoke、safe_return_smoke、world_interaction_smoke，三项均 PASS／退出 0。safe_return 已使用拉取后的真实 C 组件，不再是临时副本验证或 BLOCKED。仍有已知 macOS 系统证书诊断。日志 `/private/tmp/ae4pa-after-pull-*.log`。
- README／接口／清单结果增加同步说明，明确先前“工作区 C 待同步”已解除。D 开场已取得但未接主入口；B 快照／清理、D 完整任务页面及正式 M1 验收仍待后续。git diff --check 无诊断。没有提交、推送、发布或向成员发送消息。

## 2026年11月12日 A 接入真实开场／经理并准备集中上传（Asia/Hong_Kong）

- 用户要求拉取后继续可做的 A 工作，完成后一次性 push。开工为 work/member-A-liuling、HEAD 09bbda9、个人远端 ahead 16，保留前面全部 A 改动和 stash；摘要及本轮五个源码目标备份位于 `/private/tmp/ae4pa-intro-baseline-p8fjpkbk`。本轮已明确授权提交／push A 分支，不包含自动合并 main。
- 依据既有 V4／分工和 D PR #13 的真实接口，在 main.tscn 的 StoryLayer 直接实例化 D dialogue 场景，使用 V4_INTRO／V4_MANAGER_TALK。F5／新局先播放真实序章；序章完成只回可操作 1F，必须在 x2400 经理范围内由唯一 E 的 MANAGER_TALK 请求播放经理段，收到对应完成 ID 才开放 2F。主入口的经理代记按钮删除，独立 core 调试入口保留。未改 D 的脚本／场景／TSV／图，也未代定首看跳过规则。
- GameManager 新增 has_completed_manager_intro 只读查询；floor 增 manager_talk_requested，经理谈话优先于偷卡提示，不一键谈话又偷卡。main 登记自己的 STORY_DIALOGUE 模态并同步 Player 移动锁，关闭时只释放自己；对白期间提前消费 Q，B 独立输入不改。D 自己处理 E／鼠标继续，A 保留须松 E 的世界保护。对白时隐藏开发覆盖层，避免透明处点击后面的按钮；卸载时释放模态，新局清会话标志但不把 D 已读标记当经理已完成。
- 新 intro_flow_smoke 首次退出 1／F5 must mount D's real dialogue scene；实现后通过真实输入、TSV、员工 Area、楼梯和两个 Autoload，覆盖序章／经理分别完成、移动／Q、E／鼠标单次推进、模态叠加、关闭 E 不穿透、重复完成、无卡上楼、新局及卸载。初轮测试在瞬移后只等两帧，员工 Area 尚未更新，增加到现有检查惯用的四个 physics 帧并等 process 后通过；没有改 B 检测。测试已读文件专用 /private/tmp，不污染用户实际已读记录。
- foundation 原移动测试在新增真实序章期间失败两条左右移动断言；迁移为通过真实 D 继续按钮完成序章后再验移动，保留锁输入和全部旧底座有效覆盖。没有把“序章锁移动”修成可以穿透的移动。
- 当前工作区最终 15 项：11 项 core（foundation、task_01、floor_return、floor_flow、staff_floor、interaction_allowed、world_interaction、task_01_core、task_definitions、safe_return、intro_flow）＋C v4_doors／door_cycle＋B staff_core 场景＋D intro_preview --ui-smoke，全部 PASS／退出 0。D 独立预览第一次在普通沙箱因 user:// 专用测试文件不能保存而退出 1；获得本机测试目录访问后原脚本重跑 PASS，未改源码绕过。其余普通 headless 仍有已知 macOS 系统证书诊断，editor import 还有用户编辑器设置保存受限诊断，不称环境零错误。日志 `/private/tmp/ae4pa-final-*.log`、`ae4pa-intro-*.log`。
- 使用真实 Godot 原生 Compatibility／OpenGL 4.1 Metal 运行主入口，临时截图脚本退出 0，`/private/tmp/ae4pa-main-intro.png` 和 `ae4pa-main-manager.png` 已目视检查：序章 SMS、经理立绘／对白／继续、全屏覆盖层正常，A 开发控件不露出。不代记真人完整路线／任务节奏通过；经理说话人名字与背景对比偏低属 D 视觉后续项，未修改其组件。
- README／PLANS／接口 §16／清单结果同步，新增 assets/backgrounds/README.md 说明用户提供的五张预览图及缺门／静态人物限制；完整 M1 仍受 B 快照／清理／正面失败和 D 任务面板／HUD／失败页约束，检查点不伪造，后四任务运行不提前启用。
- 上传范围为当前已验证的 A 框架、楼层、任务定义、core 检查、整合文档、独立背景预览及五张引用 PNG／导入描述、用户三份原始 CSV／keep 描述。本机 .vscode、原素材 hotel_floors_4k.zip 和仅显式默认伸缩配置差异的 project.godot 留本地；Godot 缓存不提交。按用户要求只集中 push 到个人分支，不自动创建 PR 或合并 main；最终发布成功以远端 SHA 为准。
- 提交前审查共 64 个文件，B/C/D 模块字节保持不变；70 个本地链接／11 个锚点及所有本轮文本空白通过，git diff --cached --check 无诊断。使用 git checkout-index 导出精确暂存树到 `/private/tmp/ae4pa-release-verify-2cz05vi1`，无本机配置／ZIP／缓存依赖；首次 Godot 导入退出 0，foundation／intro_flow／safe_return／task_01_core 四项在该干净源码副本再验 PASS／退出 0。导入仍只有已记录的宿主设置／证书诊断。

## 2026年11月12日 用户首轮试玩反馈排查与 A 本地修正（Asia/Hong_Kong）

- 用户实际试玩报告：三名员工原地左右转头机械、经理感觉仅背身可交谈、对白后找不到接取任务的位置。按系统排查先核对分支与实际运行链；开工为 A 分支 4dd0890，与个人远端一致，仅既有 project.godot 默认伸缩差异／.vscode／素材 ZIP 留本地。相关文件备份在 `/private/tmp/ae4pa-feedback-baseline-hcgkme60`，这些既有本地内容保留。
- 修改前真实探针 `/private/tmp/ae4pa_feedback_probe.gd`：经理朝左／右×玩家两侧、40px 四组均为 MANAGER_TALK，85px 四组全部无目标。没有复现仅背身才能交谈；确认谈话依赖 B 偷窃 Area 的近距离缓存，不读取方向。三员工 TurnTimer 都为 3.0 秒且同时自动启动，仅翻面对向／眼睛；这是同一占位行为与角色表现问题，不把它描述成已实现巡逻或建议擅自扩展寻路。
- 任务断点定位：真实 C 201 触发后 GameManager 已为 TASK_01_CLEAN／AVAILABLE／0 秒，但 main 对 task_offered 的接收数为 0、画面仍通用提示。正式接受面板／B 污渍组件确实缺失；用户找不到领取入口是当前功能断点，不是完成了 M1 后又出现的用户操作错误。经理应只开放楼梯并指向 2F 201，不在 1F 发任务。
- A 本地修正：floor 新增独立、对称、90px 经理谈话范围，不再依赖偷窃 Area 或朝向；首谈仍优先级 0，谈完后优先级 3 的同一目标 E 只提醒去右梯→2F 201，不再只给“先接任务”偷卡提示。若将来 A 真正开放经理偷窃资格，候选让位于真实偷卡，B 组件不改。头顶提示与谈话范围一致。
- main 接 task_offered／task_updated，增加持续 Objective，并在经理完成后明确指出 2F 201；C 真实介绍后清楚显示接受界面尚未开放、试玩到此。未添加假接受按钮、未自动计时／授卡／完成任务，不把 D 待交付页面冒充可用。F5 完整任务闭环继续未通过。
- TDD：新增 player_feedback_smoke 首次出现 8 条预期 FAIL（四方向谈话范围、请求数、路线提醒、持续目标、201 显示）。实现后全部通过。旧 world_interaction 在等距比较处因经理的新路线提示仍使用 MANAGER_TALK ID 而实际失败 1 条；只迁移该合法目标预期，保留等优先级／等距按固定 ID、不同距离取最近及原真实偷卡覆盖，之后通过。
- 最终 Godot 4.7.2 当前工作区 7 项检查：player_feedback、foundation、intro_flow、world_interaction、safe_return、staff_floor、task_01_core 均 PASS／退出 0。新范围检查覆盖实际 B Area 外 85px 的双朝向×双来侧、130px 拒绝、无授卡、一次 E 一请求、初谈后去向；真实主入口／C 门确认 AVAILABLE／0 秒和两处明确提示。日志 `/private/tmp/ae4pa-feedback-final-*.log`；仍有已知 macOS 系统证书诊断。编辑器导入退出 0，生成新检查 UID，另有受限用户设置保存诊断，不称环境零错误。
- 真实原生 Compatibility／OpenGL 4.1 Metal 截图脚本退出 0，`/private/tmp/ae4pa-feedback-manager.png`、`ae4pa-feedback-201.png` 已目视检查：经理头顶范围提示与持续目标、201 试玩终点说明可读，没有被新局按钮遮挡。截图脚本经真实序章／经理继续后到达 201；不代记真人任务成功／失败／重试验收。
- QA 登记 BUG-001（谈话范围／可发现性）、BUG-002（201 静默反馈）为 A 本地已修、待用户复测，不擅自关闭；FB-01 员工角色行为交 B，FB-02 正式接受面板／HUD 交 D＋A 接线，FB-03 清理／快照／正面失败交 B→A 检查点→D 失败页。C 的真实 201 介绍此次正常，无新定位缺陷。README 和接口 §16.1 同步实际范围／试玩边界。没有改 B/C/D 内部源码或发送消息；本轮未提交、push 或合并。
- 最终探针复测：85px 四种朝向／来侧现均为 MANAGER_TALK，而 B 的 steal_range 仍为 false，证明交谈已独立；main 的 task_offered 接收数为 1，201 明确反馈可见且任务仍 AVAILABLE／0 秒。最终 git diff --check、新增脚本／UID 空白、42 个相对链接／7 个锚点通过；B/C/D 组件无 diff，既有本机配置及未跟踪资源保持不动。

## 2026年11月12日 五层场景图占位接入与 main 发布

- 用户要求将 hotel_floors_4k.zip 中的场景图按楼层摆放并推送 main。压缩包五张 PNG 与 assets/backgrounds/floor_1.png 至 floor_5.png 逐字节一致。最新共享基线为 25faec29eaa06a6ea802d74d97c0298d4f62c7ab，已包含 A PR #15 和 B PR #14。
- 在个人功能分支 work/member-A-floor-art、独立工作区 `/private/tmp/ae4pa-floor-art-main` 完成本轮。当前 A 工作区的开工文件摘要位于 `/private/tmp/ae4pa-floor-placement-bew1z7sd/local_manifest.json`，供保留首轮试玩的本地修改时核对。
- floor_base.tscn 新增首个子节点 FloorBackground。五个 floor_N.tscn 分别引用对应 PNG 的 AtlasTexture，采用既有预览的透明内容区域，统一等比缩放 0.9375 至 3600 宽。图中地面线对齐世界 y560，各层背景顶部 y 为 106.25、190.625、190.625、152.1875、-53.125。实际楼层及 F5 序章后的 1F 现可显示图片，Godot 编辑器打开楼层也能看到占位素材。
- 当前图片带有静态人物、门扇和灯光，3F 缺 305、5F 缺 504／505，部分图中门位与交互节点存在偏移。后续美术接入需拆动态层、补门号、校准交互和安全点。此轮完成用户要求的分层场景图占位。
- Godot 4.7.2 的临时实际场景探针 `/private/tmp/ae4pa_floor_placement_probe.gd` 检查五层图片映射、Atlas 取景、等比／3600 宽、地面对齐、背景位于主角之前的绘制顺序及原出生点，headless 与原生图形均 PASS／退出 0。原生 Compatibility／OpenGL 4.1 Metal 截图 `/private/tmp/ae4pa-placed-floor-1.png` 至 -5.png 和 ae4pa-placed-main.png 已逐张目视检查。
- 独立工作区改动前 foundation 回归 PASS，改动后 foundation_smoke、floor_flow_smoke、intro_flow_smoke、safe_return_smoke 四项均 PASS／退出 0。日志位于 `/private/tmp/ae4pa-placement-*.log`。headless 有既有 macOS 系统证书诊断，初次编辑器导入另有沙箱内用户设置保存受限诊断。
- README 和 assets/backgrounds/README.md 已同步实际主场景接法与占位限制。用户已授权这批背景接入提交并推送 main，发布结果由 Git 提交及远端 SHA 核对。


## 2026年11月13日 继续 A 侧：真实 B 接入与任务 01 检查点

- 开工 A 分支 HEAD 4dd0890，保留首轮试玩修正、本机设置和未跟踪资源。因下一步依赖 B/D 交付，本轮 fetch 核对共享 main b4c57d0：B PR #14 已有快照／被抓／清理，D 仍只有对白。完整工作区备份在 `/private/tmp/ae4pa-a-m1-start-ztbud6_o/worktree`；保留命名 stash 后快进 main，再应用原修改，只处理 README／progress 同段冲突并保留两侧内容；全部改动仍未暂存。用户新增 AGENTS 的 A 侧接力规则亦保留。
- A-V4-04：`scripts/game_manager.gd` 接真实 B export_snapshot／validate_snapshot／restore_snapshot；接受前深拷贝卡、世界／已完成／访问／经理／故事事实。新增 can_retry_current_task／retry_current_task，FAILED→RESTORING 取消旧长按，验证新 2F 实际安全点后恢复卡／世界并重建门、污渍、主角和相机；回 AVAILABLE／0 秒、重新发 task_offered，重新接受才 210 秒。无宿主的独立状态测试不创建虚假物理检查点。仅任务 01，不冒充后续任务／309 恢复已实现。
- A-V4-05：`scenes/levels/floor.gd` 给正式 B 员工配置目标和任务资格、连接真实 task_failure_requested，只接当前树内楼层合法来源；`floor_2.tscn` 在污渍位直接实例化 B cleaning_spot。唯一 E 加 WORK，由 A 推进真实长按并接 cleaning_completed→record_work_result；世界事实控制污渍回访显示。移动／松 E／换卡／模态／卸载／失败取消，非游玩或模态消费世界 Q；B/C/D 内部代码未修改。
- 201 接取前落点 x560／y560，捕获与恢复均对实际 C STORY 半径、其他门排除区和走廊边界校验；非法卡快照／危险落点不改原卡与失败世界。普通门仍走 request_safe_return，保留任务／卡／世界／时间，不误接任务重试。未把 x1120 标为已用安全点。
- `task_01_core_test.gd` 更新 F6 开发入口：删除代记清理／交付按钮，开启真实失败后的检查点重试，恢复时清自己的暂停开关；经理／介绍／接受／模拟失败仍明确开发控制。main 的活动目标改为真实清理操作，F5 正式接受／失败 UI 仍缺，未添加假正式面板或自动接任务。README、PLANS、接口 §17、清单结果和 QA 同步现状／D 下一接头。
- 测试先行：新增 `task_checkpoint_smoke.gd` 首次退出 1／缺真实 retry 接口。真实 B/C 输入闭环实现后通过；扩展移除楼层的迟到被抓事件测试，实际退出 1／旧源能误伤新世界，补当前楼层及树内校验后通过。恢复后门检测开关补测也曾实际 FAIL：RESTORING 清模态时停用新门 physics 后未重启；A 状态切换统一按 world_input_allowed 恢复检测，再验真实普通门违规退回。首次移动取消检查在 process_frame 信号前释放输入，修正为让真实楼层观察到一帧持续输入后通过，没有改 B 工作判定。
- 实际 Godot `4.7.2.stable.official.ed1daf0bf`：当前全部 13 项 core（floor_flow、floor_return、foundation、interaction_allowed、intro_flow、player_feedback、safe_return、staff_floor、task_01_core、task_01、task_checkpoint、task_definitions、world_interaction）及 B cleaner_v4／staff_core、C v4_doors／door_cycle 共 17 项均 PASS／退出 0。补来源校验后重新跑 checkpoint 及 foundation／world_interaction／safe_return／staff_floor 均 PASS；开发提示调整后 core 再验；门检测恢复修正后 checkpoint／safe_return／task_01_core／intro_flow／foundation／world_interaction 再验。日志 `/private/tmp/ae4pa-m1-*.log`。覆盖真实成功交付、跨层超时、正面／转身被抓、连续回滚、接取前事实保留、卡通知次数、取消、输入／模态、非法恢复、新局；数据夹具和手动时钟／转身明确限于可重复测试，不算人试玩。
- 原生 Compatibility／OpenGL 4.1 Metal 图形探针退出 0，实际清理位及恢复后接取位截图 `/private/tmp/ae4pa-m1-work.png`、`ae4pa-m1-retry.png` 已目视检查，开发文本可读，恢复后卡空／AVAILABLE／0 秒。渲染探针使用卡片夹具仅核对画面，实际偷卡在 checkpoint 回归中执行。headless 仍有已知 macOS 系统证书诊断，编辑器导入有沙箱内用户设置保存受限诊断，不称环境零错误。
- 阻塞／下次入口：D-V4-02／03 正式任务接受面板、HUD 和失败／重试页；D 按接口 §17 读取 A 状态、监听 RESTORING 关闭旧页，A 接页后跑 F5 四路径，再由 D／用户人工复测。M1、全队冻结、Windows、后续任务、两人计时、导出均未代记通过，不提前做 A-V4-06。当前任务未提交／push／合并，也未发送消息；上轮背景发布不扩大为本轮代码发布授权。

- 最终范围／文档核对：git diff --check 及新增源码／UID 空白检查通过，57 个本地文档链接／锚点有效；B/C/D 内部文件无 diff，本机 project.godot／ZIP／.vscode 与同步前备份逐字节一致，未留冲突或暂存项。


## 2026年11月13日 A 继续：同步新版保洁与 201 链路复测（Asia/Shanghai）

- 用户转发 B 的 main 检查报告并要求继续 A。先核对最近记录及真实代码：本地已有正式 CleaningSpot、完成／被抓接线和任务 01 检查点；B 报告描述共享 main 的未接线状态，不重复覆盖已有实现。开工 HEAD b4c57d0，原有全部 A 改动和本机文件备份至 `/private/tmp/ae4pa-curious-start-pbxrqtis`（180 个文件）。
- 因依赖新版组件，fetch 后核对 main f559dc4，包含 B PR #19 和 C PR #18；变动与本地 A 文件无重叠，直接 ff-only 快进成功，不用 stash、不切分支、不改写既有未提交内容。D 仍只有 dialogue／TSV，正式任务接受／HUD／失败重试页尚未取得。本轮未提交、推送、合并远端或向成员发消息。
- 先运行三份 A 检查：staff_floor／world_interaction／task_checkpoint 实际均退出 1。定位 CURIOUS 在 Area 进入及身份切换时让保洁转向玩家，旧“固定左侧即身后”前置不再成立；world 的固定左侧离开范围也会在检测刷新前穿到正面而失败。未据此改 B 行为或放宽被抓规则。
- 修改 `scenes/tests/core/staff_floor_smoke.gd`、`world_interaction_smoke.gd`、`task_checkpoint_smoke.gd`：等待真实 SuspicionTimer 后依据当前 facing 绕后，在测试里暂停随机转身／走动时钟，保留真实输入、Area、偷卡、失败、清理和交付；身份切换后的好奇也重新等待。检查点新增断言：未识别接近确实 CURIOUS，其间任务 ACTIVE／无保洁卡。main／floor／GameManager 既有实现继续沿用，B/C/D 内部源码无本轮改写。
- 验证环境为本机 Godot `4.7.2.stable.official.ed1daf0bf`。实际执行 `--headless --editor --path . --import --quit` 退出 0；core 使用 `--headless --path . --max-fps 120 --log-file /private/tmp/ae4pa-curious-<检查名>.log --script res://scenes/tests/core/<检查名>.gd`。13 项 core 全部 PASS／退出 0：foundation、floor_flow、floor_return、interaction_allowed、intro_flow、player_feedback、safe_return、staff_floor、task_01_core、task_01、task_checkpoint、task_definitions、world_interaction。B cleaner_v4／staff_core 场景及 C v4_doors／door_cycle／v4_catalog／v4_identity／v4_main_integration 脚本共七项同样 PASS／退出 0，共 20 项；独立组件通过不等于 A 已接入 C 后段目录／换装策略。
- 当前 201 自动链路：真实偷保洁卡→Q 当前身份→长按清理→回 201 E 交付放行；正面／转身被抓、跨层超时后回 2F x560／AVAILABLE／0 秒，再接受才 210 秒；卡／污渍回滚与普通门保状态退回通过。接受 API、前序卡事实、手动任务时钟及确定转身仍是明确测试夹具，不算真人 F5 完整闭环。C 主入口检查的工作位子节点数仍为一，实际为 Work，其旧占位文案不作为清洁验证证据。
- headless 保留既有 macOS 系统证书诊断；首轮并发默认日志写入受限，复测改用各自 `/private/tmp` 日志后未再出现日志文件写入错误；导入仍有用户编辑器设置保存受限诊断。不称环境零错误。本轮仅同步组件、适配测试和更新 README／PLANS／接口／QA／进度，没有新的画面布局改动，未重复截图或代记人工验收。
- 阻塞／下次入口：D-V4-02／03 正式任务接受面板、HUD、失败／重试页。按接口 §17 交页后 A 接 UI 请求及 RESTORING 关闭旧页，运行 F5 成功／被抓／超时／普通退回四路径，再与 D／用户人工验收。M1、全队冻结、202、三楼、Windows、两人计时和导出仍未完成。

- 最终静态核对：git diff --check 无诊断，五份更新文档的 56 个本地链接路径存在；本轮改写仅三份 A 测试和五份整合文档，其他变化来自上述 main 快进。B/C/D 所属文件相对当前 HEAD 无 diff；原 project.godot、ZIP、.vscode 与开工备份逐字节一致，无暂存／冲突项。


## 2026年11月13日 A 继续：接入 D 评审组件并跑通 F5 201（Asia/Shanghai）

- 开工 HEAD f559dc4，按接力规则核对进度与真实代码；fetch 发现 main `0145926`（B PR #20）及 D 评审分支 `work/member-D-v4-ui-review`／`eb5e019`。开工全部文件／摘要备份在 `/private/tmp/ae4pa-ui-start-34swmnn7`，短执行计划在 `/private/tmp/ae4pa-201-ui-plan.md`。
- 保留命名 stash 后 ff-only 到 main；apply 在 floor.gd、floor_2.tscn、staff_floor_smoke、world_interaction_smoke 四处冲突。依据备份保留 A 经理范围、检查点安全点、失败来源校验、模态 Q／唯一 E 和 CURIOUS 测试，纳入 B 真实清理／回访检查。污渍统一为 `Interactions/Stain201Slot/CleaningSpot`，只在实际完成状态与世界事实不一致时调用 B set_completed，避免每帧取消工作。保留 stash，清除 apply 产生的暂存／冲突索引，未丢弃原改动。
- D 分支基于旧历史且含旧对白，原样取得 mission_board.gd／uid／tscn、hud.gd／uid／tscn、failure.gd／uid／tscn、card_display.gd／uid、staff_ui_theme.tres 共 12 文件；未整体合分支，现有 dialogue、TSV 与素材保持原样。选定组件仍未合 main，不能写成 D 全部 UI 已发布。
- 新 A `scenes/task_ui.gd`／`task_hud.gd` 及 UID；main.gd／tscn 装配 TaskLayer。task_offered 打开 D 面板并登记 TASK_OFFER，D 接受调用真实 accept_task，成功后只释放该面板；floor 新 task_offer_requested 支持关闭后门前唯一 E 重开。HUD 保留 D 卡／层订阅，由 A 继承显示中文任务 01 路线／状态；实例内用 VBox 排列 D 两块内容避免重叠。
- D 失败页接真实 can_retry_current_task／retry_current_task，分别显示超时／被抓；RESTORING 关闭旧页，恢复后的 task_offered 展示 AVAILABLE／0 秒，再接受才 210 秒。普通退回不弹任务失败；原菜单按钮在本实例明确改名“重新开始（重播序章）”并接新局。接受页隐藏楼层按钮，仍由真实楼梯 E／距离／许可控制。
- 新 `task_ui_smoke.gd`／UID 初跑实际退出 1／缺 D 组件，接线后通过独立 D 实例与真实 F5／对白／E／D 按钮／B 偷卡清理／C 交付／A 回滚。补叠加模态、E/Q／移动、关闭重开、持 E 接受、旧重试、失败新局和带真实接受模态卸载。位置、任务时钟及转向阶段明确为自动化夹具；没有直接授卡或代记工作来完成 F5 链路，独立 HUD 子测试另有 collect_card 夹具。
- 一次只读独立评审定位 P2：D 旧禁用重试控件残留到恢复／新局后的接受页。两处补测实际 FAIL，A 每次显示时复位后通过。评审 P3 指出原卸载测试没有开着模态，已补真实打开接受页时卸载，并补失败新局按钮。原生 QA 的 HUD 内部状态码和超时页 CAUGHT 标题也经 FAIL→修正→PASS；D 原文件未改。player_feedback 原两条“尚未开放”断言实际失败后迁移为真实面板、待接受／停表及提示，原经理范围覆盖保留。
- 最终 Godot `4.7.2.stable.official.ed1daf0bf`，执行 `python3 /private/tmp/ae4pa_run_ui_suite.py`。逐项 `--headless --path . --max-fps 120 --log-file <独立临时日志>`，14 份 core 以 `--script res://scenes/tests/core/<名称>.gd` 运行，加 B cleaner_v4／staff_core 场景、C v4_doors／door_cycle／v4_catalog／v4_identity／v4_main_integration 脚本，共 21 项 PASS／退出 0；结果 `/private/tmp/ae4pa-ui-final-results.json`。无新增 SCRIPT ERROR，headless 保留已知 macOS 证书诊断。最终 editor --import --quit 退出 0，生成三个新 A UID；另有用户编辑器设置保存受限诊断，不称环境零错误。
- 原生探针 `/private/tmp/ae4pa_task_ui_visual.gd` 以 `--path . --resolution 1280x720 --script <探针>` 运行，Compatibility／OpenGL 4.1 Metal 退出 0；最终四张 `/private/tmp/ae4pa-task-ui-{offer,hud,failure,retry}.png` 已逐张目视核对，按钮、工作要求、中文时间状态、超时标题与恢复接受页可读。探针卡片是渲染夹具，真实偷卡证据来自测试；B 工作点、C 门及背景原有占位／偏移未做美术校准。
- 当前：A-V4-05 的 201 F5 自动成功／被抓恢复／超时恢复／普通退回通过。README、PLANS、接口 §18、QA、清单头部已同步。A 本轮及 D 原样组件没有提交、push、远端合并或给成员发消息；没有导入 D 背包、手册、菜单或结局。
- 下次入口／阻塞：D／用户在此 A 工作区人工走 F5 四路径，不能将自动输入／原生截图代记人工。D 正式楼梯列表／警告页、背包／暂停和 M2 核验待接；M1／全队冻结、202／三楼、两人计时、Windows、导出不标完成，不在 201 人工联合验收前扩展任务 02。
- 评审取舍：复用 D 评审组件并由 A 适配现有字段，保留当前对白；D 后续改四个详情／重试字段时须同步 A，稳定配置入口留下一轮协作。同步 task_failed→game_failed 顺序已实测；隐藏菜单信号未见真实异步来源，保留当前同步新局连接。排版由本轮截图补验，Windows／人工验收明确留待执行。

- 最终静态核对：git diff --check、新增源码／UID 空白通过，60 个本地链接与 11 个标题锚点有效；12 个 D 文件与 eb5e019 逐字节一致，B/C 内部文件相对 main 无 diff。原 AGENTS、project.godot、ZIP、.vscode、GameManager 与新版对白均与开工备份一致；21 项最终结果复核通过，无暂存或冲突项。


## 2026年11月13日 A 收尾与 B/C/D 依赖交接（Asia/Shanghai）

- 用户要求完成 A，并提供需要 B/C/D 完成的 prompt。开工 HEAD `0145926`，保留全部 A 已有改动，210 个文件及摘要备份至 `/private/tmp/ae4pa-a-finish-zu7123u9`。fetch 核对 main／B／C／D 没有后续新交付，B 目前仅 CLEAN 与 CARD 奖励，PICKUP／AUTHORIZE／巡房文件确实缺失。
- 补 A-V4-01／04／05 当前可执行部分。GameManager 新增 return_to_menu、notebook_changed、get_notebook_view，笔记由已有经理／完成任务事实派生，使用同一检查点恢复。新增 A notebook.gd 适配原 D 帮助页，保持未知规则，经理仅两条线索，201 交付后才揭示长鼻。
- 原样增加 D `eb5e019` 的 main_menu、help、bag 九个文件，累计 21 个 D 组件。main.gd／tscn 连接真实菜单开始、失败返回菜单、I 背包和 H 说明／笔记。D 独立输入停用，由主入口单独分发；装备依旧调用真实 B 接口。新局、失败、加载、恢复和卸载关闭所挂载页面并处理模态。
- 新 notebook_smoke 首跑 FAIL／缺真实笔记查询，实现后通过；task_ui_smoke 对缺菜单先 FAIL，再经真实 D 开始、帮助／背包按钮及完整 201 通过。新增真实装备移槽、停表、经理线索／交付规则、笔记回滚和新局检查。foundation／intro_flow／player_feedback 及 C 的 v4_main_integration 仅迁移正常开始入口，C 检查只增加一行点击，C 组件未改。
- 计时边界沿用既有有效提交即时结算。补测正余量提交先成功后时钟推进不反转，归零失败先生效则晚提交拒绝。没有另存第二个任务时钟。
- 一次独立只读评审没有确认的严重缺陷，提出菜单／笔记焦点检查。补 Tab／Shift-Tab 往返六次，headless 与原生 Godot 均 PASS，焦点留在笔记。原生 QA 另发现 D 背包从空状态首次入卡后仍保留旧空提示，补测实际 FAIL，新增 A bag_adapter.gd 继承刷新修正，D 原文件不改。
- 本轮 Godot `4.7.2.stable.official.ed1daf0bf`。原生主入口检查使用 `--path . --resolution 1280x720 --log-file /private/tmp/ae4pa-a-finish-native-flow.log --script res://scenes/tests/core/task_ui_smoke.gd`，PASS／退出 0。截图探针 `/private/tmp/ae4pa_a_finish_visual.gd` 退出 0，Compatibility／OpenGL 4.1 Metal，菜单／未知笔记／经理线索／背包等截图前缀 `/private/tmp/ae4pa-a-finish-` 已目视检查。渲染探针有位置／卡片夹具，实际偷卡来自自动链路。
- 整理 `docs/a_bcd_handoff.md`，分别给 B 取件／批准／文件／进度接口、C 已有交付联合验证、D 稳定 UI 入口／后段剧情／人工 QA 的可转发 prompt。说明取得同一 A 候选版本后联调，A 继续负责主场景和真实任务流程。README、PLANS 与接口 §19 更新当前入口。
- 仍需 B 的 B-V4-04／05、D 后段对白／正式暂停／楼梯等组件才能接 A-V4-06／07。C 当前组件已有交付，后段实际布局与核验要联测。已向用户询问 D-05 任务 03 批准结算及 D-07 救援后回访，回复前保持待确认。全队／人工／跨机器／后四任务通过记录由真实结果补齐。

- 最终回归执行 python3 /private/tmp/ae4pa_run_ui_suite.py，15 项 core、B 两项、C 五项共 22 项 PASS／退出 0，结果 /private/tmp/ae4pa-ui-final-results.json。新增背包反馈断言已通过，原生焦点／完整链路此前通过。静态复核 61 个本地链接／10 个锚点与新增文本空白通过，21 个 D 文件与 eb5e019 完全一致，B/C 内部组件相对 main 无 diff，C 主入口测试仅加一次真实开始点击。原规则、本机设置、ZIP、.vscode、V4 对白与开工备份相同，无暂存／冲突。本轮尚未提交、推送、创建 PR 或发送成员消息。


## 2026年11月14日 A 最新整合上传准备（Asia/Shanghai）

- 用户明确要求上传 A 最新整合补丁，本次授权覆盖将已验证的整合文件提交并推送到个人分支 work/member-A-liuling。开工 HEAD 0145926、对个人远端 ahead 11，工作区 56 个候选文件与此前干净副本逐字节一致。
- fetch 后个人远端仍为 4dd0890，本地包含其全部历史，可正常快进推送。main 新增 D PR #23／007437a，A 当前候选保持已验证基线 0145926，D 新版本的实际联合验证留后续接入。
- 上传范围沿用整合补丁的 56 个源码／UID／场景／整合文档，覆盖菜单、201 任务与真实工作、检查点恢复、背包与渐进笔记。原本机 project.godot、.vscode、ZIP 与用户 AGENTS 修改按原状态保留。
- 本轮发布前实际重跑 22 项回归，全部 PASS／退出 0，结果保存在 /private/tmp/ae4pa-ui-final-results.json。暂存树继续按候选清单核对空白和链接。远端上传成功以实际 push 及远端 SHA 核对结果为准。人工、Windows／导出、后四任务及待确认规则仍按前条记录。

## 2026-11-15 C：201 房间门 PNG 可复用资产

- 用户明确授权把三种门状态 PNG 推送 GitHub 并导入引擎，要求保留完整画布和相同锚点／缩放。在独立分支 `work/member-C-door-201-art` 基于最新 main `007437a` 实施，原 C 工作区未提交文件保留。
- 新增 `assets/final/doors/room_201/` 三张原始 PNG、Godot 导入描述和接入 README。三张均为 1280×1280 RGBA，SHA-256 与用户源文件一致；无裁剪或重采样。无损导入、size_limit=0、无 mipmaps。
- 新增 `scenes/doors/room_201_art.*`：一个 Sprite2D 切换 CLOSED／WARNING／OPEN，画布底部中心 (640,1280) 为共同锚点、统一 0.18 倍。新增 `room_201_door.*` 继承现有通用门，只替换视觉并隐藏占位图，原有状态循环与接口复用。纯美术可单独拖入使用。
- 新增 `scenes/tests/doors/room_201_art_preview.tscn` 和 `room_201_art_smoke.gd`。本机 Godot 4.7.2 editor import 完成；room_201_art_smoke 输出 PASS，验证真实继承门状态驱动贴图、完整画布、相同矩形／锚点／变换和无占位重叠；原 door_cycle_smoke 输出 PASS，覆盖 20 循环等原有时序。
- 原生 Compatibility／NVIDIA 渲染预览截图已目视检查：三状态共用基线和比例，预警延伸完整可见。沙箱环境存在 user:// 日志／shader 缓存与编辑器设置目录写入诊断；未发现脚本解析或贴图导入错误，不称环境零错误。
- 本轮未替换楼层与主线中的现有门实例；可复用场景已在引擎导入。接入者可在 201 门位选用新场景，并沿用已有 NORMAL／STORY、task_id、monster_type 和 setup(player) 配置；原 PNG 的怪物造型不改变游戏规则。

## 2026-11-15 C：按用户授权替换主线 201 门并准备合入

- 用户明确要求直接合入并替换主线 201 门实例。fetch 后 main 仍为 007437a，原有资产 PR #26 分支继续增加主线接入，未操作原 C 工作区。
- floor.gd 仅对 Room201 选用 room_201_door.tscn；原 STORY／TASK_01_CLEAN／NOSE、检测位置、半径、信号、setup(player) 保留。202 仍使用原通用门。
- 原生截图发现默认 0.18 倍资产叠在背景静态大门前；主线 Art 统一调整为 0.32 倍和局部位置 (-40,10)，覆盖背景 201，三状态仍共用完整画布和同一变换。floor_2.tscn 将 Player z_index 设为 1，避免主角走到新门前被贴图遮挡。未编辑背景 PNG。
- Godot 4.7.2 safe_return_smoke（新增真实主线场景、完整画布、202 不变和前景主角检查）、foundation_smoke、room_201_art_smoke 均 PASS；main --headless --quit-after 3 退出 0。原生渲染主线 2F 的关门／预警／开门截图已目视检查，门框与基线稳定，主角可见。
- 存在既有沙箱 user:// 日志和 shader 缓存写入诊断，未发现脚本解析或运行错误。没有代记完整真人任务通关或其他平台验证。

## 2026-11-15 C：二楼环境分层 PNG，仅个人分支

- 用户要求按远景／建筑／地面／后景家具／交互／前景／光效拆二楼，随后明确角色先不处理，并要求直接放入现有个人分支。fetch 核对开工 HEAD、origin/main、origin/work/member-C-yinshiqi 均为 45cba59。
- 新增 assets/final/floor_2_layers：32 张可组合 PNG（3 个背景／地面模块、29 张 512×512 透明物件／效果）和 3 张 1280×428 原像素分区参考。来源为用户 floor_2_4k.png，3840×2160，可见区 (0,866,3840,428)。保留各物件格子透明边距；大背景用小模块组合，未把整楼缩图后放大。
- 使用内置 imagegen 参考提取与重建，再无损分格输出；不是原 PSD 逐像素图层恢复，雕花／比例等存在 AI 差异，墙面和遮挡边缘为补绘，说明与 manifest 明确区分来源。原像素参考三区逐像素核对。没有原图不存在的角色、污渍、登记台或正式出口牌；原 201 三状态素材不变。
- 新增 README、manifest.json、prompts.md，说明 7 层目录、建议锚点、背景交替镜像拼接、静态门与三状态门的区别、局部烘焙光照及源图限制。
- 验证：35 PNG 全部解码、尺寸／SHA-256／29 个透明格子 alpha 和 3 个源图分区逐像素检查 PASS。Godot 4.7.2 editor import 完成，35 个无损／size_limit=0／无 mipmaps 导入描述均核对，未发现脚本解析或资源导入错误；存在既有沙箱编辑器设置目录写入诊断。
- 棋盘底资产总览已目视检查房号／透明背景／物件分隔／光效。仅提交本包素材及进度记录；本地未跟踪的观察入口与审阅记录不提交。未修改正式场景接线、未创建分支、未向 main 合并；未代记游戏集成验收。

## 2026-11-15 C：按原始 201 模板补齐五门三态，201 改为长鼻

- 用户先要求五门三态，随后叫停新门型，明确采用最初提供的 201 closed／warning／open 原图，只新增 202—205 的 12 张透明 PNG，并确认开启态为 202 独眼／203 大耳／204 核验／205 礼帽；最后追加 201 开启态改为 NOSE。被取消的窄门候选留在任务中间目录，未入库。
- 在现有 work/member-C-yinshiqi 分支新增 assets/final/doors/room_202 至 room_205，每扇 3 PNG；201 仅改 door_open.png 中怪物窗口，closed／warning 与用户源文件逐字节一致。合计五门 15 张可复用三态，全部 1280×1280 RGBA、共用底部中心锚点 (640,1280)、不自动裁边。
- 内置 imagegen 分别编辑房号与对应怪物，最终锁定用户原图母版，仅局部编辑窗口允许变化；生成稿局部配准，原始门框和画布不重采样。三态公共门框 472976 个可见像素差异 0；12 新图及 201 新开启态在编辑窗口外 RGBA 差异 0，全部 alpha 与对应用户模板完全一致。预警沿用原顶部双警报灯／射线／红网格侧灯。
- 新增 rooms_201_205.md、manifest、实际 prompts 说明来源、精确对齐结果及锚点；更新 201 README 和旧分层包说明，避免把旧单态门当作三态素材。原用户 G 盘文件不改。
- 实际验证：全部 15 PNG 解码／尺寸／SHA-256、15 个无损 size_limit=0 无 mipmaps 导入描述检查 PASS；Godot 4.7.2 editor import 完成，room_201_art_smoke PASS，12 纹理实际加载探针 ROOMS_202_205_IMPORT PASS。棋盘底三态总览及切换预览已检查。环境仍有既有 user:// 日志／编辑器设置保存诊断，未发现资源导入或脚本解析错误。
- 仅个人分支提交美术及说明，不新建分支、不合入 main、不修改 202—205 正式场景／规则接线。本地未跟踪的审阅记录和二楼观察入口保留，不提交。

## 2026-11-15 C：按参考图组装二楼分层场景（本地）

- 用户要求使用已确认的 G 盘 2F_assets 包，在引擎按原图摆放二楼。开工 C 分支 7c82c38，与远端个人分支一致，main 无新提交。保留本地四个未跟踪审阅／观察文件，没有新建分支。
- 对照 3840×2160 原图可见区 (0,866,3840,428) 测量布局。新增 floor_2_art.tscn：Far／Architecture／Floor／LightFX／BackFurniture／Travel／InteractiveProps／Lamps／Doors／Foreground 可编辑分组，采用现有模块与独立 PNG，不重新生成或修改资产，不继续把旧整图铺作背景。源图坐标、尺寸和实际纹理路径见 floor_2_art_layout.json。
- 以整体 0.9375 和原点 (0,190.625) 映射到 3600 宽走廊，地面 y560；按原图位置／占用范围拟合五门和家具。由于确认的独立门比例与扁平图不同，门节点固定 X/Y 尺寸拟合，同一门三态共享完整 1280 画布和同一变换，不逐态裁边或缩放。保留原图 201—203关／204预警／205开初始美术状态。
- floor_2.tscn 接入分层布景并隐藏旧背景／占位视觉；201／202 原业务组件继续运行，隐藏旧视觉并同步到新贴图。门检测中心与新位置同步为 x665.625／1226.25；202 安全点 x1076.25／1376.25。其余门仍只作参考状态美术展示，不代记其任务／检测已接入。任务锁仍 x1250，清洁交互不改内部实现。
- 新增 floor_door_art.gd、floor_2_art.gd 和 F6 floor_2_layout_preview：A/D 移动，F1 参考姿态，F2—F4 三态，F5 美术循环。预览不创建假完成记录、不执行怪物判定。新增 floor_2_layout_smoke 验证状态变换／1280画布、地面、前景遮挡、真实门与美术中心、主线状态同步及预览移动。
- 实际 Godot 4.7.2 editor import 完成；floor_2_layout_smoke、foundation_smoke、safe_return_smoke、world_interaction_smoke 均 PASS，main --headless --quit-after 3 退出 0。safe_return 检查改为读取实际门位／安全点，并保留跨锁拒绝等原覆盖。无脚本解析／导入错误；仍有既有 user:// 日志、shader 缓存、编辑器设置保存诊断。
- 原生 Compatibility 渲染总览已目视检查；初轮修复 2F 门牌被前景柱挡住、警报射线顶部边界。输出任务 outputs/floor_2_assembled_overview.png 和 floor_2_reference_comparison.png。素材自身含重建，布局与层级按原图还原，但纹样／雕花／造型不可能逐像素相同；完整限制见 floor_2_art_layout.md。
- Godot 编辑器已打开 floor_2_art.tscn；电脑操作切前台／2D 超时，未声称 UI 自动切换成功。引擎启动自动去掉显式默认 keep 配置，已仅恢复该行，project.godot 不产生本轮差异。未提交、推送或合并 main。

## 2026-11-15 C：二楼场景与确认素材发布授权

- 用户明确要求将当前成果推送并合入 main。fetch 确认 main 仍为 45cba59，C 远端与本地 HEAD 同为 7c82c38；main 无新变更，无需重复合并或重跑未改变的回归。
- 发布范围包含此前 C 分支的二楼环境资产 a78d89b、五门三态／201 长鼻 7c82c38，以及本轮已验证的分层场景、门状态绑定、检测与安全点位置校准、独立预览、布局数据／说明和检查。README 移除待发布措辞。
- 实际验证沿用上一段同一源码的 Godot layout／foundation／safe_return／world_interaction PASS、main 启动和原生截图结果；本轮仅更新发布说明，另执行精确暂存范围与 git diff --cached --check，不虚构新一次运行记录。
- 原有本地审阅记录、floor_2_observe 入口和 project.godot 自动行尾／默认值状态不纳入发布；不强制推送，不重置工作区。远端发布与合并以最终 PR／SHA 核对结果为准。

## 2026-11-15 C：修复主入口 201 接任务与扫帚清理交互

- 用户实玩反馈 201 被挡住、接不到任务且扫帚交互消失。核对发现：主入口 main 未装配已有 D MissionBoard，任务仅 offer 为 AVAILABLE 没有接取入口；布景时把整个 CleaningSpot 设为 invisible 且点位留在旧 x980，造成提示消失／与扫帚脱离。这是布景交互保留不完整，本轮恢复。
- main.tscn 挂载已有 mission_board.tscn 并默认隐藏。主入口监听 task_offered 打开页面，真实接受按钮成功后隐藏并释放模态，增加“查看201任务”按钮方便关闭后重开；没有自动接受任务或伪造清理结果。
- floor_2 的清理点移动到扫帚旁 x852，恢复节点可见并设前景 z1；201 未接任务边界留 8 像素触发余量，避免贴着半径边界无法进入。
- 新主入口流程检查实际发现接受时模态仍打开，task_updated 令工作资格为 false，关页原先没有刷新。floor._on_modal_changed 现重新应用资格与路线，使保洁偷卡／清理在关页后正常启用。
- 新 task_01_main_flow_smoke：从真实 main 入口走到201自动弹已有任务页面，点击真实接取按钮，关页／重开页后仍可交互，扫帚点可见且对齐，调用 CardManager 业务接口取得 CLEANER 作为卡片夹具，真实 E 长按通过 B 清理组件发信号，返回真实门 E 交付并验证通过 x1250 路障；PASS。序章／经理用显式前置夹具，本检查不代记真人全流程或真实偷卡通过；后者已有 world_interaction 覆盖。
- Godot 4.7.2 world_interaction_smoke、foundation_smoke、safe_return_smoke 与新主入口检查全部 PASS。环境仅有既有 user:// 日志写入诊断。新检查最初验证失败并据此补上关页资格刷新，最终通过。本轮仅本地修复，未提交／推送／合并；保留现有未跟踪文件和 project.godot 状态。

## 2026-11-16 C：201 交互修复发布授权

- 用户明确要求推送本轮修复并入 main。fetch 确认 main、C 远端和本地均为 31d34ba，无远端新增，不需要合并其他源码变更。
- 发布范围为主入口 MissionBoard 接线／接取后关页、任务按钮与指引，201 触发边界余量，扫帚 x852 可见交互点，关页资格刷新，新主入口接取—清理—交付检查及说明。
- 沿用上一轮同一源码的 TASK_01_MAIN_FLOW、world_interaction、foundation、safe_return PASS；本轮只更新发布说明并检查暂存内容，不重复声称新一次运行。
- project.godot、独立 core 测试入口的无内容行尾状态，以及原有未跟踪观察／审阅文件不纳入提交。远端结果由 PR 和提交 SHA 核对。


## 2026-11-16 C：一楼去人物分区分层美术资产

- 用户仅授权拆分一楼美术并放个人分支。保留原有本地项目／core 测试入口行尾状态及未跟踪二楼观察文件，不新建分支，不改游戏场景，不合入 main。fetch 后 C 远端与本地一致；main 新增内容与本次纯美术交付无依赖，没有额外同步主线。
- 原输入 floor_1_4k.png 为 3840×2160 RGBA，可见区域 (0,806,3840,548)。入口、前台、休息区、保洁间、楼梯间五区分别按原尺寸裁出并通过内置 imagegen 去人／去家具／补绘，再注册到 3840×548 坐标画布；没有把整栋楼压成小图后放大。前台经理和保洁人物均不进入导出图层。
- 新增 assets/final/floor_1_layers：43 张无损 RGBA PNG、43 个 Godot 导入描述、manifest、说明。包含五块建筑底图，原尺寸三段红毯与平台／踢脚线，独立前台／钥匙柜／钟／旗／双椅／桌／盆栽／柜架／保洁车／书／铃／灯具，三根前景柱及三种真实 Alpha 光效／接触阴影。
- art_sources/floor_1/floor_1_layers.ora 是可编辑 OpenRaster 源文件，61 个命名图层；七个层栈对应五个逻辑类别，阴影位于家具下、附加光晕位于家具上，复用光效母版默认隐藏。另附可移植再导出脚本、实际提示词、拼装预览及资产总览；.gdignore 排除源文件目录的引擎扫描。
- 实际验证：43 PNG 均可解码，独立家具／前景／FX 均有真实零 Alpha；所有尺寸／SHA-256 核对；从 ORA 重新导出 43 PNG 与成品逐像素一致，ORA 重组与预览逐像素一致；三段红毯拼接与原图对应区域逐像素一致。ZIP／stack.xml 结构和 61 图层核对通过。预览／棋盘底总览目视检查无人像，并修复重复 1F 牌及保洁间／楼梯底部透明空隙。
- Godot 4.7.2 editor import 完成，43 个纹理实际 load 探针 FLOOR_1_TEXTURES PASS，尺寸一致、无 mipmaps、无损、size_limit=0。只有既有 user:// 日志及编辑器设置写入诊断，没有资源导入错误。美术源文件未用 Krita／GIMP GUI 打开；未运行玩法回归或代记场景集成验收。
- 限制：扁平 PNG 无法还原原始 PSD，遮挡区域为 AI 重建，部分纹样／轮廓／窗位有差异；入口小盆栽复用提取件。绘画环境明暗／灯罩发亮保留，附加光晕和接触阴影独立可调。仅个人 C 分支发布，远端以最终 SHA 核对为准。


## 2026-11-17 C：一楼按原图校准并接入分层游戏场景

- 用户要求用现有一楼资产替换旧背景、保留全部角色交互，并指定休息区／保洁间、保洁间／楼梯两柱盖住角色且不挡移动；随后要求按原图补齐透明空隙、休息区黑屋顶、完整黑柱和最右侧天空。
- 新增 reference_aligned 45 张原像素分层 PNG、无损导入描述、坐标清单；屋顶三段、六根完整结构柱、五区建筑／两端天空、三段地面及家具分别独立。仅两处人物局部矩形补绘，避免轮廓状色差；其余可见像素、Alpha 覆盖与用户原图一致。原有重建版保留备选；新增 45 图层 OpenRaster 源文件和实际补绘提示词／范围蒙版，保留既有可移植再导出工具。
- 新增 floor_1_art.tscn、layout JSON／说明，floor_1.tscn 挂载该场景并卸载旧整图。保持旧整体 (0,106.25)、0.9375 缩放和地面 y560，统一 nearest 采样消除分层蒙版缩放细线。BackFurniture 在角色后方，玩家／员工 z1，前景柱／屋顶 z2，交互提示 z3。OptionalLightFX 默认隐藏避免重复叠亮。
- 两柱世界中心 x2595／3163.125，仅 Sprite2D 美术；整个 Art 无脚本、Control、Area2D、物理体或碰撞形状。保安800／保洁1600／经理2400、出生192、上楼3400及 y560 坐标不动。protected_hashes 核对 floor.gd、floor_base、Player、Staff、GameManager、CardManager、main 和原有本地配置／core 入口均未改变；没有沿用二楼曾误藏工作交互的做法。
- 实际 Godot 4.7.2：新增 floor_1_art_smoke PASS，真实主入口 E 打开经理对白、ContinueButton 完成真实58段对白、真实楼梯 E 上二楼，玩家真实左右输入各穿过两柱；初轮用50次按钮不足58段而测试失败，改正检查循环后通过，未修改业务逻辑。序章仍是显式前置夹具，不代记真人完整验收。world_interaction_smoke（真实保洁偷卡／往返／模态／唯一 E）、task_01_main_flow_smoke、foundation_smoke 均 PASS。
- Compatibility 原生渲染整层、两柱各显示／隐藏对照；图像比较确认分别遮住角色躯干区域1204／1169像素。45 PNG 从 ORA 再导出逐像素一致，ORA 组合与成品逐像素一致；2042593 个编辑范围外像素与用户原图一致，Alpha 范围完全一致，无新增透明裂缝。编辑器导入完成，无资源／脚本错误，只有既有 user:// 日志、shader 缓存及编辑器设置保存诊断。
- 限制：人物背后及被家具遮挡的区域属于补绘／重建，移动家具后可能需进一步修整；没有用 Krita/GIMP GUI 验证源文件。此次本地 C 分支集成，未提交／推送／合并 main，保留所有既有未提交文件和观察入口。


## 2026-11-17 C：纠正一楼素材来源，使用独立生成高清原文件

- 用户指出上一轮将“布局按原图”误解成“使用原图像素”，要求呈现内容必须使用此前单独生成的资产。停止 reference_aligned 原图裁片方案；保留它作历史候选，当前场景不引用它或 assets/backgrounds/floor_1.png。
- 从既有生成记录找回32张独立生成原 PNG；不使用早期已缩小的43张注册导出。补齐高清横梁、细黑柱、紫色远景、地毯，并对独立生成楼梯修复底部缺口，合计37原文件。全部保存到 hd_generated，与生成输出字节一致，原始完整画布不降采样；实际36纹理形成67独立 Sprite。新增67图层／7680×1096 ORA和实际提示词。游戏不加载预览烘焙图。
- floor_1_art 仅参考原图区域／坐标／占用范围，PNG自身的独立生成造型和纹样保留。region_rect及scale显式存于场景与JSON，统一linear、无损、size_limit=0。重复横梁与地毯采用内部区域衔接，修复黑缝；完整前景柱及两端天空补齐。
- 两根指定柱继续 z2，玩家／员工 z1，纯美术无碰撞／输入节点；所有NPC、出生和楼梯坐标保持，保护文件哈希核对业务源码未改变。新增检查所有实际 Sprite 路径必须属于 hd_generated，防止重新落回原图裁片。
- 实际 Godot4.7.2 FLOOR_1_ART、world_interaction_smoke、task_01_main_flow_smoke、foundation_smoke 均 PASS；FLOOR_1_HD_FULL_SIZE 实际加载37纹理并确认与原PNG尺寸一致。Compatibility 渲染整层、7200×1440细节及两柱遮挡对照完成。37PNG字节／尺寸／导入参数、67层ORA重组通过。仅有既有 user://日志／shader缓存／编辑器设置写入诊断。
- 旧版的“与原图像素完全一致”验收不再适用于当前版本；当前验收是使用独立生成素材、布局按参考、无损保留素材分辨率及交互回归。本轮仅本地C分支修正，未提交／推送／合入main。

## 2026年11月16日 A：合入 main 的二楼布景与主入口修复（Asia/Hong_Kong）

- 用户明确要求将最新 main 合入 A 并运行。本轮基线 A 02be618、main 158818c；在临时克隆重放合并并处理 10 个冲突文件。保留 A 菜单、任务 UI 适配、背包／笔记和检查点，接入 C 分层二楼、201—205 三态门、扫帚 x852 与关页资格刷新，以及 D #29 新对白布局／救援立绘；没有引入未合并 D publish 分支。
- 发现真实接入问题：201 中心移至 x665.625 后，旧检查点 x560 落入半径120，接受任务被安全校验拒绝。现有 task_01_main_flow 与 checkpoint 回归实际 FAIL；将接取前安全点移至 x520 后主入口接受／清理／交付通过。没有放宽安全校验或修改 C 门规则。
- main 的 UI 自登记模态与 A 适配整合后，task_ui 卸载断言实际 FAIL；MissionBoard／Failure 在各自 _exit_tree 释放自己的模态后通过。保留 main 的停表、输入保护、换层拒绝恢复及 A 主题。现有 UI／检查点测试采用真实工作点、门和安全点坐标，保留成功、取消、失败、非法恢复及普通退回断言；新 main 流程测试通过真实开始按钮进入 A 菜单链路。
- 实际 Godot 4.7.2：候选首次 editor import 退出0；包含用户原有 project.godot 与三个 core 文件修改的最终候选，全部16项 core、B三项、C七项及独立UI共27项 PASS／退出0，无新增脚本错误。日志索引 /private/tmp/ae4pa-main-a-suite-results.json。headless 保留既有 macOS 证书诊断，导入有用户设置保存受限诊断。
- 原有未提交文件备份索引 /private/tmp/ae4pa-main-into-a-backup-path；运行相关原修改继续保持未提交，未将本机设置、ZIP、审查文档或启动器混入本次合并提交。双方进度保留。此次仅本地 A 合并及启动，不推送、不修改 GitHub PR，不代记用户真人／Windows／后四任务验收。

## 2026年11月8日 D-12 玩家说明与界面交付材料（Windows，Asia/Shanghai）

- 开工：分支 `work/member-D-caizhichun`。保留原有未提交的 D UI／测试改动和未跟踪的 D-10 房号表、对白及通关界面文件；未切分支或执行 Git 写操作。
- 文档：新增 `docs/player-guide.md`，按已确认的输入映射、三卡五怪规则及现状区分计划玩法与当前可运行测试；更新 README 的 F5/F6 入口、D 独立 UI 状态和玩家说明链接；补充项目角色署名，D 姓名来自用户确认，A/B/C 姓名标为待 A 核实。
- 截图：在 Godot 4.7.2 的实际 `ui_test.tscn` 运行窗口采集并保存 INTRO 消息、营救 309 目标、背包空状态和失败界面四张截图，位于 `docs/media/d12_*.jpg`。截图注明来自独立 UI 测试，不表示完整游戏流程已接通。
- 验证：通过 Godot 实际运行窗口采集四张 853×480 JPEG 画面并确认可解码，文档中的本地 Markdown 链接均存在，`git diff --check` 无诊断。未运行游戏回归；本次只整理交付材料。
- 未完成：1—3 分钟完整项目演示视频待 A 接通主线并确定可录制版本；A/B/C 中文姓名待确认。完整 1F→5F 通关、全员试玩、导出和课程平台要求仍按主计划待验收。


## 2026年11月8日 D-12 交付材料一致性复核（Asia/Shanghai）

- 检查：确认 `work/member-D-caizhichun` 分支和现有工作区状态；保留全部既有修改及未跟踪文件。对照 README、玩家说明、D-12 进度记录和 `docs/media/d12_*.jpg` 四张图。
- 截图核对：四张 853×480 JPEG 与玩家说明图注一致，分别为 INTRO 求救信息、前往 309 目标、背包空状态、失败提示；截图画面属于独立 `ui_test.tscn` 运行，不代表完整主线。
- 完成：新增 `docs/demo-recording-checklist.md`，准备约 90—150 秒录制顺序并逐项标明 A（及相关 B/C 模块）接入前置；README 与玩家说明增加清单链接。未制作或声称已有完整演示视频。
- 验证：检查文档内四个截图相对链接和录制清单链接均指向存在文件；核对 A/B/C 姓名、完整主线和统计数据仍标为待确认／待接入。仅进行交付文档和截图核对，未运行 Godot。
- 待完成：A 接入并验收完整 1F→5F 主线、309 救援、失败重试、出口和通关界面，提供可展示的真实统计数据并确认 A/B/C 署名后，才能录制并交付完整演示。

## 2026-11-17 C：高清一楼发布与 main 同步

- 用户授权推送并合入main；同步main新增菜单／UI，保留双方README与进度记录。新增美术检查适配真实开始按钮，合并后 FLOOR_1_ART、world_interaction、foundation、task_01_main_flow 全部PASS。仅更新测试入口，未修改菜单或角色业务。发布范围排除旧原图裁片候选、观察入口及本机配置。


## 2026年11月15日 未上传依赖检查与 PR #22 审查（Asia/Shanghai）

- 用户要求检查 B/C/D 推进必需内容是否漏传，并审查有冲突的当前 PR。开工为 work/member-A-liuling／ef8a2f7，与个人远端一致。56 个整合文件逐字节等于 origin/work/member-A-liuling，剩余原修改为 A 接力规则、project.godot 默认伸缩行、.vscode 本机路径、原背景 ZIP；ZIP 五图与已跟踪 PNG 哈希一致，未发现漏传的必需游戏源码。
- fetch 与 GitHub 查询确认 main 为 007437a，唯一开放 PR 为 D 的 #22，head eb39714，CONFLICTING／DIRTY，46 个改动文件，statusCheckRollup 为空。A 集成 ef8a2f7 仍在个人分支，当前 main 不含该提交，开放列表中没有 A→main PR。协作需明确使用 A 候选，进入 main 的整合审查仍待处理。
- 使用临时共享克隆 /private/tmp/ae4pa-pr22-review-owj3l15w，检出 main 后执行不提交的 PR22 合并，实际复现 14 个冲突。主工作区未切换分支或执行该合并。14 文件包含新版／旧版对白三件套、任务面板、失败页、HUD、UI 检查及三份整合文档。
- 一次只读独立审查与本轮核对定位 P1：旧 dialogue 仅接 INTRO／RESCUE_309，覆盖 main 会丢 V4_INTRO／V4_MANAGER_TALK；旧 mission_board 缺 main 的模态登记与换层事务保护。P2 为房号表和玩家说明仍用 V3、旧独立 UI 检查遗漏当前保护性断言。可复用的菜单／背包／帮助／共享卡名／主题等不少内容已在 A 候选。
- 实际 Godot 4.7.2 比较 main 对照 /private/tmp/ae4pa-pr22-main-yli0ofyj 与“14 个冲突全选 PR 版本”示例 /private/tmp/ae4pa-pr22-theirs-xew3qejp。两边 editor import 均退出 0，D 独立 ui_test -- --ui-smoke 均退出 0。另用 /private/tmp/ae4pa_pr22_probe.gd：main 面板锁世界、210 秒保持、F5 V4 序章可见，退出 0；错误合并示例面板不锁世界、推进一秒成 209、F5 对白不显示而故事锁仍在，预期退出 1。日志 /private/tmp/ae4pa-pr22-{good,bad}-{probe,ui}.log，保留已有 macOS 证书诊断。
- 新增 docs/pr_22_review.md，写出逐文件冲突处理建议、实际验证、旧文档问题、给 D 的可转发审查意见及 GitHub 审查入口。本轮仅保存本地审查记录，GitHub PR 状态和用户原有配置／资源改动保持开工状态。后续先协调 A 与当前 main，再按新版保留保护逻辑并移植 D 的有效增量，修正候选须重新验 F5。


## 2026年11月15日 A 调试：开发入口 E 经理交谈（Asia/Shanghai）

- 用户提供 task_01_core_test 开发入口截图，目标已为 MANAGER_TALK 但 E 无响应。核对 floor 和 main：楼层正确发经理请求，F5 已监听；core 只接 notice，缺对白实例和请求监听。保留开工原 AGENTS、project.godot、本机文件及 PR 审查记录，未切分支或同步远端。
- 在既有 task_01_core_smoke 补真实 E 回归，初跑退出 1／缺经理对白节点。task_01_core_test.tscn 挂现有 D dialogue，脚本接 manager_talk_requested／dialogue_finished、自己的模态和移动锁；经理仅在对白完成后解锁，新局忽略旧完成信号，卸载清自己的模态。未改 B/C/D 内部源码，开发代记按钮保留。README 操作及 QA BUG-003 同步。
- Godot 4.7.2：focused RED 日志 `/private/tmp/ae4pa-core-talk-red.log`，修复后 GREEN `/private/tmp/ae4pa-core-talk-green.log`。执行 `python3 /private/tmp/ae4pa_run_ui_suite.py`，15 core＋B 两项＋C 五项共 22 项 PASS／退出 0；检查 E 打开和单次推进、无偷卡／切卡、移动锁、结束后上楼条件、另一页模态保留、重开／卸载与原任务恢复。结果 `/private/tmp/ae4pa-ui-final-results.json`；测试以位置、略过动画和按钮等夹具执行，不算真人全程验收。
- 原生 `--path . --resolution 1280x720 --script /private/tmp/ae4pa_core_manager_visual.gd` 退出 0／CORE_MANAGER_NATIVE_OPEN=true，OpenGL 4.1 Metal，截图 `/private/tmp/ae4pa-core-manager-dialogue.png` 已目视检查实际对白显示。headless 仍有既有 macOS 证书诊断，Windows／用户重新试玩未执行。
- 当前修复可本机重启 core 场景后验证，无 B/C/D 交付阻塞。本轮未提交／上传；下次入口是用户复测该 E 交谈，完整正式任务继续使用 F5。原 201 人工联合验收、后四任务和 PR 整合待办继续保留。

## 2026年11月16日 A：PR #22／#24 冲突专项检查（Asia/Hong_Kong）

- 用户要求检查两个冲突 PR 并说明修改方法。本轮 fetch 核对 main `158818c`、D #22 `eb39714`、B #24 `7af4af1`，保留当前 A 工作区已有修改；使用临时共享克隆重放合并，没有切换用户分支、修改游戏源码或操作远端 PR。
- 实际冲突：#24 仅 docs/progress.md，保留 B 两段交付记录与 main 的 C 记录即可；临时候选已处理且无未解决文件。#22 为 14 个文件；保留 main 的 V4 对白三件套和任务面板模态／换层保护，再合样式与新增组件。main #29 已有救援立绘，素材与旧 PR 相同；bag／help／main_menu／win 等仍是剩余增量，不把整 PR 视为已取代。旧玩家说明和门表需要改为 V4。
- 新增检查报告 docs/pr_conflicts_20261116.md，包含逐组文件策略、可转发 D 的说明、版本和证据。原 docs/pr_22_review.md 是已有未跟踪文件，本轮未覆盖。独立同宿主子代理只读复核策略，测试按摘要读取，不冒充运行证据。
- 实际 Godot 4.7.2 在 #24 + 最新 main 的临时冲突处理候选上完成首次导入，work_items、staff_core、cleaner_v4、foundation、world_interaction、task_01_main_flow 六项均 PASS／退出 0；结果 /private/tmp/ae4pa-pr24-merge-results.json。存在既有证书与用户编辑器设置保存受限诊断。git diff --check 与新报告空白检查通过。
- 限制／下次入口：#22 尚未生成修复候选，需 D 按报告合并并验证 F5 序章、经理、任务面板停表及新增 UI。#24 的临时通过不代表 GitHub 冲突已消除；需要在其来源分支保存处理后再审核合入。本轮未提交、推送、合并或发消息，不代记人工／跨平台验收；此次为冲突专项，不是完整代码审计。

## 2026年11月16日 A：本机双击游玩入口（Asia/Hong_Kong）

- 用户要求可直接玩的程序入口。当前 A 分支已 pull 至 02be618；保留本地已有修改，新增根目录 play.command 并赋执行权限，README 补启动说明。脚本从自身位置定位项目，调用本机 Godot 运行 project.godot 的 scenes/main.tscn，不进入编辑器；引擎路径按应用程序／下载／PATH 查找，无组长用户名硬编码。
- 实际验证 bash -n 通过；./play.command --headless --quit-after 5 --log-file /private/tmp/ae4pa-play-launcher-check.log 退出 0，Godot 为 4.7.2，主菜单入口无新增脚本错误；保留既有 macOS 系统证书诊断。此为启动检查，不代记完整人工通关或独立导出包验收。
- 当前入口运行当前 A 工作区，可玩范围仍为 201 任务循环；不是已导出的独立 app。未改 B/C/D 组件、未提交／推送／合并。
- 原生启动：普通沙箱启动退出 134；使用原生窗口权限重试后游戏进程持续运行，日志确认 Compatibility／OpenGL 4.1 Metal（Apple M5），没有新增脚本错误。游戏窗口已为用户启动，未结束该进程。

## 2026年11月16日 A：main 合并落地与原生运行结果（Asia/Hong_Kong）

- 本地 A 已落到合并提交 35d6d01，父提交为 A 02be618 与 main 158818c；已确认 origin/main 是当前 HEAD 的祖先。没有推送，远端分支／PR 保持原状态。
- 原有13个修改／未跟踪文件已保留：代码与配置逐字节恢复，README／QA／进度保留原有本地增量并合入新记录；命名恢复 stash 为721dc6087a1163d61130d04f3f722e194e724bc1，完整备份索引 /private/tmp/ae4pa-main-into-a-backup-path。未把原有本机设置、启动器、ZIP或审查文件纳入合并提交。
- 337个游戏文件与27项PASS的候选逐字节一致。本地完成资源导入退出0，再验foundation、task_ui完整链路和floor_2_layout三项全部PASS／退出0，结果 /private/tmp/ae4pa-main-a-root-results.json。独立只读接入评审无阻塞发现；画面润色、未来任务、跨机器验收不在此次结论内。
- 已关闭本会话之前启动的旧游戏，使用play.command启动合并后版本；原生Compatibility／OpenGL 4.1 Metal（Apple M5），日志 /private/tmp/ae4pa-main-a-native.log。CUA已实际看到游戏主菜单、开始游戏和操作说明按钮。没有代替用户通关；点击开始并完成经理对白后可上2F看C的分层布景。
- 下次入口：直接使用当前A工作区／play.command继续用户试玩。任务01检查点已为x520，扫帚清理点x852；D publish新交付仍未引入，后续任务和远端发布需分别按授权处理。

## 2026年11月16日 A：按用户授权推送合并提交（Asia/Hong_Kong）

- 用户要求push。fetch确认远端A仍为02be618、本地35d6d01可正常快进；两侧差异与工作区git diff --check均通过。
- 实际执行git push origin HEAD:refs/heads/work/member-A-liuling成功，远端从02be618更新至35d6d018b3ad053050575cdbf90bdbaba1a7ded1；git ls-remote再次核对与本地HEAD一致。
- 此次只推送现有提交，没有创建新提交、PR或合入远端main；原有未提交源码／文档、本机设置、ZIP与play.command继续保留在本地。验证沿用上一轮同一合并候选27项及落地后三项结果，本轮没有虚构重新运行。此条推送记录本身尚未提交。

## 2026年11月17日 A：同步最新 main 并准备合入 A 增量（Asia/Hong_Kong）

- 用户明确授权更新到最新main，并将A的新工作合入main。起点A35d6d01，已被PR#30合入；最新main为c736553。备份所有14个原修改／未跟踪文件至路径索引 /private/tmp/ae4pa-a-release-backup-path，在临时干净克隆整理增量，保留本机project.godot、.vscode、ZIP和历史审查草稿。
- 发布A既有core开发入口经理E修复及回归、A接力规则和macOS play.command；README／QA同步真实输入及接入状态。详细验收见docs/acceptance_status_20261117.md与docs/qa_evidence/a_sync_20261117/results.json，证据使用仓库相对路径供团队复核。
- 发布前补最小必要修正：真实接受成功后更新旧offer通知；新增到既有task_ui断言先FAIL再PASS。两份C集成检查通过实际楼层选择按钮后验证到达，保留原有检测；未改C门或B员工业务逻辑。
- 实际Godot4.7.2，最终17core／3B／7C／1UI共28项PASS，另launcher语法与无缓存首次导入启动通过。冷启动原先退出0但有57条脚本／资源加载错误，不能算通过；补自动导入后无上述错误。原有证书／用户设置诊断单列，不代记环境零错误、人工／Windows／完整五层通过。
- 只沿用既有个人A分支发PR，不创建平行玩法实现；最终推送和main合并状态由GitHub PR／SHA核对后追加。没有将所有本地未提交文件一并打包。

## 2026年11月17日 A：PR #34 已合入并同步完成（Asia/Hong_Kong）

- 本次有效增量提交abbf4e7已通过PR #34合入main，最终合并SHA为98e8130e4fddf7bef25cec9f722e1775ac747b8a。GitHub再次查询确认closed／merged；git ls-remote核对远端main与work/member-A-liuling均为该SHA，本地main与当前A也已快进至同一版本。
- 合并后的Git源码树与28项通过的发布候选逐字节一致；本机play.command实际完成增量导入及主入口headless启动，退出0，无脚本或资源加载错误。没有配置云端CI，不把本机验证称为GitHub Actions通过。
- 本机project.godot原差异、.vscode、背景ZIP与历史审查草稿按备份哈希完整保留，未发布；命名stash与完整备份仍保留用于恢复。本条远端操作收尾记录暂存本地，未另造发布提交。
- 下次入口：当前A／main已同步，可直接使用play.command运行新版；由D／用户在固定98e8130版本做201真人四路径和任务／当前卡／余量复述。Windows、导出、后四任务仍未代记通过。

## 2026年11月17日 A：当前里程碑收尾与剩余任务核对（Asia/Hong_Kong）

- 用户要求“完成A侧”。核对当前A／main的98e8130、GameManager、楼层／UI接线、B工作／文件奖励与D剧情，确认任务01正式循环已发布，任务02—05仍被流程拒绝；M1真人验收没有新增结果，不能直接标全A完成或越过门槛启用后续任务。
- 本轮只修正PLANS、README、interfaces和a_bcd_handoff中的当前状态：真实楼梯／暂停／重试已接入，201安全点为x520，B取件／批准／巡房文件已存在；旧prompt明确标历史，避免队友重复实现。历史接口／验证证据保留，新的当前状态表优先；没有改B/C/D业务源码。
- acceptance_status_20261117固定发布与合并SHA，逐项列A-V4-01—09的成果／缺口，补真实F5成功、被抓恢复、实际超时恢复、普通退回、模态和新玩家理解记录表，全部真人结果仍未执行。该表由实际操作人填，不用自动时钟夹具代记实际等待超时。
- 验证：逐项核对发布候选results.json的28/28及对应日志，复用同源码已有结果，本轮文档改动未重跑Godot。检查修改文档的本地链接／新锚点、空白和发布版本一致性；具体命令结果见本轮终端。跨模型文档评审配置为disabled，未调用外部评审。所有原有本机设置、ZIP和审查草稿保留，没有新提交／push。
- 下次入口：先由D／用户按验收摘要完成并记录98e8130的M1真人路径。通过后A接任务02，再核对D-05／07及完整309对白进入任务03；A-V4-07—09继续受前序主线、真人计时和目标平台条件约束。
- 工具记录限制：全局gstack评审／学习日志目录创建被文件系统权限拒绝，未请求扩大权限；disabled评审状态和本轮核对结果已在本仓库记录，skill-end返回recorded。该限制不影响上述文档检查。

## 2026年11月18日 A：按用户确认完成当前201收尾（Asia/Hong_Kong）

- 用户明确回答“还没有，先完成当前201的A侧收尾”。范围固定为当前任务01，不启用任务02—05，不代记M1真人验收。本地A仍为98e8130，保留全部已有未提交文档、本机配置及未跟踪资源，无需为本次收尾重新拉取队友分支。
- 对当前工作区实际重跑Godot4.7.2的foundation_smoke、task_01_main_flow_smoke、task_checkpoint_smoke、task_ui_smoke四项：4/4 PASS、退出0，无SCRIPT／Parse／资源加载错误。覆盖正式UI接受／交付、被抓／超时回滚、模态所有权与普通退回。日志中的既有macOS系统证书诊断单列；超时／位置／朝向仍有自动夹具，不代替真人四路径。完整结果与四份日志在docs/qa_evidence/a_201_closeout_20261118/。
- 验收摘要补本次范围确认及新证据链接，并把普通门真人步骤设为201接受后、交付前进入202，以实际观察退回后原任务余量继续。之前整理的当前接口／计划／交接和真人记录表继续保留。本轮未发现失败项，不为凑改动修改游戏源码，也未提交／push。
- 下次入口：双击根目录play.command，固定98e8130做验收摘要的真人成功、被抓恢复、实际超时恢复、普通门退回及模态／复述记录，由D或用户填写。当前201的A侧自动检查与验收准备已收尾；M1通过后才进入A-V4-06。

## 2026年11月19日 A：导出仓库美术供 Figma 使用（Asia/Hong_Kong）

- 用户要求导出仓库全部美术素材供导入 Figma。生成本地 `builds/figma_art_20261119/` 和同名 ZIP（约 163.36 MiB）；沿用已有 builds 忽略规则，并在素材目录加入 `.gdignore`。保留已有工作区改动，没有修改游戏源码／素材原文件，也没有提交、推送或上传 Figma。
- 包内逐字节复制 179 张游戏 PNG、2 张美术预览 PNG、4 张 UI 参考 JPG、1 个 SVG 和 2 份 ORA，另附 25 份既有说明／清单／摆放资料及导入说明、CSV／JSON 索引。原背景 ZIP 内五张图片与 assets/backgrounds 哈希一致，因此不重复复制；一楼当前高清与历史版在说明中明确区分。
- 按 scenes/character_visual.gd、视觉小说素材说明和 dialogue.gd 的 3×2／512px 规则，在临时独立 Godot 项目额外导出四角色六帧行走及女主／闺蜜各六张表情，共 36 张 512×512 PNG。Godot 4.7.2 输出 EXPORTED_AND_PIXEL_VERIFIED_FRAMES=36、退出 0，逐帧重新加载后像素与源区域一致。临时项目存在用户日志目录沙箱限制和既有系统证书诊断，不影响导出结果；未借此代记游戏运行通过。
- 验证：复制文件 SHA-256 与源文件一致；全部 PNG 的 chunk CRC、结构和 zlib 数据可解析；SVG XML、两份 ORA 和最终 ZIP 校验通过。另按源目录重建美术清单核对覆盖范围及压缩包内容，并执行 git diff --check。此次仅为美术导出，不需要运行玩法回归；没有验证 Figma 实际导入或将位图转换为可编辑矢量。
- 下次入口：解压 ZIP，按 README_导入说明.md 选择 01_import_original 中的分类 PNG／SVG 或 02_split_frames 的单帧拖入 Figma。当前任务无阻塞，原 201 真人验收和后续玩法状态不变。

## 2026年11月17日 B-V5：员工行为、偷卡稳定性与 V2 美术接入（Asia/Hong_Kong）

- 基于 `origin/main` 98e8130，在独立工作区／新 B 分支完成；没有改写 A 任务系统、C 场景模块或 D UI。正式 1F 将经理移至前台附近短巡逻、保安移至入口站岗巡逻、保洁员移至清洁区—工具车往返，避开主要前景柱；柜台当前单一深度结构不适合把经理强放柜台后方，因此采用用户允许的大堂前台附近方案。
- 根因对照：角色放大后旧 55px 区域与视觉体量不匹配；CURIOUS 结束还会保留朝向玩家；保洁工作循环又叠加独立随机转头，造成刚按 E 突然转向。正式实例区域校准为 95px，CURIOUS 恢复原朝向，职业循环只由可观察的停留／0.4秒准备／移动驱动；0.8秒、背后、静止、资格、正面／回头被抓均保留。
- 接入 V2 保安／保洁静止透明 PNG，显示高度 AN190／经理198／保安204／保洁184；女主与经理继续原正式素材及动画，保安／保洁行走暂用原六帧。静止／行走使用同一脚底裁切缩放逻辑，无额外角色实例；临时预览、Debug字段、本机字体和 `.vscode` 均排除。
- Godot `4.7.2.stable.official.ed1daf0bf` 实跑：`staff_core_smoke`、`cleaner_v4_smoke`、`floor_1_art_smoke`、`world_interaction_smoke`、`task_checkpoint_smoke`、`task_01_main_flow_smoke` 全部 PASS；`main.tscn` headless 启动退出0。覆盖三卡／双槽、真实偷卡与清洁、唯一E、D进度状态、正面／回头失败、检查点恢复和201交付。保留既有 macOS 证书及测试存档不可写诊断，不称环境零错误。
- 剩余：保安／保洁 V2 专属行走和职业动画尚未制作，本轮按要求不新增大量动画；经理柜台后方活动需未来场景深度／遮挡结构由 A/C 共同确认。正式 Windows 与本提交后的全程真人复测仍待团队验收。

## 2026-11-17 C：二楼左右楼梯间与栏杆合为单张PNG

- 用户要求按一楼式整体楼梯，避免独立前景栏杆不合理遮挡人物。内置imagegen按原左右朝向／金色拱门及一楼栏杆风格分别生成两张887×1774 Alpha PNG，原尺寸保存；补充实际提示词／SHA／定位清单与说明。
- floor_2_art的Travel两个节点替换为整体楼梯，保持背景z0、玩家z1；删除Foreground/LeftRail、RightRail及两个旧纹理引用，其他前景层保留。布局JSON同步删除旧栏杆条目。金色踏步底对齐源y394／世界560，左右楼梯交互点192／3400不变。
- floor_2_layout_smoke新增检查整体PNG、无独立栏杆／附加脚本碰撞、两侧双向真实移动及原交互坐标；FLOOR_2_LAYOUT PASS。floor_flow、world_interaction、task_01_main_flow均PASS。业务源码及floor_2.tscn与HEAD文本核对无变化。Godot导入、真实Alpha／无损／size_limit=0核对通过。
- Compatibility左右实际楼层截图目视核对人物位于栏杆前方。截图经理前置／静止位置为显式夹具，右端画面不代表剧情门锁已解开。环境仅既有user日志／shader缓存／编辑器设置诊断。此次本地C分支修改，不推送、不合main。既有未跟踪美术候选／观察入口保留。

## 2026-11-17 C：二楼整体楼梯发布授权

- 用户明确要求推送并合入main。fetch确认main与C分支均为98e8130，没有远端新增。发布两张含栏杆的整体PNG、无损导入描述、场景替换、布局说明及检查；沿用同一源码的四项PASS与实际渲染，不重复代记新测试。排除旧一楼候选及观察入口。


## 2026-11-17 C：发布已确认五怪动画图集

- 用户明确授权推送个人分支并合入 main。assets/final/monster_idle 包含本次指定五张最终图集及清单、切帧说明；独眼轻动作、核验大动作。
- 五张均验证 RGBA 真实 Alpha、4×2 网格、源文件与复制文件 SHA-256 一致，共40帧。仅发布资产，无游戏行为改动；运行时动画接入及前述门逻辑仍待后续实现。保留其他未跟踪候选。


## 2026-11-18 C：单门调度、渐进遇怪与站立动画（本地）

- 用户要求开门才检查、一次只开关一扇、20房间半随机分配；另明确大耳保留停步、核验保留附近不换证。未收到本次代码推送授权。
- 新 door_scheduler.gd 管理生产楼层的单门 WARNING/OPEN 与关门间隔；首次近距离未知怪优先开门，其他门先关闭；模态与待处理请求期间不继续轮换。floor.gd 全部房间按会话分配装配，GameManager 保存随机结果、遇怪记录和唯一待处理请求，检查点恢复同一结果，新局清空。
- 已确认五怪图集通过 monster_idle_visual.gd 接入；2F五门绑定实际状态及怪物，原OPEN皮肤内置旧怪由暗色内景覆盖后显示实际站立动画，关门不显示怪物，无新增物理碰撞。3F–5F仍用旧背景加组件，不代记高清布景替换完成。更新怪物分配表及任务资料302/403/501起点。
- 201沿用真实介绍、任务UI、取卡、清理与交付；其他首次／重复遇怪违规发 monster_encounter_requested(context)，保持pending并拦住跨门，不能把关闭聊天当成完成任务。后续任务执行和D聊天尚未接入，202以后可能停在待接入请求，未宣称完整五层已可玩。接头说明 docs/room-monster-table.md、docs/interfaces.md。
- Godot4.7.2 Compatibility：ENCOUNTER_FLOW、foundation、task_01_main_flow、task_checkpoint、task_definitions、world_interaction、floor_flow、floor_2_layout 均PASS。新检查覆盖20房分配/会话稳定、首次正确卡仍介绍、已认识正确卡通行、关闭门无卡安全、违规请求、大耳/核验原规则、400步互斥、模态冻结及上层实际实例装配。checkpoint旧自动退回断言按新请求语义更新，保留交付不回滚验证。
- 实际Compatibility渲染检查201开门显示长鼻、202关闭无怪；随后按场景比例调小怪物。图集导入无损size_limit=0。初次编辑器导入遇本机用户目录写入诊断，后续测试APPDATA指向工作目录，无脚本/资源错误。未代记D对白、人手通关、其他平台或未实现任务通过。
- 旧独立门相位/安全退回API保留供历史独立适配；正式楼层使用managed_cycle新路径。现有未跟踪一楼候选与观察场景保留，不提交、未push。


## 2026-11-18 C：恢复用户确认的完整开门美术（本地）

- 用户指出开门预览只剩门框。定位为上一轮 floor_door_art.gd 的 OpenInterior 深色覆盖矩形同时挡住了门扇、201门牌和暖光。移除覆盖层，五门共用皮肤保持完整原OPEN图，仅叠加独立站立怪物；不改调度、规则或任务代码。原图自带室内剪影保留。
- 用户提供201 open/warning/closed与仓库三图逐字节SHA-256一致，无需重生或替换PNG。Compatibility实际渲染确认打开门扇、门牌、暖光恢复，202关闭；ENCOUNTER_FLOW PASS。仅本地，未push。

- 2026-11-18 用户要求门口怪物更大：二楼共用怪物缩放0.9→1.15（约28%），脚底位置和门美术不变；Compatibility实际渲染核对门框内比例，未修改交互逻辑，未推送。

- 2026-11-18 用户再次要求放大：二楼门口怪物共用缩放1.15→1.35（较上一版约17%），脚底锚点不变；Compatibility实际渲染确认，未修改门或交互逻辑，未推送。


## 2026-11-18 C：本轮发布授权与 main 同步

- 用户明确授权推送本轮门逻辑、原开门素材恢复、站立动画及最终1.35比例，并入main后再同步个人分支。先fetch并快进同步main bef62ba，已有候选与观察入口保留且不发布。
- 发布前重新运行 ENCOUNTER_FLOW、foundation_smoke、task_01_main_flow_smoke，均PASS；其余既有回归沿用同源码上一轮实际记录。附图集无损导入描述及新脚本UID，保留完整原开门图。
- 发布范围包括半随机20房配置、单门调度、首次/违规请求与D/A接口；202以后实际聊天与任务执行仍待接入，不当作完整主线已完成。最终远端PR及同步SHA由发布结果确认。


## 2026-11-18 B：任务 02—05 组件封装交付

- 从最新 main `6a26974` 建立独立 B 分支，复用既有 `CleaningSpot`／`Staff`，新增 `parcel_cabinet_2f.tscn`、`register_309.tscn`、`exit_register_5f.tscn`、`patrol_staff_4f.tscn` 四个薄封装。目标 ID、身份、工作类型、一次性奖励和恢复入口固化在根节点；没有修改 A 主线、C 楼层、D UI 或定义任务 03 尚未确认的结算／回访规则。
- `work_items_test.tscn` 改为直接实例化四个正式封装；`work_items_smoke` 覆盖固定参数、错误身份、一次性结果、完成视觉隐藏、PATROL_RECORD 不进入卡片、被抓／恢复及只读进度。Godot 4.7.2 在最新 main 上重新导入后，自动检查 PASS，综合人工场景启动退出 0；保留既有 macOS 证书与编辑器设置保存诊断。
- 偷卡难度调整继续留在 PR #35 工作区，未混入本组件分支。临时中文字体、主题、`assets/temp_review/`、`temp_*review*` 与本机 `project.godot` 均未复制到交付分支。

## 2026-11-19 B：五项工作交互视觉状态补充

- `work_items_test.tscn` 加入既有 `STAIN_201`，与 202 包裹、309 批准、402 巡逻记录和 503 离店批准同屏；测试快捷键只服务 F6，不修改公共输入映射或正式任务状态。
- 202 组件复用正式包裹柜／信封素材，309 组件复用正式登记台素材；完成后只隐藏可领取物件或提示，家具节点保持可见。正式楼层已有同一家具时由 A 隐藏测试夹具的 `PersistentVisual`，避免重复绘制。
- 201 污渍、402 巡逻记录和 503 表单仍缺正式透明 PNG，接口文档登记建议画布、游戏可见尺寸、锚点、图层及状态；本轮没有生成低质量占位美术。
- Godot 4.7.2 重新导入后 `work_items_smoke.tscn` PASS，覆盖正式资源引用、家具保留、物件隐藏、错误身份、一次性结果、失败／重置及只读进度；临时字体、主题、预览素材和 PR #35 难度参数均未进入本分支。

## 2026-11-18 C：三楼分区分层美术资产（个人分支）

- 用户要求只制作三楼美术，去人物、不制作门，保留分层源文件与真实Alpha PNG；不接游戏场景。内置image_gen按区域/物件生成24部件，不把原整楼图片放大代替独立资产。参考原图仅提供布局与样式。
- assets/final/floor_3_layers：29张游戏PNG，包括4块1920×940背景分区、可拼接墙面/天际线/顶梁/地毯、整体楼梯（含栏杆）、双窗、家具及光效。登记台无接待人物，台面/钥匙格补齐；门位连续墙面，待独立门叠加。保留装饰画/徽章内的静态人物图案，不是场景NPC。
- art_sources/floor_3/floor_3_layers.ora：7680×940，4分组、35独立可移动图层；同时保留原生生成PNG、参考裁块、相对路径提示词和预览。图层只按原生或缩小使用，没有放大原走廊像素。
- 用户指出左端外侧黑柱遗漏，另生成完整黑柱透明PNG并补回3F牌后方，同时更新四分区/ORA/预览。两端楼梯的栏杆均在整体楼梯PNG内，不单设遮挡组件。
- 验证：全部透明资产alpha最小0，背景分区完整不透明；从ORA实际35图层逐层重建与mergedimage像素完全一致，缩略图符合256上限；目视核对人物/房门排除、家具与左右楼梯及左柱完整。validation.json记录29输出。只检查美术，不代记游戏接入或通关。
- 本次只提交个人分支，不推送或合入main；原未跟踪候选和观察场景保留。


## 2026-11-18 C：三楼分层与三至五楼房门资产发布授权

- 用户明确要求推送个人分支并合入main。包含此前个人提交20cbfa6的三楼分层（29PNG、35层ORA、补齐左柱）和已确认301母版/11房号衍生三态，共36门PNG。
- 门资产放assets/final/doors对应房间目录；art_sources/doors_3f_5f保留提示词/检查/预览。36文件均验证1254×1254、RGBA真实Alpha、复制与确认稿SHA-256一致。三楼ORA/Alpha/拼接验证沿用其源提交validation.json；未重新生图。
- 只发布美术，没有更改角色、任务、门逻辑或游戏场景，没有代记未做的游戏接入。只发明确房号，不补造305/309/504/505。旧未跟踪候选与观察入口保留。


## 2026-11-18 C：独立美术组件接入三楼（本地）

- 用户要求用前面生成的独立组件替换旧三楼背景，原图只参考布局；进一步明确删除305，不保留占位。floor_3_art.tscn直接引用独立墙板/天空/顶梁/双窗/整体楼梯/左黑柱/家具/光效PNG，35独立部件，不引用原背景、合成分区或预览整图。floor_3.tscn隐藏旧背景并实例该布景。
- 301—304及309按原图对齐，门中心世界x1139.0625/1514.0625/1879.6875/2310.9375/3023.4375，y560；真实检测点和309救援点同步。305从场景与随机池删除，普通房目录相应19间。主线输入/任务/楼梯解锁条件不变，工作人员与玩家代码未动。
- 309高马尾观察窗三态PNG导入，默认关闭；读取既有has_friend展示救援后开门，不显示怪物，不加入普通房单门调度。301—304复用真实调度与已确认怪物动画。通用门美术room_id改为字符串以支持3F路径，2F行为保持。
- 新F6美术预览floor_3_layout_preview.tscn显式停用普通门检测/调度，便于A/D看图；不是主线解锁快捷方式。正式入口仍为main，3F仍受后续任务未接完的进度限制。
- 验证：FLOOR_3_LAYOUT、ENCOUNTER_FLOW、floor_flow、task_01_main_flow、world_interaction均PASS；基础foundation并发运行首次序章推进超时导致移动断言失败，独立重跑PASS，未修改该测试或D对白实现。floor_flow及encounter旧“五门”断言按用户删除305更新，保留其他楼层数量验证。
- Compatibility实际渲染检查独立组件全景、左端楼梯黑柱/沙发双窗、302礼帽开门动画、309高马尾窗/登记台/右楼梯。新美术无碰撞，跨走廊移动PASS。初次导入仅系统safe-save诊断，未见脚本/资源载入错误。截图用显式关闭/302打开夹具，不代记主线3F通关或309剧情完成。
- 本轮仅本地修改，未提交或push；既有候选和观察场景保留。接入详情见scenes/levels/floor_3_art_layout.md。


### 2026-11-18 C：三楼登记台落地与门比例修正

- 按用户反馈修改floor_3_art.tscn：登记台从约0.531缩为等比0.49，下移并按实际不透明台脚落地，调整接触阴影和台灯光晕；301/302/303/304/309由(0.5,0.72)改为(0.68,0.68)，保留组件原比例和原门中心/底部锚点。没有改房门检测或任务规则。
- 实际Godot Compatibility渲染查看登记台/309和302开门画面：台脚贴地，门横向不再压窄，花台/烛台与门间距可用。截图为本地显式美术预览夹具，不能代替正式任务链验收。
- 验证：floor_3_layout_smoke.gd 输出 FLOOR_3_LAYOUT: PASS；git diff --check 通过（仅既有行尾转换提示）。本次保持本地修改，未提交或推送。


### 2026-11-18 C：三楼场景发布准备

- 用户已授权将本次三楼组件组装、309高马尾观察窗三态、删除305、登记台落地和五门等比缩放推送个人分支并合入main。同步README与房号说明。
- 发布前独立顺序回归：foundation_smoke、floor_3_layout_smoke、encounter_flow_smoke、floor_flow_smoke、task_01_main_flow_smoke、world_interaction_smoke全部PASS；编辑器资源扫描没有脚本/资源错误，仍有既有系统safe-save权限诊断。实际Compatibility截图验收沿用同一最终场景的登记台落地、宽门比例及302开门预览。
- 仅纳入本次场景、309最终PNG、所需Godot导入描述/UID与记录；旧候选图、1F参考重建、观察测试入口保留本地。主线3F任务链/救援聊天尚待后续实现，本次不代表全游戏通关验收。


### 2026-11-19 C：青绿色四楼独立分层美术（不含门）

- 按用户确认的雅致四楼效果图分区重绘和拼接；内置imagegen生成13个独立纹理/家具/标牌组件，保留青绿墙纸、金饰、巡逻记录台和休息家具，去除旧水管、清洁工具、人物与所有房门。已确认三楼的整体楼梯/黑柱/顶梁/外景和通用光影复用，来源记录在layout.json；确认图无窗，本次不增造窗。
- assets/final/floor_4_layers输出25张游戏PNG（含4块1920×1280连续建筑底图）、可拼墙面/地毯/踢脚线、透明家具与效果；art_sources/floor_4保留7680×1280、4组30层ORA、13个原生生成图、确认稿、提示词、拼接预览与validation.json。门位连续墙面，后续叠加已有401—405门。没有把总图缩小再放大充作资产。
- 实际验证：透明物件Alpha含0且有非零像素；浅色底接触表检查无黑底/棋盘格；四建筑分区拼回与原分层建筑像素一致；墙面/地毯/踢脚线重复边缘像素一致；从ORA的30图层按偏移/透明度重建与mergedimage完全一致，缩略图不超过256。查看无门总拼接图，修正楼梯与屋顶衔接，完整保留左右黑柱，家具台脚落地。
- 本次只美术交付，不运行或代记游戏任务回归，不接四楼场景，不修改门/任务逻辑。提交当前个人分支，未授权推送/合入main；旧未跟踪候选保留。


### 2026-11-19 C：四楼独立组件组装进游戏（本地）

- 按用户要求用已确认青绿四楼资产及401—405三态门替换旧背景。新floor_4_art.tscn直接引用独立PNG，墙面/地面纹理平铺，家具与光影单独Sprite；不使用总图或四块扁平分区替代独立组件。
- 母版缩放0.46875、源地面1100映射世界560；五门统一等比0.8，真实Marker随门中心对齐。floor.gd增加Floor4Art绑定分支，沿用原适配器与单门调度。403大耳停步/其他半随机不变，不更改输入、任务或解锁条件。
- PNG透明边缘导致楼梯/家具悬空，按实际不透明底边重新贴地；两端保留完整黑柱与整体楼梯，补暗色楼梯背板和地面底沿。实际Compatibility截图已核对左端401/休息区、403开门大耳动画/巡逻台、右端405/挂画长凳。
- 新增F6四楼美术预览（显式停用普通门检测/调度）和布局检查。该预览不代替正式主线解锁或四楼任务通关。本次不自动提交、推送或合入main。
- 验证结果：FLOOR_4_LAYOUT、foundation_smoke、encounter_flow_smoke、floor_flow_smoke、task_01_main_flow_smoke、world_interaction_smoke全部PASS；git diff --check通过。实际资源导入未见脚本/资源加载错误；保留原系统safe-save权限诊断。


### 2026-11-19 C：四楼发布授权

- 用户授权推送个人分支并同步合入main，包含独立资产提交42adc14及四楼场景组装、401—405绑定、预览与布局检查。发布前获取main，发现B员工/工作点和D UI已有新合入，先保留四楼提交再同步main进行兼容回归。旧候选与未跟踪实验不纳入。
## 2026年11月19日 B：V5 难度候选与最新 main 兼容复核（Asia/Hong_Kong）

- `work/member-B-v5-staff-polish` 合入 `main@2538f11`，`docs/interfaces.md`／`docs/progress.md` 冲突均保留 B 与 C 的追加记录；没有改写 C 的单门调度、首次遇怪、半随机分配、大耳停步或核验附近禁止换证。
- 本轮待真人确认参数：保洁 CLEANING 3.5—4.5 秒、ORGANIZING 3—4 秒，保安 3—4 秒，经理 2.4—3.2 秒；转身准备 0.4 秒、背后静止长按 0.8 秒、正面／回头被抓与唯一 E 不变。
- Godot 4.7.2 资源重新导入；`staff_core_smoke`、`cleaner_v4_smoke`、`world_interaction_smoke`、`task_checkpoint_smoke`、`task_01_main_flow_smoke`、`encounter_flow_smoke` 均 PASS。首次导入前的怪物纹理缓存缺失诊断已通过完整重新导入处理；最终人工难度仍以 F5 试玩反馈为准。
- 临时中文字体／主题、`assets/temp_review/`、美术预览、组件 PR #41 文件和调试文件不进入本难度提交。


## 2026年11月19日 A：按用户要求拉取 main 并打开游戏（Asia/Hong_Kong）

- 用户要求从 main 拉取并提供最新游戏入口。当前个人分支 `work/member-A-liuling` 执行 `git pull --ff-only origin main`，从 `98e8130` 快进至 `f18e4ce`，与本次 fetch 的 `origin/main` 一致；没有推送或新建提交。
- 原有本地修改先完整备份，再命名 stash；恢复时仅 `docs/progress.md` 的双方追加记录冲突，已全部保留。其他非重叠原文件 SHA-256 与备份一致，原本地进度追加内容完整保留，工作区恢复为未暂存。备份目录 `/private/tmp/ae4pa-main-pull-20261119-160355`，恢复 stash `16a4d61d47153a62aa3cb2d67d3f9d88dbc20f6d` 继续保留。
- Godot `4.7.2.stable.official.ed1daf0bf` 完成资源导入（退出 0），`foundation_smoke.gd` 输出 PASS／退出 0。导入仍有既有系统证书及沙箱内编辑器设置保存诊断，没有脚本／资源加载错误；日志为 `/private/tmp/ae4pa-main-20261119-import-output.log` 与 `/private/tmp/ae4pa-main-20261119-foundation-output.log`。
- 通过 Godot MCP 启动当前工作区，CUA 实际看到“怪物员工通道”主菜单、“开始游戏”和“操作说明”。下次入口为仓库根目录 `play.command`，双击后点“开始游戏”；Godot 编辑器也可 F5 运行 `scenes/main.tscn`。本次仅同步与启动检查，不代记真人任务验收或完整五层通关。

## 2026年11月19日 A：当前201收尾与完整任务余量清单（Asia/Hong_Kong）

- 用户要求完成A并列出已做／未做，随后明确确认“尚未完成：先完成当前可做的A侧收尾”。本轮范围为 `main@f18e4ce` 的201整合检查、旧检查迁移和交接；保留已有修改，没有改游戏业务代码，没有提交／推送，也未启用任务02—05。
- 首轮8项检查中6项通过：task_ui仅旧“普通门自动退回”断言失败；safe_return访问已不在真实门下的 `Art/Sprite2D` 后脚本报错，60秒超时。核对C的现行门表及真实 `managed_cycle` 调用链，确认主线已改为持有强制遇怪请求、201美术已移到分层布景，不回退C业务规则。
- 修改 `scenes/tests/core/task_ui_smoke.gd`：保留原201／HUD／超时／被抓／模态覆盖，检验202强制请求不覆盖已交付201、不撤销真实卡片和工作事实、越过门中心仍被限制在来侧、错误房号不能清除请求、新局立即清理。修改 `safe_return_smoke.gd`：绑定真实分层201美术，显式调用保留的A退回API，保留两侧落点、危险区／跨锁／同帧／旧楼层与计时保护；明确只是兼容API，不宣称主线自动退回。
- 实际Godot `4.7.2.stable.official.ed1daf0bf`／macOS headless，最终 foundation、task_01_main_flow、task_checkpoint、task_ui、world_interaction、floor_return、encounter_flow、safe_return **8/8 PASS、均退出0**；只加强UI测试后再完整复跑该测试通过。结果、实际命令、受检源码SHA-256、首次失败与最终日志见 `docs/qa_evidence/a_201_closeout_20261119/`。保留既有系统证书诊断；没有脚本／资源加载错误。位置、员工状态、门相位和任务时钟有夹具，不替代真人或实际210秒等待。
- 新增 `docs/a_status_20261119.md`，按A-V4-01—09列已交付、缺口、依赖与下一步；同步PLANS、README、a_bcd_handoff、acceptance_status与interfaces的当前基线、强制遇怪边界和201／202／302／403／501任务起点。历史98e8130／28项证据保留，不转记本轮；真人表仍全部未执行。文档本地链接与锚点、空白检查实际通过。
- 工具限制：gstack检查选择器因Git临时对象写入权限不可用，采用仓库已有Godot脚本直接验证，不宣称READY_FOR_SHIP。全局功能标记／学习日志目录同样不能写入，未扩大权限；本条已保留门规则迁移的操作经验。
- 下次入口／阻塞：用户或D先按验收摘要对当前版本记录真人成功、被抓、实际超时、模态／复述及202未接任务边界。M1通过后先接任务02；任务03前确认D-05／D-07并取得完整309剧情，再接后两任务、完整测时与目标平台导出。当前可执行收尾已完成，完整A职责／M1／后四任务仍不标完成。

## 2026年11月19日 A：按周一会议重整全组工作与补充决定（Asia/Hong_Kong）

- 用户提供2026-11-16 14:28会议摘要，要求按讨论整理工作；随后确认只前移五怪首次教学到二楼、五个正式任务仍分布五层，以及两卡门要求两个装备槽同时装备指定两种卡。本轮仅整理文档，不改游戏逻辑、测试、素材或项目配置，不提交／推送／合并，也未向组员发送消息。
- 新增 `docs/work_replan_20261119.md`：逐条对照会议待办与当前 `f18e4ce` 源码，区分已经补齐、待验与未实现。经理Q版、五怪动态图、一至三楼分层场景、菜单／HUD／标题／对白、长按进度已存在，不重复列从零制作；正式污渍PNG、人物比例／命名及实际可读性仍有交付／验收事项。没有把“有组件”当完整主线通过。
- 新排工为R-01规则表、R-02核对已填真人结果、R-03素材／反馈、R-04二楼五怪教学、R-05三楼以上随机／重遇和双卡门、R-06原五层正式任务／309／结局／导出；沿用ABCD文件归属和V4编号。明确当前FIRST门表仍分散201／202／302／403／501，新目标尚未实装；正式任务入口必须与前移教学分开，不能只改门号表或因教学结束提前完成后段任务。
- 同步PLANS近期队列、game-design／team-plan补充、README、room-monster-table当前事实提示、a_bcd_handoff、a_status及interfaces目标说明；保留原会议／主策划、既有代码事实和历史验证证据。未指定的双卡门／组合、无经理卡教学安全路线、202开放具体含义、重遇违规后果及随机池／固定任务点关系继续待定，已确认方向不重复标成未知。
- 用户随后报告已经填写真人验收表。读取当前 `docs/acceptance_status_20261117.md` 仍为待填／未执行；根目录三份项目CSV均为11月12日旧任务／功能／问题记录，未发现本次真人结果，连接文档会话也为空。已询问实际文件路径／链接，记录为“用户已填写、结果待核对”，不要求重复填表、不推断全部通过。验收摘要只更新顶部说明，没有改写表格实际结果。
- 文档检查：核对相对链接／锚点、空白和状态区分；具体最终结果见本轮终端。与本轮开始前备份核对，游戏脚本／场景／测试及原配置未再改变。本次纯文档整理不重跑Godot，不把此前8项检查转记为新教学／双卡门通过。
- 下次入口：先读取用户提供的已填真人表，按结果关闭M1通过项或分派实际问题；同时用工作重整表确认剩余教学／卡组细节。M1结果核对与规则表就绪后，A接二楼首次教学与任务02，再按原五层接后段任务。当前排工文档已整理，实际验收结果位置仍待用户提供。

## 2026年11月19日 A：保存用户201真人六项结果并收口M1功能验收（Asia/Hong_Kong）

- 用户提供 `docs/acceptance_status_20261117.md` 路径。磁盘初读仍为空；通过CUA检查VS Code同一路径的未保存编辑页，实际读取成功、被抓恢复、实际超时恢复、202后续边界、模态边界、新玩家理解六项结果全部为用户原文 `ok`。旧状态列为“未执行／执行”，不是新增失败结果。
- 先备份较新的磁盘说明至 `/private/tmp/ae4pa-before-human-save-20261119.md`，再保存用户编辑页；遇到文件内容较新的保存冲突，因已有完整备份而保存用户内容，随后将六条用户行合回较新文档。原始用户填写全文另保留 `/private/tmp/ae4pa-human-filled-20261119.md`。原文ok保留，状态统一为“通过（用户记录）”，没有虚构操作细节、录像或实名。
- 当前201／M1功能验收按用户六项ok通过，不再以“未完成真人验收／待定位表格”为阻塞。表内基线为f18e4ce；实际测试日期／系统／Godot准确版本、测试人实名和详细观察未填写，作为记录元信息待补，不把本次读取日期替代实测日期。当前结果不扩大到新二楼五怪教学、指定双槽卡组、后四任务、309、结局或跨平台。
- 同步验收摘要、PLANS、README、a_status、a_bcd_handoff、team-plan、interfaces及work_replan的当前状态和旧表格锚点。R-02当前功能验收收口，A下一项为教学／正式任务／卡片／通路接线表，之后接二楼教学和任务02；双卡具体组合、教学安全路线等未决细节仍保留，接口全队冻结不代记完成。
- 本轮只保存／整理用户验收记录与排工文档，保留已有代码和设置差异；没有再改游戏逻辑或测试，没有提交／推送／发消息。文档链接／锚点、六项原文与状态、空白及游戏源文件哈希核对见本轮终端；纯文档更新不重跑Godot。下次从已确认的M1结果和会议工作表继续，不要求用户重复填表或重做通过项。

## 2026年11月19日 A：正式202任务接入至3F（Asia/Hong_Kong）

- 用户明确要求直接接202，不等待B剩余三个美术或全部五层素材，范围包括201完成后的任务切换、202对白接取、二楼保安／身份、包裹柜／领取／交付及三楼解锁。M1当前201真人六项用户ok继续保留原f18e4ce范围，不重新要求验收201，也不扩大成202真人通过。
- 起点A f18e4ce，获取远端引用确认B #35／#41已在main，另有D #42新UI；pull过程中连接重置，现有origin/main引用已为c89c88c，随后本地快进成功。完整备份索引 `/private/tmp/ae4pa-task-02-backup-path`（117原文件），命名stash `931c42740f433d216251aeeabf381664684247b9` 保留；恢复时仅追加进度冲突，双方记录已保留并恢复原未暂存状态。当前基线c89c88c，未推送。
- 使用writing-plans／executing-plans／TDD，计划与执行ledger为 `docs/superpowers/plans/2026-11-19-task-02.md`。先证实核心“201完成后仍拒02”和正式“无202对白”两项RED，再实现GREEN；用户指定直接推进，沿用当前A个人分支并保留已有改动，不新切分支或自动提交。
- 修改GameManager仅启用01／02，按任务定义处理资格、步骤、180秒、工作与交付，接受清自己的room请求，快照复用B接口；任务02失败保留已交付01、保洁、污渍／通路与笔记，撤销接取后新增卡／包裹，回2F x1070/y560、AVAILABLE/0秒，再接受才180秒。
- A楼层真实组装B二楼保安x420、`STAFF_SECURITY_2F`及包裹柜封装x990，唯一E选两个工作源，绑定实际source并拒迟到／外部事件；正式柜体保留，不叠重复柜体，包裹领取检查当前SECURITY。202由A实例设STORY，绑定现有C入口；201已完成镜像不因换任务丢失。202未交付后段右界1476／路障1500，当前工作与交付点都可达，交付后可真实走到楼梯上3F。
- 接D既有样式与最小兼容API：`Dialogue.show_task_dialogue`、`MissionBoard.configure_task_details(details,title_text="")`；main／task_ui／task_hud按当前任务显示202对白、接取、领取、交付及重试，保安已生效后不再误提示Q。B员工／CardManager／工作脚本、C门／调度内部与资源原文件均未改；本轮三个B组件回归通过，未发现需B修复的已测接口问题。
- 执行计划要求的独立只读评审找到四项真实问题：后段锁只看201、202进度还提示回201、当前已保安仍要求Q、已知怪物错卡仍提示等未接聊天。增加断言／复现后修复，同一评审再检查未报告剩余重要缺陷（评审未独立运行测试）。真实主流程覆盖早接近202不覆盖01、对白／实际接取按钮／重开、暂停、正背面偷窃、Q与瞬时领取、物件／柜体、回访、实际失败UI／重试、长鼻及独眼Q放行／越门、3F楼层按钮。
- 本机Godot4.7.2、macOS headless，相关17项最终PASS／退出0。初轮16/17仅旧检查点末尾“202仍不可接”预期失败，保留原日志后迁移为202 AVAILABLE/0秒并额外检查01／保洁／通路仍保留，再整项复跑通过。最后仅缩短202文案／身份中文化及去旧201标题，完整201 UI与202主流程再复跑通过；其余受检源哈希未变。结果、实际命令、失败原始及最终日志／哈希在 `docs/qa_evidence/a_task_02_20261119/`。
- 原生Compatibility/OpenGL 4.1 Metal实际观察202四句对白与202/180秒接取面板，201前置由显式标注夹具建立；面板后HUD目视检查未完成，不记真人202通关。原生进程正常退出0且无脚本／资源错误，headless保留既有系统证书输出，编辑器导入另有沙箱保存设置诊断。
- 新增 `docs/task_02_handoff_20261119.md`，同步README、PLANS、interfaces、a_status、a_bcd_handoff和会议排工的当前状态；201真人原文未改。本轮未提交／推送／发消息，没有启用03—05、309、未定双卡或完整五怪教学。下次入口：`play.command`正常新局完成201后到202，按交接记录真人202成功／被抓／实际180秒超时、模态与上3F；完整教学／双卡具体组合及03／309继续独立推进，不以其他美术缺口阻塞已接202。

## 2026-11-17 D 序章与游玩界面美术接入

- 补丁制作基线为远端 main 的 `98e8130`；本机应用于 `work/member-D-hotel-ui-preview`。F5 菜单读取独立雨夜封面和中英字标，序章标题也使用独立字标。
- 序章首条短信先显示倾斜手机与新消息，约 0.67 秒后摆正。沿用现有 TSV 和按键推进，闺蜜左侧、安右侧，聊天随最新消息滚动。首条短信和通知只在该轮序章开头显示一次；回访短信画面沿用聊天历史。
- 背包用三收藏格、两佩戴格显示 CardManager 当前数据。HUD 用新状态底板、卡槽和进度轨道，任务时间和工作进度继续读取现有状态。主 UI 仅将工作进度挂到新 HUD 的布局容器。
- Debian／Godot 4.6.3 无窗口导入与独立 UI、开场预览、`intro_flow_smoke`、`task_ui_smoke` 均退出 0。另在正式入口检查手机摆正、头像左右、最新短信可见、序章字标、三卡单行、真实装备和 HUD 生效状态，退出 0。本环境未打开图形窗口，Windows／Godot 4.7.2 目视待验。

## 2026-11-19 D 黄铜旅馆 UI 审查准备（Windows）

- 当前分支为 work/member-D-hotel-ui-preview，补丁基线 98e8130；Fetch 后接入 main 2538f11，只解决进度文档追加冲突，保留双方历史。原 D 等其他工作区未操作。
- 本机 Godot 4.7.2 导入、intro_flow、foundation、独立 UI 和带画面验证退出 0；菜单双语标题、手机震动摆正、头像、短信滚动、三收藏／两装备和 HUD 高亮截图已保存到 docs/qa_evidence/d_hotel_ui_20261119。
- task_ui 退出 1：202 普通门安全退回断言失败。干净 main 2538f11 同样失败；最新 encounter_flow 退出 0。未改管理器／门行为或删除断言，交 A 复核强制相遇与旧测试的对接。
- 背包与 HUD 截图的卡片来自仓库外脚本调用真实 CardManager API 的测试夹具，非剧情取得；夹具、缓存、临时存档和无关导入描述均不纳入。
- git diff --check 通过。保留 PR 开启等待审查；本条不宣称正式五任务主线已验收。

- 提交审查前 main 又更新到 f18e4ce（PR #35／#41）。已再次接入，保留 B 组件、员工参数及所有 main 记录；最终 intro_flow、foundation、ui、staff_core、encounter_flow 和带画面验证退出 0，task_ui 与干净 f18e4ce 均在同一普通门退回断言退出 1。最新证据已替换为最终分支生成的截图与日志。

- C同步main：仅进度文档发生追加段落冲突，已保留B/D与C全部记录；场景/脚本自动合并无冲突。后续回归针对合并后的代码运行。

- C发布前最终回归（同步main@c89c88c后）：floor_4_layout、foundation、encounter_flow、floor_flow、task_01_main_flow、world_interaction全部PASS；资源导入无脚本/资源加载错误，保留既有safe-save系统提示。沿用最终组件实机截图检查，未宣称四楼主线任务已实现。


### 2026-11-19 C：新版长鼻怪8帧动画替换与发布授权

- 用户已确认新版单张与8帧站姿，并授权替换游戏、推送个人分支、合入main。以确认PNG无损替换assets/final/monster_idle/nose_idle_sheet.png，尺寸1448×1086、4×2、每格362×543，真实Alpha0—255，SHA-256更新至manifest；其余四怪PNG未改。art_sources/monster_idle/nose_v2保留确认单张、内置imagegen提示词及8帧边界信息。
- 共用适配器只调整NOSE脚底基线514→504和各帧时长（420/130/150/220/350/150/150/300ms），保留整格切片、既有显示缩放、开门显示/关门隐藏和模态冻结机制；未改门逻辑、碰撞、卡片或任务。
- 实际Compatibility渲染检查201门前的新长鼻怪与主角/布景的描边和尺寸、脚底站位；截图为显式预览夹具，不代记剧情/任务完整通关。encounter_flow、floor_2_layout、floor_3_layout、floor_4_layout、task_01_main_flow五项PASS，git diff --check通过。当前main@8e64221已核对，无新增远端提交。


### 2026-11-19 C：五楼独立分层美术（无门、无人物）

- 按用户提供的五楼参考制作17个独立生成组件，配合已确认三楼的外景/黑柱/整体楼梯/顶梁/灯桌/盆栽及光影复用。去除离店登记员与出口两人，全部房门与附带灯具排除；保留空出口、EXIT牌和整体栏杆平台。未增造504/505或修改游戏房间目录。
- assets/final/floor_5_layers共31PNG，包含4块1920×1500建筑分区、可拼墙纸/地毯/踢脚线、独立屋顶徽章/半圆窗/檐口栏杆/通长顶条/柱头，及登记台、休息椅、留声机柜、挂画、花瓶、灯具/光影。art_sources/floor_5保留7680×1500、4组44层ORA、17张原生图、提示词、参考和预览。
- 首轮拼接发现屋顶留白形成断缝、花瓶未落台面，已裁屋顶组件透明留白、补连续栏杆顶条、调整台面位置、按实体脚底落地，并复查最终预览。原生组件仅裁切、平铺或缩小，不用整楼低清图放大代替。
- 实际验证：所有透明对象Alpha含0且有可见像素；浅色底检查表未见黑底/棋盘格；四建筑分区拼回与建筑合成逐像素一致，重复纹理边缘一致；从ORA44图层依偏移/透明度重建与mergedimage完全一致，缩略图≤256。图片中静态酒店徽章不属于场景人物。
- 只美术交付，游戏场景/人物/房门/任务逻辑未改，不运行或代记游戏通关测试。只提交work/member-C-yinshiqi本地分支，不推送或合入main，既有未跟踪候选保留。


### 2026-11-19 C：五楼组件场景接入与发布授权

- 用户授权用五楼资产及房门替换场景、推送分支并合入main；进一步明确按原图只留501—503，删除504/505。已先合入main@caf862d英文切换更新，无冲突；保留其翻译/字体/UI。
- 新floor_5_art.tscn直接用独立PNG，房门统一等比0.66，Marker同步到x1087.5/1696.875/2610.9375、y560；地面源1340映射世界560，屋顶最高实体边微调到视口内。原图人物不进入布景，玩家/工作人员沿用运行时角色。
- floor.gd添加Floor5Art状态绑定；501核验/502、503半随机、单门调度、原楼梯点与退出流程不变。504/505从场景和随机目录同时移除，全楼普通门数17；相应更新既有楼层门数断言，保留其他行为检查。没有新增尚未实现的5F任务或逃脱剧情。
- 实际Compatibility检查501开门核验动画、左休息区、中央屋顶/离店台/503和右EXIT平台，家具落地、三门原比例、无静态人物。新增F6显式美术夹具及floor_5_layout_smoke，预览停门检测/调度，不代记正式主线通关。

- 最终验证：floor_5_layout、foundation、encounter_flow、floor_flow、task_01_main_flow、world_interaction、localization_smoke七项PASS；git diff --check通过。资源导入无脚本/加载错误，保留既有safe-save系统提示。源资产31PNG/4组44层ORA沿用6d88780的Alpha/拼接/重建检查，未改原生素材。发布范围包括该资产提交及五楼接入，旧未跟踪候选不纳入。
## 2026-11-19 D UI Refresh v2：素材包接入与 Windows 审查准备

- 解压根目录 Hotel_UI_Refresh_v2.zip 到项目外，实际查看新增按钮与 HUD 素材；选择性整合附带补丁，未覆盖原 D 工作区和旧暂存结果。
- 新分支 work/member-D-ui-refresh-v2：封面改居中容器，闪电／短黑屏／标题上升／按钮依次出现，期间禁用误触；返回菜单恢复动画、焦点与状态。统一实际按钮反馈，正式 HUD 接背包／笔记／暂停及原数据。
- main 在工作期间合入英文切换，已整合到 caf862d 并保留语言选择与通知翻译；主场景仅 UI 接线，不改玩法或发卡。
- 实际 Godot 4.7.2：导入、开场、基础、独立 UI 及两尺寸图形验证退出 0。task_ui 与干净 main 在同一普通门退回断言退出 1，保留记录交 A。测试副本只调整临时路径与等待动画，未改断言。
- Windows 实际封面／HUD／空背包／暂停等截图和46帧动画GIF、日志见 docs/qa_evidence/d_ui_refresh_v2_windows/README.md；没有发测试卡片。原生 F5 已观察封面、操作说明与手机，后续完整原生走场受电脑工具弹窗超时限制，未代记通过。
- 所有改变仍在 D 的新分支准备新 PR，不更新已合并的 #42，不合并 main。缓存、临时进度、原ZIP、包内Linux验证文件不纳入。


### 2026-11-19 A：按用户要求同步最新 main（caf862d）

- 在 `work/member-A-liuling` 执行 fetch、fast-forward 到 `origin/main@caf862d`，未提交、推送或切换个人分支。保留本地 202 正式任务接入及全部既有修改。
- 同步前完整备份 164 个已修改／未跟踪文件到 `/private/tmp/ae4pa-pull-main-20261119-172912`；原始 tracked 修改另保存在 stash `2fd4711eec8cc7bfd87b695db78a159373a568cb`，恢复后仍保留备份。核对 164 个文件均在，15 个四楼导入描述与上游一致，现由 main 跟踪。
- 恢复本地工作时解决 `scenes/levels/floor.gd`、`scenes/task_ui.gd` 两处文件冲突：保留 202 多工作点／保安独立目标／任务对白／三楼放行，同时保留 D 的双语刷新与格式化提示信号、C 的四楼门视觉绑定。所有本地修改恢复为未暂存，无未解决冲突。
- Godot 4.7.2 完成新资源导入，无脚本／资源加载错误。foundation、task_01_main_flow、task_ui、task_checkpoint、task_02_core、task_02_main_flow、floor_4_layout 共 7 项退出 0；`git diff --check` 通过。证据见 `docs/qa_evidence/a_main_sync_20261119/results.json`。
- 双语原测试未通过：沙箱拒绝 user:// 写入；另任务快照取在收集保洁卡前，当前动态任务步骤在收卡后已改变，导致状态保持断言比较了不同准备阶段。保留源测试不改；临时诊断脚本改用 /private/tmp 故事存档、在卡片准备后取快照，切换／暂停／状态保持检查退出 0。语言设置跨进程持久化未验证，不计为通过。既有系统证书诊断及编辑器设置写入限制单独记录，不代记游戏功能错误。
- 下一步入口仍为 202 真人验收及 D 反馈配合；本次不代记真人通过，也不扩展 03—05。


### 2026-11-19 A：202双语反馈、中文缺字与语言保存收尾

- 用户要求继续A侧；按最近入口处理可独立完成的202双语接入与上轮失败，不等待剩余美术，不代替真人202验收。当前仍为 `work/member-A-liuling@caf862d` 加既有未提交修改，本轮未检查远端、提交、推送或启用03—05。
- 先在独立 `ae4pa-a-locale-check-20261119` Godot存档中复现原双语测试失败，排除user://权限后只剩任务快照断言。根因为收集保洁卡会把任务步骤改为CLEAN_STAIN，而旧测试在收卡前取快照；移动卡片准备后的任务快照，并增加真实步骤断言，原楼层／玩家／任务／卡片／检查点／暂停时钟保护断言全部保留。
- 新增 `task_02_localization_smoke.gd`，先取得有效RED：202对白／说话人／面板／HUD／时间／重试均缺翻译。补35条202与过渡文案，HUD统一复用201既有翻译及分钟计时路径；main的202组合目标先翻译模板和参数，并在语言变化时刷新。D对白／面板／失败组件本轮不再改；没有新增任务真值或改变身份／领取／交付规则。
- Godot字形探针另查出当前字体缺“柜、带”。沿用官方Noto CJK SC Sans2.004、OFL及Hotel Staff CJK重命名，从原580码点扩至582，原580个水平度量全部一致；只保留最终子集，不加入完整源字体、pip环境或运行依赖。新202测试包含对白中文字形覆盖；最终相关源码字形探针缺失列表为空。
- Godot4.7.2最终13次检查全部退出0：双语完整状态保持／写英文、重启读英文、切中文、重启读中文、202双语全阶段共5次；foundation、201主流程、task_ui、task_checkpoint、202core、202主流程、四楼布局、world_interaction共8次。RED／GREEN日志、命令、源文件SHA-256、专用配置和字体来源见 `docs/qa_evidence/a_202_bilingual_20261119/results.json`。语言持久化现已在独立存档跨进程验证，不再沿用上轮“未验证”的状态。
- 实测测试使用专用资源映射与独立profile，仅测试配置允许存档写入，未读取／修改玩家原存档。Godot导入无脚本／资源加载错误，常规沙箱运行仍有既有系统证书／编辑器设置权限诊断。gstack检查选择器仍无法写Git临时对象，直接执行仓库Godot检查，不宣称READY_FOR_SHIP。
- 学习记录：macOS独立Godot存档设置为 `application/config/use_custom_user_dir` 和 `application/config/custom_user_dir_name`；绝对名称不会把存档移到/tmp。卡片／世界准备应在语言切换快照之前完成；新增中文对白同时核对字体子集，避免只验英文目录。
- 下次入口：正常 `play.command` 完成201后接202，记录成功交付／实际被抓／实际180秒超时、暂停背包和3F解锁，并目视检查中英换行与缺字；202真人／Windows／完整五层仍未验。201用户六项ok未动，03／309和完整五怪教学／双卡配置仍独立待后续。


### 2026-11-19 A：登记202真人反馈、修复英文UI适配并准备03接线

- 用户本轮明确“真人通关已验收”“超时已验收”，按用户记录分别确认202成功／超时通过；不要求重做，不推断被抓／暂停背包／回访／Windows全部通过。已追加acceptance_status与202交接，201六项原始ok行不改。
- 按用户要求使用gstack design-review，适配原生Godot：CUA查看真实中英菜单；独立测试profile中用真实main／UI与明确201前置、202任务／三卡夹具捕获九个页面前后图。原生Compatibility／OpenGL4.1 Metal、1280×720，最后CUA再次实际看到202英文对白与Continue已分离。没有把夹具当真人通关。
- 四项发现均修复：202长对白压住按钮→按实际换行高度向上扩展内容／名字牌／背景，预留16px页脚并监听语言／尺寸变化；HUD槽文字越界→保留更高槽区域；英文Cleaner ID及背包字号适配既有卡框；主场景隐藏重复开发标题／帮助／目标／重开控件但保留必要notice、原节点与测试钩子，缩短英文任务路线。只改scenes/ui/dialogue.gd、hud.tscn、bag.tscn、A主场景与英文目录的必要部分，不换美术或任务真值。
- 新english_layout_smoke先在原代码失败（中英对白页脚、HUD槽边界），修复后通过；未改既有用例断言。本轮最终16次退出0：既有8项core／201／202／楼层回归，5次双语／重启保存，新增布局、真实intro_flow、D独立ui_test。首次重跑的语言相关失败保留：预览留下英文偏好，而旧断言按中文；最后新建独立profile顺序跑，不改玩家语言来迎合测试。
- 本轮重跑脚本一度复用了前一双语证据目录，覆盖部分逐项原始日志；发现后改用独立a_english_ui目录并保存首次重跑。前一results.json里的原13条命令／结果和源码哈希未改，逐项JSON从该索引恢复；原始日志无法据此重造，旧目录新增log_provenance.md明确限制。本轮所有最终原始日志、源码哈希和18张前后图独立保存，不将覆盖日志伪称旧原件。
- 本轮结果与设计报告：docs/qa_evidence/a_english_ui_20261119/results.json、design_review.md。外部审查按codex_reviews=disabled未发送，浏览器检测器不适用于原生游戏，未宣称全产品或跨平台设计通过。gstack要求的按修复提交未执行，遵守用户保留工作区、不擅自提交／推送的授权边界。
- 界面修复后继续A侧R-01／A-V4-06：新增task_03_readiness_20261119.md，区分二楼教学／五层正式任务，核对302真实入口、B register_309、经理资格、三卡双槽、3F检查点／跨层恢复及309占位。确认现有offer／accept／retry仍固定二楼、完整救援对白未交付，不能只加ENABLED_TASKS就标03完成。已异步询问D-05批准即结算及D-07救援后楼层访问；无回复时未当同意，尚未启用03—05／309。
- 下次入口：读取用户对D-05／D-07的回答和完整309对白，从03接线准备表继续独立验证再主线组装。202已通过的成功／超时不再列为阻塞；完整五怪教学、具体双卡配置、其余真人细分与平台仍单列。本轮保留已有修改，无提交／推送／对外消息。
- 操作经验：原生Godot同bundle多个安装时，CUA用实际app完整路径；截图／语言保存测试各用专用profile，中文断言不要读玩家已选英文的存档；每轮证据runner必须独立输出路径。


### 2026-11-19 A：确认D-05／D-07并接通任务03批准流程

- 用户明确“两条都采用”：登记台当前经理批准即完成03／停表／解锁309，不额外回302交付；真实救援对白结束后封锁1F／2F，仅回访已到达3F—5F并按正常规则解锁下一层。同步game-design及v4-migration，不再列这两项规则未定。
- 因下一项依赖D的新救援交付，fetch main核对仍caf862d，没有新309文本。未合并／切换／提交／推送；保留当前个人分支及全部既有修改，修改前备份/private/tmp/ae4pa-task03-backup-0eev8ns0。新计划与ledger为docs/superpowers/plans/2026-11-19-task-03.md；采用writing-plans／executing-plans／TDD，就现有明确方案直接推进，不重复要求许可。
- 新core先因03拒绝接取RED，接入后GREEN：ENABLED_TASKS仅01—03，新增can_offer_task按定义楼层／前置检查；03接受240秒，MANAGER仅收藏／备用均拒绝。REGISTER_309当前经理批准立即COMPLETED／0秒／registration_309_approved，01／02保留DELIVER。检查点按真实楼层恢复，1F失败回3F x1320/y560、AVAILABLE／0秒，保留01／02卡与通路，撤销03新经理卡／批准。
- 新main先因302无对白RED；实际诊断发现managed普通门CLOSED没有请求，A按正式任务规则独立于门动画相位登记302触发，不改C内部。3F组装B真实register_309 x2645/y560，对齐已有桌子且隐藏重复物件；唯一E、来源校验、经理真实前／后偷卡、I第三卡换槽及Q当前身份、真实E批准、被抓／超时跨层恢复、已知3F错卡请求／Q解除均有检查。309视觉读取批准事实即打开；未救援时不假装has_friend或4F开放。
- 新增受前置约束的rescue_friend()->bool／friend_rescued信号，供未来真实D对白结束后调用；has_friend后楼梯列表过滤1F／2F，旧请求也被许可校验拒绝。当前F5的309 E只反馈后续未开放，不播放两句占位、不生成跟随；救援状态和上楼策略仅用明确domain callback夹具验证，正式309救援仍未完成。
- A复用D已有对白适配／详情样式，加入302四句介绍、240秒／经理身份／即时批准／重试的中英反馈。仅扩现有许可字体所缺表／附，582→584码点且旧度量全部保留。旧02用例末尾“03仍未启用”的预期按本轮新范围迁移，保留02成果与04拒绝检查；其余有效断言未删。
- 最终30次相关headless检查全部退出0，包括01／02／03、底座、检查点／回访、工作与B组件、三／四楼、美术门、序章、D独立UI、双语／语言重启保存及布局。语言写入用例先串行，再并行读者，使用专用profile不读玩家偏好。另原生Compatibility／OpenGL4.1 Metal主流程--capture退出0，查看302英文对白、240秒面板及309批准后画面。新测试先败后通、原始诊断、源码哈希与图见docs/qa_evidence/a_task_03_20261119/results.json。
- executing-plans要求的独立只读评审使用完整临时项目与独立profile重跑03core/main，两项通过，无重要缺陷；后加可选截图助手经同一评审复核无重要风险，主代理再跑最终套件／原生流程。评审未改文件或提交，不扩大为真人／Windows通过。
- 更新03handoff、准备表、README、PLANS、interfaces和A状态。201六条原文及202成功／超时用户结果不改；本轮没有完整二楼五怪教学、指定双卡、04／05、救援跟随或导出。下一次从03真人成功／被抓／实际240秒、跨层／换槽反馈，以及D完整309对白接线继续；D-05／D-07已定，不重复询问。


### 2026-11-19 A：按用户授权准备推送并合入main

- 用户明确授权当前成果push及merge到main。选取A任务02／03、英文UI修复、相关文档／测试／证据及最终资源必要导入描述；保留本机project.godot既有差异、编辑器设置、原始资源包及预览导入缓存，不覆盖或清理。
- 新鲜fetch核对main仍caf862d，无新增合并冲突。以暂存树26af5b9导出无缓存副本，全新导入退出0、30次定向检查全部通过；见docs/qa_evidence/a_publish_20261119。随后仅修正文档当前状态表并增加本记录，受测运行代码未变。
- 三份独立只读评审无阻断缺陷，旧状态表已更新；未配置VERSION，不新增版本号／发布包。用户验收不扩大，完整309／04／05、五怪教学／双卡及跨平台仍待后续。提交／推送／远端合并结果以实际Git与PR为准，本条为合并前记录。

## 2026-11-19 D：五怪任务对白校正（main d0fec0d）

- 工作目录：ae4pa-monster-dialogue-current；分支 work/member-D-monster-dialogue-current，未提交。原 D／PR22／角色整合工作区未被本轮编辑。
- 保留 A/B/C 任务真值和门配置。当前 FIRST 是 201=NOSE、202=EYE、302=HAT、403=EAR、501=CHECKER，尚非本轮提出的二楼五房配置。
- 已接：201 初见→原接受面板、201/202 真实 task_completed→交付成功对白；202 复用 A 的 TASK_02_INTRO 入口与原完成回调。持卡、备用槽或 Q 切换均不能替代工作／交付；完成工作仅提示返回交付。独立预览不结算。
- 五怪全部中文阶段存于 scenes/ui/monster_dialogues.json；新 203／204／205 只预览。新二楼房务申请、独立清理点／巡房记录、领取通行单／管理批准三套合同待 A/B/C 确认，不能套用 309 登记或最终 EXIT。既有后续任务／救援保持。
- 201/202 主场景与 309 主场景回归保留原断言，新增读完对白操作。详见 [接线与差异](monster_task_dialogue_handoff.md) 和 [本轮证据](qa_evidence/d_monster_dialogue/README.md)。
- Godot 4.7.2：新增对白回归、现有 UI、foundation、序章经理、201 任务逻辑与 201/202/309 主场景回归均实际退出 0；202/309 core 退出 0。Windows 根证书读取诊断未阻断检查。git diff --check 通过。
- 图形模式从真实 main 渲染 201/202 初见与交付画面，中文面板与按钮边界已查看。截图含公开 API 测试卡片／工作报告，不作为人工偷证或完整五任务试玩。新 204/205 的独立标记、顺序和双身份工作验收仍阻塞；英文新对白翻译未确认。

## 2026-11-20 B：正式美术与交互收尾（用户授权测试通过后提交合并）

- 基于main `d0fec0d` 整理已保存成果，角色母版与动作移入 `assets/final/characters/`，正式共享renderer接入；女性190px／保安200px，AN步频从16fps调整为约10fps，移动160px/s不变。职业／转身／疑惑／被抓读取原Staff状态，偷卡0.8秒及转身准备0.4秒未改。推车因缺少可靠扶车接触姿态未实施，保留清洁／整理动作。
- 正式201清洁由B组件发起／取消／完成事件控制AN持拖把姿态，取消／卸载立即复位。三项任务PNG进入 `assets/final/work/`；202删除重复的小信封，保留柜中唯一包裹，完成只改变信封格子，柜体像素保持。309家具沿用正式资源，04／05组件视觉就绪不等于A主线已开放。
- 按用户明确规则移除2F取证保安，TASK_02指向 `STAFF_SECURITY_1F`，更新中英文路线提示；三名取证员工仅在1F。GameManager旧楼层移除／释放逻辑无需改写；循环加载1/2/1/2/1/3/2/1验证单楼层、员工数量、节点释放、证件持久化与不可重复取卡。4F巡逻文件组件不受影响。
- 复用现有I背包与equip_card，补充第三卡未装备提示、未装备卡优先选择及槽位替换说明。三卡所有权／双槽／Q规则不改；真实I事件、A/B按钮、Q、跨层、快照恢复及03经理被抓／超时／任务推进自动通过。
- 正式接入后Godot 4.7.2 Compatibility／macOS Apple Silicon：foundation、staff_core、work_items、final_visual_integration、staff_floor_ownership、third_card_bag、task_01_main_flow、task_02_main_flow、task_03_main_flow PASS；日志单独检查脚本／资源错误，不能只凭测试末尾PASS。修复了接入期的GDScript类型推断错误及单信封后的旧测试预期。`git diff --check`通过。
- 视觉依据：此前用户已确认静态母版，动态反馈“整体基本可以”；本轮用户授权不再逐项人工确认。精确逐帧造型一致性、脚掌接地、拖把手部接触、柜内补图接缝及不同平台观感未作新的人工验收，自动状态／图集尺寸检查不能替代这些项。母版锁定，不以新的测试结果宣称全部视觉细节人工通过。
- 排除临时字体、project.godot本地接线、预览场景、生成脚本、调试适配及原始候选目录。原未提交内容／stash保留。A仍负责正式救援对白接入与04／05主线，C/D现有成果不覆盖；本轮未改房门、怪物或违规惩罚。
- 补充：TASK_02_LOCALIZATION中英文路线回归PASS。额外尝试暂存树干净导出时本机磁盘写满，未完成的导出未计通过；仅移除本轮新建的不完整导出副本恢复空间，原工作区／候选／stash未删。正式项目配置已恢复原main，所有上述定向测试在无临时Autoload下执行；缓存全新导入与目标平台导出仍不宣称完成。
## 2026-11-20 PR #48 合入最新 main 的定向验证

- 用户授权将本轮对白 PR 推送并合入 main。Fetch 后 main 为 `147e3ec`（PR #49）。合并保留 B 正式角色、工作点和一楼保安配置；202 继续显示 D 的现场逐人对白，真实路线提示读取最新任务面板。进度文档保留双方历史记录。
- Windows／Godot 4.7.2：合并后导入退出 0，怪物对白与 201／202／309 主场景回归分别退出 0；未重新记录人工 F5 或跨平台验收。
- 本次日志位于 `docs/qa_evidence/d_monster_dialogue/merge49-*.log`；旧 d0fec0d 结果保留为历史。本轮 `git diff --check` 通过。未改变 201 任务、救援与逃脱事实，也未将 203／204／205 预览伪装为正式任务。


### 2026-11-20 A：接续D并整合二楼五怪正式主流程

- 按本轮用户明确的201—205方案执行；fetch核对D分支0ce69db及main a802721，已包含B PR49一楼保安和最终交互素材。独立worktree／分支work/member-A-five-monster-tutorial开发，保留原工作区project.godot差异与全部未跟踪素材；不合入main。
- 按文件隔离：B只新增五工作点场景及独立行为测试，C只改目录／独立测试，A集中任务定义／管理器／楼层／主场景及D最小适配。保留201／202原工作链及D真实交付对白；新增TASK_T03_ROOM_SERVICE、TASK_T04_DUAL_WORK、TASK_T05_TRANSIT及独立成果，顺序、双槽、当前身份和真实工作严格核验，返房交付才解除限制。
- 同步201—205首见、工作点、路障、安全检查点、任务详情／HUD／顶部提示／重试；已完成回访及缺证／未做／部分成果阶段使用D原面板。203不改309，205不改离店／救援；205后才上3F，302保留独立登记任务，403／501不再首次教学。
- 初版独立评审指出越门、205核验滞留、HUD／元数据问题，均补RED→GREEN；真实截图另检出A task_hud覆写仍回201，已覆盖全新任务各状态并修复。旧语言与UI测试补读D真实对白；旧02楼层门槛和普通门测试按新授权迁移，保留有效断言，原生新流程不使用前置伪工作夹具。
- 最终冻结源码38项全部通过、各退出0；真实Compatibility主场景从菜单至201—205工作／交付到3F再次退出0，后三项六张原生截图已核对。覆盖缺证／错身份／部分工作／未交付、203真实被抓、204／205超时恢复和完成回访；字体584→661且原584度量不变。命令、stdout／stderr、源码／PNG哈希、失败记录与限制见docs/qa_evidence/a_five_monster_20261120。
- 未把自动／确定性夹具代记真人、实际210／240秒或Windows；新增教学英文、完整309救援／跟随、04／05与最终逃脱仍待后续。原201六项及202用户成功／超时结果不改。下一入口为新五怪真人／时限验证与D完整309交付接线；本轮仅推送个人分支并创建整合PR，远端结果以PR为准。

- 本轮实际推送：功能提交`1109dc9`已推到`work/member-A-five-monster-tutorial`，创建[PR #50](https://github.com/sd5913/ae4pa/pull/50)，base为main@a802721、保持未合并；此后仅补本文及交接／计划中的PR链接，受测运行源码未变。


### 2026-11-21 A：按真人试玩反馈修复二楼门与205

- 接续PR50的844ff9c，在原独立worktree保留全部已有资料。按本轮明确要求，将2F教学门与3F+普通门调度区分：首次完整WARNING后OPEN；任务期间住客留场；成功对白结束后关闭并从自动警报中退场；返层／重试不重复预警。对话绑定实际门口怪物，完成回访暂时只显示说话门，结束恢复未完成门与中断警报的剩余时间。
- 新增交付当前身份复核：201保洁、202保安、203经理、204保安＋指定双槽、205经理＋指定双槽；核验违规不能直接交付擦除，须退至安全区。核验OPEN范围内I提示退回安全工作台，防止背包模态绕过换证规则。
- 调整205领取／批准点至2630／2850，柜桌放大落地，移除背景沙发冲突。后三项只显示当前目标中文提示，零时长动作显示E操作而非0/0条，完成后提示下一步。保留全部真实工作与返房交付，不把持卡／对白结束当成果。
- 最终42/42定向检查均退出0；原生Compatibility从正常新局走完201—205到3F退出0。包括真实I界面选卡／按钮、Q、A/D走向205工作点和E结算，实际美术可见性断言与7张画面。位置／员工面向／怀疑阶段、任务时钟仍有显式夹具，不代记真人或实际等待。证据docs/qa_evidence/a_tutorial_playtest_fix_20261120；源哈希验证匹配，测试配置已恢复生产原文。
- 静态审查发现被其他对白打断的WARNING不能恢复，已新增RED→GREEN修复；审查会话额度中止，未声称完整独立终审。旧测试按新预警时序及揭示旗标迁移，保留原工作／恢复／互斥断言，失败证据未覆盖。
- 任务重复性的具体建议追加到五怪交接：203侧重权限与309线索，204侧重停步／安静时机，205侧重安全区配证与紧凑两阶段核验；尚未改既定任务目标。后续仍为真人新教学／时限、完整英文、309救援／跟随及04／05。此次仅更新PR50，不合入main。
## 2026-11-20 D：HUD 排版与真实状态显示

- 当前 work/member-D-monster-dialogue-current 上局部修改正式 HUD，保持其他工作区。1280×720 / canvas_items / keep 原配置未改；HUD 专用主题区分 28／20／18／16／14 逻辑字号，不改全局主题。
- 左侧提示和任务，右侧楼层和双槽；黄铜文字安全区、暖白正文、独立标题／状态与换行目标；删除重复身份显示，卡名精简、生效标记独立。真实工作受阻提示优先，已满足的身份提醒不残留。
- 完成后不再显示剩余时间；待交付仍显示真实倒计时。下一目标读取实际任务目录／前置条件，缺少统一后续主线目标时明确提示接口待提供，不伪造救援／解锁。无新 Timer，不改任务或权限。
- Godot 4.7.2 图形运行真实 main，1280×720／1920×1080／960×540，状态与长文案、卡槽、危险提示、背包／暂停／对白检查退出 0；现有 UI、202 正式主场景回归退出 0；git diff --check 通过。截图与完整修改清单见 [本轮证据](qa_evidence/d_hud_layout_20261120/README.md)。
- 图形测试使用真实接口准备状态和测试用卡片，长文案只替换复制的显示视图；不计为人工完整五任务试玩。未提交、推送或合并本轮修改。
## 2026-11-20 D：309重逢CG v2正式接线

- 保留当前HUD和其他本地工作，在work/member-D-monster-dialogue-current选择性接入用户Room309_Reunion_Pack。36拍JSON与原包SHA256一致；新版顺直短发三帧CG、帕希卡／Persica姓名、短信／立绘别名兼容。素材AI来源与原剧情在cg309_reunion/记录。
- 查明原309只有“救援尚未开放”占位且无跟随者。保留任务03与登记批准前置，真实309 E必须当前CLEANER；经理卡仍做登记授权。CG用统一模态，整段结束才调用原rescue_friend()，生成一次帕希卡；取消／菜单／新局不计成功。旧HUD改动保留并显示五楼总目标，4F之后仍遵守现有主线。
- 本机Godot4.7.2图形主场景309回归退出0：错误权限、36拍、E／鼠标单拍、回显、转场锁、取消重开、不提前救援、结束后移动跟随、重复交互、换层和新局均通过；独立F6同场景图形入口、任务03核心、序章／经理和UI回归均退出0。旧失败夹具缺键释放的记录保留；根证书诊断不阻断。git diff --check通过。
- 真实主场景和960×540截图、命令、夹具范围与限制见 [309本轮证据](qa_evidence/d_309_reunion_20261120/README.md)。前置任务通过API准备，不代记从新局人工完成三层；未代记完整04／05／EXIT通关、骨骼／逐帧动画或音效。未提交、推送或合并。
## 2026-11-20 D：按用户授权合并剩余 PR46

- PR51已合入main 78ce578。为PR46从远端原head c202ff8建立独立ae4pa-pr46-merge-final工作区，合入main，不改原D、旧UI分支和其他工作区。
- 四处冲突逐项解决：进度记录保留双方；HUD脚本／场景以PR51字号、黄铜布局、真实状态、309接线为基础，补回46的按钮信号和入口；交互进度继续挂InteractionArea。旧HUD重复身份、旧倒计时拼接和重复淡出通知不恢复。main自动合并保留309控制器，菜单动画／按钮反馈／语言和暂停返回菜单接线纳入。
- Godot4.7.2：导入退出0；真实图形菜单开场禁用输入、完成恢复、返回重播、工具栏背包／笔记／暂停检查退出0；图形HUD多尺寸、无窗口309救援／跟随及UI回归退出0。新截图与日志见docs/qa_evidence/d_pr46_merge_20261120。首次误将等待渲染帧的HUD检查用headless启动，未产生结果并手动停止，改图形运行后通过，不把该中断计为PASS。
- 原46记录中caf862d上的task_ui普通门退回失败仍保留作历史，本轮没有把它代记为通过；本次定向检查不等于人工完整五任务试玩。根证书诊断未阻断。
- 无冲突标记，git diff --check通过。309 CG、管理器、楼层、员工和门判定相对最新main无改动。随后按用户授权推送原46分支并合并，实际状态以PR为准。

### 2026-11-20 C：五楼发布前同步最新 main 与复核

- 发布前获取 main@8b6c33b，合入队友正式角色、任务02/03、怪物对话、309与HUD更新；仅进度记录冲突，保留双方全部内容。五楼状态绑定与三门配置自动合并；未覆盖队友脚本。被新main接管的8个本地3F/4F分区导入描述先移至项目外备份，未删除用户文件。
- 最新合并结果实际检查：floor_5_layout、encounter_flow、floor_flow、final_visual_integration四项PASS；Godot导入退出0，实际Compatibility图形捕获退出0，查看501开门、角色、屋顶、离店台、503及EXIT截图，未见脚本或资源错误。git diff --check通过。源PNG与ORA不变。
- 不把旧7项PASS外推至最新main：foundation旧测试出现5个移动/FAILED断言失败；task_01_main_flow在Floor1查找Stain201Slot后空对象中断，已停止。另建干净main@8b6c33b对照，完成导入后重复运行，复现完全相同foundation断言与task01空对象中断，表明并非本次5F改动引入。首轮对照误在导入完成前运行产生资源缺失，已作废，以导入完成后的记录为准。
- 额外旧world_interaction无窗口检查超时；localization旧检查引用已变更的菜单控件失败；task02/03旧主线检查空对象中断并停止，monster_dialogue旧真实主线门槛断言未通过。上述均记录为未通过，未修改队友UI或把本次美术发布记为全剧情验收。前述四项与实际图形结果覆盖本次五楼美术接入。

### 2026-11-21 C：试玩修复任务房开关与本层左楼梯退回

- 按用户本轮试玩反馈，改`door_scheduler`接管固定任务房生命周期，首次见面仍开门接介绍。201接受后关闭，真正开始清洁时通过楼层唯一E入口调用`GameManager.record_work_started`保存监督标记，直到交付对白结束才关闭，长按中断／换层回访不重置监督。202执行任务期间关闭，就绪回到门前再开，交付对白结束后关闭；302接受后不再开门。所有固定任务房完成后退出随机周期，普通随机住客房不受其同类型任务完成影响。403/501只预接通用显示策略，不启用尚未交付的04/05主线。
- E交付先由调度器`prepare_delivery`关闭上一门、打开交付门，才发实际提交请求，覆盖“入范围同一帧按E，尚未调度就弹模态”的边界；既有对白冻结保持开门直至对白结束，维持同层至多一门开启。
- 正式托管普通门的已知怪物违规现经`rule_violated`调用既有安全退回API，2—5F统一使用本层`Interactions/ReturnPoint`左楼梯记忆点；不再生成门中心隐形阻挡，也不把角色留在门右侧。保留长鼻/独眼/礼帽当前证件、大耳停步、核验附近不换证规则。退回验证来源与落点，使用既有输入锁和确认、同帧去重，不清证件/任务/倒计时；通知中英文同步改为本层左楼梯。3F在接受302前限制行走右界，接受后解除，防止绕过主线。
- 新`task_door_lifecycle_smoke`走真实201/202接取、工作组件、交付与怪物对白、实际楼梯回访、302登记批准，并检查交付同帧开启与已完成永不重开；403/501单独标注为未来状态夹具。`safe_return_smoke`更新为2—5F真实托管门从左右两侧错误身份退回、正确身份/关门通行、大耳/核验、模态核验延迟、非法来源/危险落点拒绝及任务时钟保留。旧`encounter_flow`断言同步新退回规则。三楼纯美术预览允许全走廊，正式主线门槛不变。
- 实测PASS：task_door_lifecycle、safe_return、encounter_flow、v4_doors（600规则矩阵）、v4_identity、floor_flow、floor_2/3/4/5_layout共10项；实际Compatibility图形运行完整生命周期检查也PASS。Godot导入退出0，无脚本/资源解析错误；git diff --check通过。二楼纯美术旧检查首次0.15秒冷启动计时不足导致未走物理帧，改等12个真实物理帧后PASS。
- `foundation_smoke`仍复现main@c6f1cc1修复前已存在的5条移动/FAILED断言失败，未记为PASS（此前干净main@8b6c33b对照亦相同）。本次不改菜单/开场流程，不以专项通过代记完整人工主线验收。修改留在用户个人分支工作区，用户本轮授权修复，不自动发布。

### 2026-11-21 C：任务门修复发布授权

- 用户在本轮明确授权推送个人分支并合入main，覆盖上节任务门生命周期、本层退回、302通路限制、相应接口／通知及检查。发布前已fetch，main仍为c6f1cc1，无新增主干改动；沿用该实际版本上的十项专项、Compatibility图形与导入结果，不重复代记基础测试通过。
- 仅选择本次15个已跟踪修改及新生命周期检查／UID提交；旧候选美术、源图导入缓存和其他未跟踪文件保留在本机。发布后实际PR与两分支一致性以远端核对结果为准。


### 2026-11-21 A：PR50同步最新main并解决合并冲突

- 用户本轮授权将当前已提交功能合入main。取得main@e4b2685，包含C PR52／53、D PR46／51；8个文本冲突逐段整合，保留双方文档历史。二楼按最新用户要求维持完整预警／任务住客留场，3F+保留本层左梯退回和302强制通路，保留D新HUD、309 CG与跟随、C五楼美术。
- 补齐自动合并不会提示的语义接线：后续固定任务门与FIRST拆开、工具栏背包共用核验限制、504／505不再进入目录／随机池。必要英文和3个缺字一并修复。旧测试适配真实新界面／规则，原有效断言与失败记录保留。
- 最新49项矩阵全部通过；原生正常新局201—205到3F、实际309救援接线与HUD布局复查通过。命令、失败与复查、截图、源哈希、字体度量和夹具限制见[合并证据](qa_evidence/a_main_merge_20261121/README.md)。无CI／在线部署，未导出安装包；真人和Windows不代记。
- 发布按本轮用户授权进行；远端合并提交以Git回读为准。原工作区本机配置和93个未跟踪文件保留。下次入口：本轮最新main，优先真人复测新五怪、309与普通门退回；04／05、完整英文、最终逃脱仍待后续。

### 2026-11-21 A：整理供 GPT 讨论的当前机制

- 按用户要求新增[当前游戏机制与讨论稿](current_game_mechanics_for_gpt_20261121.md)，以main@bb71226的任务定义、实际启用列表、交付／重试／楼层规则和309正式接线核对，附可直接复制给GPT的沟通要求；README补入口。
- 明确二楼五项＋三楼登记已启用，309已接入，04／05及最终逃脱未完成；将203—205差异化提案与当前实现分开，不迁移旧真人验收。
- 本轮只改文档；核对相对链接、文件空白与Git差异，不重复运行Godot测试，不提交或推送。原project.godot本机修改及原未跟踪素材保留。无新增玩法决策或需要记录的长期操作经验。
- 下次入口：用户可将整份机制稿交给GPT讨论，再按确认方案决定玩法改动；原真人复测及04／05待办不变。

### 2026-11-21 A：403／501／EXIT 接线准备

- 用户指定首要目标为接通403、501、EXIT并统一解锁／检查点。已核对实际定义、GameManager前置／快照、楼层唯一E、B巡房奖励／离店批准、C固定任务门、D成功页，当时新增接线设计稿，独立只读builder核对未发现重要规则缺口。原设计稿未收录于 main，后续实现见[后段主线交接](late_mainline_handoff_20261121.md)。
- 关键缺口：HAS_FRIEND当前被当作完成任务ID检查；巡房文件不是证件，不能套用空required_card的取证／工作身份判定；403／501未加入启用列表，正式场景未实例化工作源和安全标记；EXIT没有正式结算接线。
- 当前按brainstorming技能的明确设计确认门槛等待用户确认，尚未改产品代码、创建开发分支或提交／推送。后续按设计生成实施计划，先建立失败用例再逐项接线。
- 基线：PATH无godot，实际使用Downloads/Godot.app的4.7.2。首次foundation因未导入的新资源失败；随后headless editor --import --quit退出0（仍有FreeType字体及编辑器设置保存权限错误），重跑foundation退出1，五条失败为左右移动、左右边界、FAILED状态防绕过，另有FreeType错误。日志保留/private/tmp/ae4pa-late-mainline-{import,baseline-recheck}.stdout.log。本轮不记基线通过；文档git diff --check通过。源代码和原有未提交修改保留。


### 2026-11-21 A：接通403／501／EXIT与统一检查点

- 用户确认接线设计后直接实施：启用TASK_04_PATROL／TASK_05_EXIT，403背后长按偷文件返房交付，501当前经理批准并返房交付，EXIT统一复核真实位置／救援／任务／离店交付后WON。复用B员工和工作组件、C固定任务门、D现有面板。
- 接取前快照统一恢复，403／501分别安全点(1650,560)／(900,560)，保留救援、跟随、证件与前序成果；真实成果和卡片分开。完善当前任务HUD／详情／失败／回访与403→501→EXIT目标；成功页两按钮接通，新局清D缓存，菜单清同行。
- 最终51项检查按影响复查全部通过；另正常新局真实八任务＋36拍309 CG＋EXIT连续通过，原生Compatibility后段通过并查看截图。初跑失败、评审RED→GREEN、源哈希、测试夹具和时钟推进限制见[证据](qa_evidence/a_late_mainline_20261121/README.md)。基线在正常本机权限和ui-smoke参数下foundation通过；此前沙箱字体及缺资源失败未视为源码修复。
- [当前交接](late_mainline_handoff_20261121.md)列文件和接口。原project.godot和原有文档／未跟踪素材保留；测试用户目录配置已恢复。用户未授权提交／推送／合main，本轮均未执行。
- 下次入口：常用本地A分支F5／play.command，真人新局到EXIT；实际180秒平衡、Windows、完整英文、D正式后段剧情／外景结尾／统计待补。巡房近距离提示与角色标签重叠留D排版，不影响任务。

- 收尾：验证源码18项按哈希同步至`work/member-A-late-mainline-local-20261121`，原项目配置不变；机制稿同步更新。附加本地核心复跑被自动审批额度限制阻止而未执行，未绕过；隔离区通过证据保留。

### 2026-11-21 A：人工试玩16项改进方案（待审批）

- 按用户“先方案、审批后实施”要求，仅静态核对卡片、背包、怪物门、任务顺序、309文案和同行退回，新增[16项方案草案](playtest_improvement_proposal_20261121.md)。未改产品源码、未运行Godot、未提交／推送。
- 推荐轻量改版：一次非限时偷岗位牌教学、收藏立即使用／可选快捷槽、204任意顺序、202单个线索解谜原型、403交谈查阅领取、统一可见区禁换证、补309至EXIT因果和同步同行退回。明确这些会替换部分旧策划，尚未生效。
- 已确认代码现状：换证检测对NORMAL／STORY不一致，204第二工作受固定顺序限制，安全退回仅瞬移Player而跟随者缓动。偷证后无反应、403不放行的具体人工入口仍需复现，未将候选原因记为已修复。
- 文档16项映射、空白及git diff --check通过。下次入口：待用户批准方案范围后排实施顺序；此轮不提前接功能。

### 2026-11-21 A：只修bug与Carol／Terese更名

- 用户明确先修bug，机制调整后谈；本轮保留三次取证、双槽资格、204固定顺序、403偷文件及既有主线解锁。女主显示名Carol、闺蜜Terese；资源与内部节点ID不重命名。
- 复现并修复提前空槽Q后首次获证未激活，后续收卡不抢当前身份；已持卡重复E不再误提示先接任务。补齐剧情CHECKER门前Q／装备按钮限制，普通门沿C原违规退回；403切卡按真实任务进度说明缺记录／待交付。
- 同行订阅真实安全退回事件，女主瞬移同帧同步Terese；正常跟随保持原样。楼梯既有提示在真实范围内显示并抬到布景上方，菜单只列实际所在楼梯方向。
- 开场、电话、怪物对白、309、中英文任务／笔记与世界标签已更名，专项补齐英文旁白An／An's和安（心想）遗漏。独立只读复核未发现机制越界。
- 最新54项按影响复查全部通过；真实新局八任务与309至EXIT通过，原生Compatibility专项通过并看过三张截图。53项初跑有1个旧夹具失败，保留原清理／交付覆盖后复查通过；没有把初跑全记绿。先红后绿、原始测试入口错误、源／画面指纹和人工边界见[证据](qa_evidence/a_playtest_bugs_20261121/README.md)。
- 用户原project.godot已逐字节恢复；原有未提交修改／素材保留，未提交、推送或合main。[交接](playtest_bugfix_handoff_20261121.md)列具体入口；后续真人复测本轮修复，机制提案仍待另行批准。

### 2026-11-21 A：交互与新手引导

- 用户要求继续交互／教学；本轮对应人工清单1／2／3／5／9／10。新增实际70px楼梯地面范围／方向、随真实朝向变化的员工背后标记、I／Q／第三卡渐进提示、当前身份胸牌和短反馈、收藏拖至A／B槽、五怪已学笔记与3F以上实际门前复习，以及302短介绍和批准后保洁进309的阶段提示。
- 复用D原HUD／背包、B卡真值／工作组件和C真实门；原按钮／键盘保留，拖放仍校验所有权、有效槽与核验区。提示不暂停计时；保留三次取证、双槽资格、204固定顺序、403偷文件、真实交付和检查点。Carol／Terese显示名保持。
- 独立只读评审发现提前装备会抑制第三卡提醒，补失败例后改按具体新得未装备卡提示。另先红后绿覆盖当前槽移空提示Q、离开实际房门收起复习、真实可见HUD保留原因；普通违规同时说明退回本层楼梯。补本轮英文、双卡生效标签及三项教学任务名，OFL同源字体补9字且保留字宽和命名。
- 最新55项按影响复查全部通过，包括foundation、正常新局五怪、完整八任务／309CG／EXIT和本轮专项。初跑53／55、第一轮复查54／55与真实输入坐标诊断均保留；两项中文测试明确自身语言夹具，原断言不删。原生Compatibility中文1280×720／英文960×540实际GUI鼠标拖动、命中、释放、槽位与相关画面通过并看图；不以直接drop回调或对白预览代替正式场景。
- [本轮交接](interaction_onboarding_handoff_20261121.md)、[验证证据](qa_evidence/a_interaction_onboarding_20261121/README.md)列文件、命令、182项源码指纹、配置恢复与夹具边界；当前机制稿及公共接口同步。原project.godot逐字节恢复，既有未提交改动和素材保留，未提交／推送／合main。
- 下次入口：当前工作区play.command或F5，真人观察楼梯、背后长按、首卡I／第二卡Q／第三卡拖换、核验限制、3F怪物识别与302分阶段。Windows、真人易用性和实际长倒计时平衡待复测；一次取齐证件、收藏直接用、204任意顺序、解谜、403改交谈及309剧情改写仍未实施。

### 2026-11-21 A：按批准方案接入三身份外观

- 用户批准保洁头巾／保安帽，并确认经理只换上衣、不换原裤子后，替换旧胸前工作证卡牌：CLEANER米白紫边头巾、SECURITY紫金帽、MANAGER深青西装上衣＋米白领口，NONE原样。原棕裤、靴子、红挎包、脸与动作保持。
- 新A外观子节点在Player的Visual/Artwork下，只读CardManager.active_card并继承原镜像；cards_changed同事件同步收卡／Q／装备／快照／新局。头饰为内置imagegen透明素材；经理上衣局部处理原纹理，原人物两张PNG与HEAD一致。公共绘制仅提取只读get_render_pose，不给员工挂换装材质。
- 新外观专项与真实主场景Q／装备／移动／快照／重开专项通过。原生站立、六行走、清理共32格逐像素核对无身份原绘制、裤靴、经理头脸与红包；领口、弯腰衣角、同事件同步、透明度／染色分别先红后绿。主场景保洁双向、保安行走、经理上衣及切回原黄衣均看图。
- 最终57项回归全部通过，含foundation、员工、原引导、完整新局八任务／309CG／403／501／EXIT及检查点。独立只读复核无重要问题，透明度兼容建议补测修正。没有把概念预览或headless代作GPU画面检查，真人／Windows／实际长倒计时仍不代签。
- [接入交接](player_identity_outfits_handoff_20261121.md)、[验证与57项命令](qa_evidence/a_player_outfits_20261121/README.md)、[生成来源与完整提示词](../art_sources/player_identity_outfits/README.md)可复查；194项源码指纹、42张截图指纹、原配置恢复证明已存。原project.godot逐字节恢复，已有工作区改动／素材保留，未提交／推送／合main。
- 下次入口：当前工作区play.command或F5，人工看三身份在实际取证、Q、背包换槽、清理／行走和重试中的观感。更新原人物图集时须重核头部／上衣锚点与原生像素检查；其他机制提案不在本轮实施。

### 2026-11-21 A：整理游戏测试清单并准备发布

- 将16条人工试玩反馈、自动／原生回归结果、未批准的玩法提案、B／D侧待办，以及Windows、长时限和新版本真人验收缺口汇总到[游戏测试工作簿](../outputs/game-test-20261121/游戏测试.xlsx)，共23条，分别标记分类、BUG状态、负责人、后续动作和是否完成人工验收。
- 区分旧版验收：201成功／实际超时及202通关／超时保留用户已填写记录；不将旧版验收扩大为本次楼梯、教学、拖放、302、身份外观和后段新改动已人工验收。
- 工作簿用Artifact Tool生成，导出后重新读回核对23条记录；检查表格预览、筛选表与冻结表头。未实施建议仍按待确认记录。
- 下次入口：发布后从正常新局真人复测；尚未实施的玩法建议先单独确认，Windows及403／501实际计时仍待验证。

### 2026-11-21：整理 GitHub 文档入口

- [PR #55](https://github.com/sd5913/ae4pa/pull/55) 已把 A 侧主线和测试工作簿合入 `main@d189e02`。首页增加工作簿下载入口，[文档目录](README.md)集中提供试玩、验收、开发、交接和历史记录。
- 更新中英文玩家指南、组员接入、执行清单和 QA 入口。旧房间表明确标为历史资料，现行路线以[游戏机制](current_game_mechanics_for_gpt_20261121.md)为准。
- 核对 Git 差异、文档链接和工作簿文件结构。本轮为文档整理，真人验收继续以测试记录为准。
### 2026-11-21 D：英文标题、怪物档案与剧情界面

- 在 main 最新记录之后追加本轮 D 交付：接入英文标题图、十页手册、按实际遭遇解锁的怪物档案，以及手机震动和剧情 UI 调整。保留 main 的 A/C 进度与历史记录。
- 运行证据和未验证项沿用本分支已有记录；本次同步后的复测结果另行记录，不把同步前结果冒充为本次验证。

### 2026-11-21 B：FB-02 偷卡站位颜色与真实资格一致

- 基线 main@49dc7d8。定向复现：保安、保洁、经理的背后站位在员工移动、玩家移动或交互禁用时仍亮绿，但真实 begin_steal 拒绝。原有首卡、拖放及身份外观修复保留，不重复开发。
- 仅修改 B 的 staff_interaction_guide.gd：绿色读取已有 READY／STEALING 状态，其余沿用黄色；不更改员工状态机、0.8秒长按、范围、失败、卡槽或任务规则。
- 在现有 staff_core_smoke 中补覆盖，修复前9项错误颜色断言失败，修复后该场景及 interaction_onboarding_smoke 自动 PASS。环境为 macOS／Godot 4.7.2；后者加载真实 main、员工与引导，不等于真人视觉验收。
- 工作簿 FB-02 记录本次补修、日期、代码提交及待真人复测；其他易用性、任务顺序、怪物规则和关卡／剧情提案不在本批实施。

### 2026-11-21 B：PR #58 追加证件与工作点反馈

- 保留上一批站位修复，不重测 FB-02 绿灯。定向确认原员工 GOT ID 未区分收藏、装备和当前身份，取消无可见原因；完成工作点 can_interact 仍为 true，与 begin_interaction 拒绝重复操作不一致。
- 复用员工现有 FeedbackLabel／Timer，分别显示收藏、A/B装备或未装备、真实生效身份；显示期随换槽／Q同步，重开清除。取消按松键、移动、离开、员工移动等原因提示，被抓优先保留原 CAUGHT／失败信号；不改长按、范围和奖励规则。工作点仅补完成状态守卫。
- 实际回归：third_card_bag_smoke --ui-smoke、work_items_smoke.tscn、tutorial_workpoints_smoke 均自动 PASS（macOS／Godot 4.7.2）。含当前槽替换即生效、备用槽需Q、HUD／配饰一致、403文件非证件、501错身份及已完成不可重复；未做全量回归或真人视觉验收。
- A/D待处理：bag_adapter 无论替换当前槽还是备用槽都建议Q；全局I/Q提示和错误双卡组合与任务未开放的解释在A/D接线层，本批只记录，不改背包布局、资格、顺序、门或楼层。
- 原工作簿更新 FB-02／05／23；完成工作点接口矛盾单列本轮自动发现的组件Bug，不冒充新增真人反馈。代码提交与限制写入工作簿及PR #58；继续开发，暂不请求A审核。

### 2026-11-22 D：怪物对白统一为标准剧情框

- 在 work/member-D-delivery-closeout 复用 dialogue.tscn：monster_dialogue.gd不再创建独立绿色面板，201—205现有各阶段与302／403／501公开对白入口共用奶油正文、金边、姓名框。无继续按钮和怪物序章跳过按钮。角色ID与英文名称映射在 dialogue_roles.gd；已有怪物中文台词全部补齐英文目录。
- 只改D显示和输入适配，不改任务／发卡／结算。暂时降低HUD、独立怪物视觉和引导提示透明度，关闭后恢复。已有任务守卫、原子模态交接、完成事件单次触发与预览不改状态断言保留。
- 五种怪物正式高清半身立绘均缺失，未放大362×543场景帧。Carol沿用标准人物槽；怪物半身尺寸／头肩对齐未验收。部分小剪影已烘焙在门OPEN图内，需素材负责人提供干净门图；没有修改A/C门行为。
- Godot 4.7.2 Windows：资源导入退出0；中文1280×720／英文960×540正式场景怪物回归各退出0；intro_flow、story_surface、localization、late_mainline、HUD图形布局均退出0。英文台词覆盖和单次输入、HUD恢复断言通过。未进行人工新局完整八任务通关。实际截图、映射和日志见[证据](qa_evidence/d_monster_surface_20261122/README.md)。
### 2026-11-22 CI：Windows 试玩包

- 基于 `main@cc52b6d` 增加 Godot 4.7.2 Windows x64 导出配置、GitHub Actions 和 README 下载入口。Actions 浅检出并校验 LFS 对象；该基线没有 LFS 指针。
- Linux 本地用同版官方模板验证导入、本地化和 Windows 导出。解压测试包后确认 EXE、PCK、提交 SHA 文件齐全；同版 Linux 运行模板可从解压后的 PCK 启动。删除导出包含规则后，即使仍生成 EXE 和 PCK，独立检查也会因缺少序章 TSV 而失败。
- Actions 中另设 Windows 无界面启动检查和完整通关检查。基线完整通关检查复现 `ROOM_SERVICE_203`、`TRANSIT_REGISTER_205` 的 `TASK_INACTIVE` 和最终通关断言失败；该结果单独记录。图形、输入和人工通关待 Windows VM 验收。

### 2026-11-22 C：五怪独立透明半身立绘发布

- 用户选择前面单独生成的五张Alpha透明底PNG，并明确忽略后来的横向画风确认图；授权推送个人分支、合入main。资产路径assets/final/monster_dialogue_portraits_v1，分别为nose/eye/hat/ear/checker_halfbody.png，保留原始文件字节，不重新绘制或转码。
- 五张均为1024×1536 RGBA，Alpha范围0—254，含真实全透明像素；逐张SHA256与生成时validation.json一致。art_sources/monster_dialogue_portraits_v1保留内置imagegen原始提示词和Alpha校验报告，素材README说明透明混合和隐藏RGB。
- 本次仅发布五张独立素材及必要说明、提示词／校验，不包含横向合图、不替换运行时对白或怪物动画。fetch后main仍cc52b6d，选择性暂存及git diff --check；不为纯素材新增玩法测试或声称游戏对白已接入。

### 2026-11-22 D：UI polish v4 与五怪正式半身

- 从最新main 569b5d0建立 work/member-D-ui-polish-v4，代码／测试提交35b2400245cfb3bce6e4183dae7c71e9a76d3bcd。用户微信ZIP与main五张PNG哈希完全一致，复用assets/final/monster_dialogue_portraits_v1，不复制第二套资源。
- 接入五怪固定Atlas裁切；标准人物槽底部／姓名牌／正文统一，Carol、Terese和员工按整套表情共同轮廓固定裁切；修复短信布局后最终滚动和旧滚动请求；按钮改为黄铜矢量状态；正式HUD四按钮上移，楼层／双槽在下且楼层底图等比；笔记增加宽度与滚动区、关闭键和模态恢复。未改任务、主场景、卡片或门规则。
- Godot4.7.2 Windows：资源导入、手册、剧情输入、本地化、ui_test、怪物对白、HUD布局全部自动退出0；真实five_monster正常新局201—205自动退出0。新定向main场景中文1280、英文960、1920布局与笔记10次开关／菜单重入均退出0。英文初次断言逻辑坐标与物理宽混比的失败保留，修复坐标系后通过；没有去掉检查。
- 已生成实际截图与20.1秒Godot录屏，区分真实五怪任务与主场景review；人工完整八任务／后段路线未代记。物理H启动页未观察到打开，InputEventAction关闭／暂停模态已自动通过，物理键人工复核仍待联调。原门图烘焙小剪影和原图轻微暖边保留，未改A/C模块。详见[本轮证据](qa_evidence/d_ui_polish_v4_20261122/README.md)。
- 补充快捷键代码提交36a4a77：按InputMap匹配真实InputEventKey，H／Esc十次开关、help_keys和ui_test_keys自动退出0；桌面注入键未观察到响应，鼠标点开始正常，硬件键盘人工复核未代记通过。

### 2026-11-22 C：新版核验怪站姿动画替换与发布

- 用户确认浅暖棕头发描边的新版核验怪及8帧待机图，并授权替换游戏、推送GitHub和合入main。基于main@569b5d0建立独立动画发布分支，避免把尚待A验证的PR65复核提交一起合并。
- 无损替换assets/final/monster_idle/checker_idle_sheet.png，1448×1086／4×2／单格362×543，Alpha0—255；SHA256 19fff3637b7c010ae3266ed037bbe97546831b03e2a7885c72f5ef978e00d98e。其他四怪PNG逐一核对与manifest原hash一致。源母版、浅发边修改提示词、动画原始提示词与8帧边界保留在art_sources/monster_idle/checker_v2。
- 共用动画适配器只调整CHECKER脚底锚点512→494及8帧时长400/150/170/230/160/180/180/350ms。保持完整格切片、原有角色缩放、开门显示/关门隐藏/模态冻结，不修改门判定、任务、UI或移动。
- 实际Compatibility图形夹具在真实floor2/5门205/501检查8帧区域、脚底锚点、开关门显示、暂停与恢复，退出0并查看4张开关门截图；显式全任务已完成的美术夹具，不代记完整主线通关。tutorial_lifecycle、known_monster_rules、floor_5_layout、checker_safe_bag四项回归PASS；导入退出0，无脚本解析错误，git diff --check通过。截图和临时检查脚本位于本次会话outputs/checker_v2_in_game及work，未纳入运行时资源。

### 2026-11-22 A：整理项目上下文文档

- 从 GitHub 核实的 `main@dca61f7` 建立独立工作区。[当前项目状态](CURRENT_STATUS.md)集中记录实现、自动化和真人待验；同步项目首页、文档目录、开发规则、里程碑、接口和 QA，并保留早期记录的范围。
- 审查基线中的 macOS 定向通过、整链两次失败和 Windows 历史证据分别记录。文档实施阶段沿用该审查证据，未重跑 Godot。
- 验证：八份 Markdown 的相对链接和锚点检查通过，跟踪文件及新增状态页的空白检查通过。独立工作区只包含文档改动。
- 下次入口：[当前项目状态](CURRENT_STATUS.md)的首项复测，由 A 牵头核对完整新局的 EXIT 阻断条件，C/D 按模块协查。真人、同提交跨平台与导出继续待验。

### 2026-11-22 A：补录真人完整通关

- 用户确认已完整通关，未发现问题。已同步[当前项目状态](CURRENT_STATUS.md)、[执行清单](../PLANS.md)和[QA](qa.md#已记录的真人通关)。试玩提交、平台和 Godot 版本待补录。自动化结果沿用原记录。

### 2026-11-22 A：接入 Linux Godot CI

- 从 `main@bf00cde` 建立独立工作区。[阶段 B PR](https://github.com/sd5913/ae4pa/pull/68) 接入 Linux Godot 4.7.2 的干净项目导入和八项定向 smoke。每项使用独立用户数据目录，执行日志随 GitHub Actions 运行留存。
- 临时诊断定位到旧基线 501 交付后的 E 释放等待，详情见 [QA 历史记录](qa.md#历史自动回归失败与诊断)。当时完整主线测试保留原断言，尚未接入首版 CI。游戏源码、场景和素材未改动。

### 2026-11-23 A：同步项目状态与主线 CI 证据

- 当前 GitHub `main@cac0214d9845a2bae8c6dcb7a55000755e10e19c` 已合并阶段 A 文档 PR #67、阶段 B Linux CI PR #68 与 Windows 构建 PR #60，以及阶段 C 项目技能 PR #69。
- 主线 [Linux Godot CI](https://github.com/sd5913/ae4pa/actions/runs/45100701304) 干净导入和八项 smoke 通过；[Windows workflow](https://github.com/sd5913/ae4pa/actions/runs/45100701293) 导入、本地化、Windows x64 导出／包检查和 runner 无界面启动通过。其非阻断 full-mainline 步骤从正常新局报告八项真实任务及 309 CG 路线 PASS，同时保留 203／205 `TASK_INACTIVE` 诊断输出。
- `main@dca61f7` 的两次 EXIT 断言失败继续作为历史证据；不再列为当前 main 的复现失败。新 CI 不代替画面、实机键鼠、真人及同 SHA 跨平台验收。
- 本轮只同步 Markdown 状态、流程与 QA，不改 Godot 脚本、场景、素材或工作流。


## B 本地既有修复交付保存（2026-11-25）

- 分支：`work/member-B-interaction-batch1-20261123`，基线 `ac58302`；提交号以本条所在Git提交为准。
- 保存FB-05/23收藏／装备／生效提示、FB-18巡房提示去重、相关英文与工作资格提示；保存清洁姿态隔离、204正式污渍、审批单命名与接受成功后的局部反馈、302批准→309寻找Terese的现有剧情引导。未改双卡规则、任务顺序、怪物或房门机制。
- 本次导入及四项定向自动回归PASS；沿用11月24日正常新局八任务到EXIT的自动结果，详见[QA](qa.md)。不写成人工验收通过。
- 排除工作间预览、临时字体、截图、缓存、本地配置及未确认的审批桌布局微调；这些资料继续在本地／原备份中保留。
- A/D接力：main已到48c0b5c；翻译与新手提示存在三方冲突，需后续单独对接D记忆/UI改动。本次只保存上传开发分支，不合main、不创建PR。
- 环境备注：保留4个stash引用，不应用／删除；其中一份旧stash已有两个关联对象缺失，未在本轮擅自修复。原Documents备份部分为云端占位文件，另存一份可本机读取的Codex持久备份。
### 2026-11-23 D：封面按钮、HUD与工作人员待机

- 实测代码 `1e817cc0e33e7f9263d49be9dc0914d583b99d1c`，含独立共享视觉修复 `e36e3cc`；当前分支 work/member-D-ui-polish-v4。封面两项统一280×56／14px间距，语言文字独立居中；按钮反馈改0.12秒颜色；HUD图标换28px矢量，任务牌上移24px并去除重复目标。共享视觉脚本只固定保安／经理普通站姿，不改行走、警觉、碰撞、速度或任务规则，交A/B审查。
- Windows / Godot 4.7.2：导入、中文1280与英文960图形main场景检查、现有HUD布局、foundation、final_visual_integration、员工core／cleaner、localization与ui_test最终均退出0；git diff --check通过。最初错误入口／配置及移动夹具断言失败留日志，并已按真实入口／新配置重跑。
- 实际main场景截图、前后来源、16.8秒静止与启停录屏及限制见[本轮证据](qa_evidence/d_button_idle_20261123/README.md)。截图已目视检查；录屏供A/B审看，未代记物理键盘人工或导出验收。保留所有原未跟踪文件，不合并main。
### 2026-11-23 D：剧情UI润色、双装备教学与超时演出

- 实测代码81c5451abeed7c8f75c88d5b16ce045bce0bd9aa，work/member-D-ui-polish-v4。唯一语言文字层、箭头内移、跳过置顶、六条中英旁白、背包圆形关闭、弹窗留白与精简暂停；D标准对白组件增加真实2/2教学与两类超时第二拍。任务、卡片、失败事实与检查点规则不变。A task_ui现有请求接线已复用，无需新接口。
- Windows Godot4.7.2：导入、本地化、intro_flow、story_surface、ui_test、三卡双槽（--ui-smoke）、checkpoint、theft最终退出0；新增main图形中文1280／英文960、两种超时与重试、单次教学／通知、菜单清理、楼梯／任务详情和右上跳过检查退出0；git diff --check通过。历史测试入口／类型／旧布局预期失败记录保留。
- [正式场景截图、15.97秒自动录屏、文案对照、日志及限制](qa_evidence/d_ui_narrative_20261123/README.md)。任务前置用公开API，A时钟加速触发超时；不是人工等待完整时限或人工全通。截图已目视核对，物理操作／跨机器／导出仍待验收。未生成CG、不替换Carol、不合并main。原无关未跟踪文件保留。


### 2026-11-24 D：记忆界面与已读历史交付（完整存档待 A）

- 保留原工作并在 work/member-D-memory-ui-review 交付；已合入 origin/main@ac58302，合并提交 a57fdeb。旧 PR #64 已合并，本轮使用新审查分支。本轮代码 3f2972359338f00d427f8a9c2e0c606feffd300b；记录整理未修改运行代码。
- 已安全读取 Downloads/Memory_UI_Pack_v1.zip 的完整 prompt、HTML 和三页图，选择性导入背景及七个 SVG；正式封面新增禁用态读取入口，剧情/暂停提供三页入口，六手动槽和独立自动槽、确认请求、模态焦点隔离与会话已读历史。移除旧2/2矩形提示来源，保留 Carol 教学。没有创建假存档或复制 HTML 示例状态。
- Windows Godot 4.7.2 Compatibility：3f29723 的记忆 UI 中文1280、英文960、中文1920三次图形回归均退出0，含真实GUI点击及跨设备物理Esc事件；a57fdeb干净副本导入、本地化、intro_flow、三卡双槽、checkpoint、ui_test、theft、正常story_surface及narrative图形回归均退出0。失败的早期入口/跳动画参数运行日志保留，未修改断言掩盖。详细命令、SHA、环境和截图见[本轮QA](qa_evidence/d_memory_ui_20261123/README.md)。
- 正常正式窗口鼠标验证了未读历史为空、打开首条短信后只记该条、关闭仍停原句；键盘注入曾受 InputMap device=16 影响，最终 D 按键匹配修复已用 Godot raw events 验证，真实硬件验收仍待做。
- 完整磁盘存储、原子覆盖/备份/坏档、跨进程卡片/计时/任务/309单跟随者/EXIT恢复、309全屏CG历史事件及保存→退出→重启录屏均未完成。请 A 按[状态归属及接口清单](memory_ui_handoff_20261123.md)接入；D页面禁用保存/读取并明确提示缺少服务。先审查，不合并main。未清理任何原未跟踪文件。


### 2026-11-24 PR #74 合并前检查

- 按用户最新指令拉取并准备合并；远端 main@ac58302，功能分支此前15a1a79。PR #74 无冲突，但旧 Linux CI 的 late_mainline 失败，日志见 https://github.com/sd5913/ae4pa/actions/runs/45362472145 。其他七项 smoke 和导入已通过。
- 定位为独立夹具未读完新增双装备教学就换层、超时对白尚未结束就点隐藏重试，以及旧断言要求任务框外重复返回501目标。本次只改独立测试：真实输入读完演出，确认失败菜单可见后重试；清除旧错误反馈的断言改为文本及tooltip均空，同时保留任务牌内501交付目标断言。没有关闭教学/超时、改任务规则或跳过断言。
- 测试代码481cd5c15aad150033ecfc86663b3c26c94d8716：Windows / Godot4.7.2.stable.official.ed1daf0bf，隔离APPDATA，headless late_mainline_main_flow_smoke.gd -- --ui-smoke（中文）及 -- --ui-smoke --english 均退出0。覆盖403/501工作、交付、超时恢复、真实EXIT及成功页重启/菜单；前六任务和救援由公开/既有夹具准备，不是人工新局通关。旧失败日志保留于[合并复测证据](qa_evidence/pr74_merge_20261124/README.md)。最新云端CI须以本次推送后的运行结果为准。
- 完整记忆磁盘保存/恢复仍待A接入，未将本次后段回归记为跨进程存档通过。所有原未跟踪文件保留。


## 2026-11-25 B e200548 与最新 main 整合验证
- 基线：B `e200548960e15bab3757f6aca62df08e4bcf3b2d` + main `48c0b5c137003beeaf8a4b72472ded0695ba8e00`，独立 worktree；原未提交布局、工作间、临时字体/预览均未纳入。
- QA/进度末尾冲突并列保留双方记录；保留D新证件/超时对白及记忆UI，保留B交互优先与全部交付修复；英语重复巡房记录键统一为main较新措辞。
- Godot 4.7.2.stable.official.ed1daf0bf / macOS Apple M1 Pro：本轮自动PASS：third_card_bag、interaction_feedback_batch、tutorial_workpoints、final_visual_integration、localization、memory_ui、full_mainline_escape（正常新游戏→八任务→309→EXIT，含失败恢复）。
- 两个旧主线/反馈测试适配D正式教学/超时对白的真实E输入后再请求上楼和重试；未绕过弹窗/任务规则、未削弱断言。203/205错误资格TASK_INACTIVE为预期拒绝。
- 自动测试不等于真人视觉验收；整合后F5窗口供玩家复测。首次受限沙箱字体/日志错误不计为有效PASS；有效测试使用正常本机权限。

- CI联调补充：首轮Linux仅late_mainline旧断言（审批后HUD为空）失败；已改为精确验证501审批成功/交付文案及组件成功反馈，中英文定向PASS，保留全部任务/失败恢复断言。远端CI待追加提交重跑，不能把首轮记作通过。

### 2026-11-23 Linux／macOS 桌面打包交接

- 基于 GitHub `main@ac58302b29499a4243dd302876a8f24e84be013a` 新增 Linux x86-64 与 macOS Universal 2 预览。沿用 Windows 的资源包校验和 Godot 4.7.2；启用 arm64 导出所需的 ETC2／ASTC 导入。
- [打包与发版说明](desktop-release.md)记录预览验证、签名环境与密钥格式、受保护主线版本标签及学生发布流程。macOS 预览仅使用临时签名；GitHub 发版草稿必须通过 Developer ID 签名、公证、装订及验证。
- Linux 上使用匹配的 Godot 4.7.2 验证了 ZIP 解压启动、中国简体与英语配置、本地化检查及三平台 PCK。macOS Universal 2 通过 Linux 交叉导出与 Mach-O 检查。详见 [桌面打包分支验证](qa.md#桌面打包分支验证2026-11-23)。
