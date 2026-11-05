# 怪物员工通道 GitHub 四人协作指南

适用仓库：[sd5913/ae4pa](https://github.com/sd5913/ae4pa)。A 管公共底座和整合，B 管员工与卡片，C 管房门与怪物，D 管界面、剧情和测试。本指南按“本机 Codex 开发、Godot 验证、GitHub Desktop 同步”的操作方式讲解。

团队采用一条简单流程：**更新公共版本 → 回自己的分支开发 → 本机测试 → Commit → Push → 提 PR → A 检查并合并 → 全员同步。**

## 1 你们仓库现在是什么情况

2026-11-05 22:44（Asia/Hong_Kong）只读检查时：

- 仓库属于 GitHub 组织 `sd5913`，是公开仓库，默认分支为 `main`。
- 已有 `main`、`work/member-1`、`work/member-2`、`work/member-3`、`work/member-4` 五个分支，全部指向初始 Godot 提交 `4192a1a`。
- 没有待合并的 PR；`main` 返回未保护，规则集列表为空。
- 云端 main 只有初始项目文件，还没有 A 本机新建的 `scenes/`、`scripts/`、`docs/` 等底座内容。
- A 本机当前分支为 `ling/identity-shift-prototype`，底座改动尚未提交或上传。

**首次协作由 A 发布公共底座，成员同步后再开始功能开发。** 以上是发布前的历史快照，后续状态以 [云端文件](https://github.com/sd5913/ae4pa)、[分支列表](https://github.com/sd5913/ae4pa/branches)、[PR 列表](https://github.com/sd5913/ae4pa/pulls) 为准；本次发布记录见 [进度文档](progress.md)。

## 2 先认清这些名字

| 名字 | 用你们的项目理解 |
|---|---|
| 仓库 Repository | 整个游戏项目及其修改历史 |
| main | 大家共享、经过检查、能运行的公共版本 |
| 分支 Branch | 你做自己功能的一条工作线；切分支会改变本地项目文件 |
| Commit 提交 | 在本机保存一份有说明的修改记录 |
| Push 上传 | 把已提交的记录上传到 GitHub 的对应分支 |
| PR / Pull Request | 请求把自己的分支改动加入 main，供 A 检查 |
| Merge 合并 | 把分支中的改动纳入另一条分支的历史 |
| Fetch / Pull | Fetch 检查远端更新；Pull 把当前分支的远端更新取到本机 |

例如 B 写好偷卡：先保存文件，再 Commit 到自己的分支，再 Push，然后向 main 提 PR。上传个人分支后，网页默认显示的 main 不会立即变化；A 合并 PR 后，main 才加入这项功能。[提交操作说明](https://docs.github.com/en/desktop/making-changes-in-a-branch/committing-and-reviewing-changes-to-your-project-in-github-desktop)、[PR 操作说明](https://docs.github.com/en/desktop/working-with-your-remote-repository-on-github-or-github-enterprise/creating-an-issue-or-pull-request-from-github-desktop)。

## 3 谁在哪个分支做哪些文件

沿用仓库现有 `work/member-*` 即可。**下表的人与编号是建议分配，尚未核实你们实际对应关系；已有分配就按现状，由 A 确认后填写。** 分支名不需要与 V2 中的示例完全相同。

| 成员 | 建议对应分支 | 负责范围 |
|---|---|---|
| A | `work/member-1` | `project.godot`、主场景、Player、楼层、GameManager 和整合 |
| B | `work/member-2` | `scenes/staff/`、`scripts/card_manager.gd`、员工测试场景 |
| C | `work/member-3` | `scenes/doors/`、房门测试场景 |
| D | `work/member-4` | `scenes/ui/`、界面测试场景、QA 和说明材料 |

A 这次底座可以先从当前的 `ling/identity-shift-prototype` 提交 PR，不必带着未提交文件切到另一个分支。底座发布后再安排后续工作分支。

每个人都能读取整个项目，主要修改自己负责的文件。需要改公共接口时先与 A 对齐；素材由全员选择、使用者导入。接口和 F6 入口分别见 [公共接口](interfaces.md)、[组员接入](onboarding.md)。

## 4 A 现在先做一次公共底座发布

1. 在 GitHub Desktop 选择仓库 `ae4pa`，确认 Current Branch 是本机当前功能分支 `ling/identity-shift-prototype`。
2. 在 Godot 保存项目并验证 F5。检查 Desktop 的 Changes 列表，应包含新场景、脚本、UID、文档和项目配置；`.godot/` 与 `builds/` 不应提交。
3. 填写提交说明，例如“A：建立可运行公共底座和团队文档”，Commit 到当前分支。
4. 点击 Publish branch；如果该分支已发布，则点击 Push origin。等待上传完成。
5. 创建 PR，确认 **base 是 main，compare/head 是当前底座分支**，填写改动和实际验证情况。
6. 请另一名成员查看这次 PR；A 按第 7 节完成测试和合并。若启用了一个审批要求，A 自己的 PR 需要由另一名有相应权限的成员批准。
7. 在 GitHub 的 main 页面确认出现 `scenes/`、`scripts/`、`docs/` 等新文件，再通知组员同步。

当前本机有许多未提交文件，应先在现有分支完成提交，再切换分支。Desktop 出现未提交修改的提示时，先确认这些修改属于谁，保留它们，不使用 Discard 来解决分支切换问题。[GitHub Desktop 分支操作](https://docs.github.com/en/desktop/making-changes-in-a-branch/managing-branches-in-github-desktop)。

## 5 每个人每天开始前怎么同步

下面以“B 分配到 work/member-2”为例，其他成员替换成自己的分支。

1. 保存 Godot 文件。若自己有未提交改动，先在自己的分支检查并 Commit；适合交接的提交再 Push。保存、停止 Godot 运行，再切分支。
2. Desktop 切到 `main`，点击 Fetch origin；若出现 Pull origin，再点 Pull origin。此时本机 main 更新。
3. 切回 `work/member-2`，Fetch／Pull 该分支自己的远端更新。
4. 在 Current Branch 菜单选择 **Choose a branch to merge into work/member-2**，选择 `main`，确认方向为 **Merge main into work/member-2**。
5. 合并成功后 Push origin，自己的云端分支也就包含最新公共底座。
6. 打开 Godot 检查自己的 F6 场景，再开始让 Codex 修改。

**在个人分支点 Pull，只会同步那条个人分支；要取得 A 刚合并到 main 的内容，还需要第 4 步。** 上述操作对应 [GitHub Desktop 官方同步流程](https://docs.github.com/en/desktop/working-with-your-remote-repository-on-github-or-github-enterprise/syncing-your-branch-in-github-desktop)。

| 合并方向 | 目的 | 谁操作 |
|---|---|---|
| `main → 自己的分支` | 取得公共更新后继续开发 | 每位成员 |
| `自己的分支 → main` | 交付功能并加入公共版本 | 提 PR，由 A 检查后合并 |

## 6 做完一个小功能怎么交给 A

一次 PR 只交一项能独立检查的小功能，例如“一名保安会转身并能偷卡”。

1. Godot 保存，F6 验证自己的组件；公共功能受影响时同时 F5 回归。
2. 在 Desktop 看 Changes，确认没有误改他人的文件。
3. 填写清楚的 Summary，Commit 到自己的工作分支，再 Push origin。
4. 在 Desktop 使用 Preview Pull Request / Create Pull Request，或在仓库网页 Pull requests → New pull request。
5. 核对 base 为 `main`，compare 为自己的分支，创建 PR 并请 A 查看。尚未准备验收的工作可标记 Draft。

PR 描述可以复制下面的格式：

```text
做了什么：B 新增一名保安的转身与背后偷卡。
修改范围：scenes/staff/、scripts/card_manager.gd、自己的测试场景。
怎么运行：打开 scenes/tests/staff/staff_test.tscn，按 F6。
实际测试：背后偷成功；正面失败；中途转身失败。
A 需要接入：staff.tscn，调用 setup(player)，监听 card_stolen。
证据和限制：附截图／视频；列出尚未实现或未测的部分。
```

“实际测试”只填写自己确实做过的项目。A 要求修正时，在原分支继续修改、Commit、Push，同一 PR 会更新，无需为同一项修正另开 PR。[创建 PR 的官方步骤](https://docs.github.com/en/desktop/working-with-your-remote-repository-on-github-or-github-enterprise/creating-an-issue-or-pull-request-from-github-desktop)。

## 7 A 怎样检查和合并 PR

1. 在仓库网页打开 Pull requests，选中成员的 PR，确认合并目标为 main。
2. 看 Files changed：文件是否属于该成员；接口是否与文档一致；有没有缓存或不相关改动。
3. 先保存、提交自己当前工作，再在 Desktop 的 Current Branch → Pull Requests 中打开该 PR 分支。刷新并取得最新提交，再打开 Godot测试。
4. 要求该分支包含最新 main，运行成员的 F6 场景及 F5 主流程。若只交了独立组件，main 中尚未接入的部分另列整合任务。
5. 有问题就在 PR 留下可复现的反馈，等成员修正后再检查。不要为减少差异而直接覆盖其整个文件。
6. 测试通过、讨论处理完后，在网页选择普通合并 **Create a merge commit**，点击 Merge pull request 并确认。
7. 更新本机 main，再运行一次公共版本；通知全员按第 5 节同步。一次合一个 PR；测试后 main 若又有变化，合并前先重新同步并检查。

PR 分支的打开方式见 [本地查看 PR](https://docs.github.com/en/desktop/working-with-your-remote-repository-on-github-or-github-enterprise/viewing-a-pull-request-in-github-desktop)，网页合并见 [合并 PR](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/merging-a-pull-request)。

你们现在采用长期个人分支，建议统一普通 merge commit，并保留 `work/member-*` 分支继续使用；检查时仓库没有开启合并后自动删除分支。GitHub 官方提示，长期复用的分支反复 squash，后续 PR 可能重复出现旧提交或冲突；暂时不需要学习 rebase。[合并方式说明](https://docs.github.com/en/pull-requests/reference/pull-request-merges)。

**GitHub 显示“可以合并”，表示它能处理文件差异；游戏是否正确仍要在 Godot 验证。** B 的卡片、C 的门、D 的 UI 按依赖接入，周末小样先 B、再 C、最后 D。

## 8 A 怎样管理权限和 main

以下为建议设置，尚未替仓库启用。

**人员权限。** 在仓库 Settings 的 Collaborators and teams／访问管理页面，确认成员有仓库写权限；A 保留管理权限，B/C/D 使用 Write 即可。组织仓库可以按成员或团队授权，已有组织基础权限时一并核对。组织 Owner 自动拥有仓库 Admin 权限，仅在仓库里选择 Write 不能降低其组织 Owner 权限。[组织仓库角色](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization)。

**main 保护。** 在 Settings → Branches → Add classic branch protection rule，为 `main` 建立规则：

- 要求通过 PR 合并，并要求 1 个审批。
- 保持不允许强制推送和删除；不要勾选 Lock branch，否则会把 main 设为只读。
- 当前没有接入 GitHub 自动检查，先不要求不存在的 status checks；普通 merge commit 流程也不要求线性历史。
- A 自己的 PR 请 B/C/D 中另一人审批，避免把“自己批准自己”当成正常流程。

按团队约定由 A 点击合并。**Write 权限本身也能合并 PR；“要求一个审批”并不自动等于“只有 A 能合并”。** 若要技术上限制 main 的更新者，组织仓库可额外配置 Restrict who can push to matching branches，只加入 A 的实际 GitHub 用户名，并保留 PR 要求。`sd5913` 是组织名，不要把它当成待选的个人账号。[保护规则设置](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)、[保护规则行为](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)。

本阶段不需要复杂管理系统：A 列清当前四个人各做哪一项，D 记录 BUG；可用仓库 Issues 给任务指派负责人，在 PR 中关联任务。

## 9 出现冲突或按钮不可用怎么办

| 遇到的情况 | 怎么处理 |
|---|---|
| Push 之后 main 没变 | 先在网页分支下拉框看自己的分支；功能要经过 PR 合并才进入 main |
| PR 没有可比较的改动 | 核对选中的分支、是否 Commit／Push，以及该分支是否真的有新增内容；当前仓库初始五个分支内容相同是正常的 |
| 提示不能自动合并 | 提交者先把最新 main 合进自己的分支，解决冲突，再测试、Commit、Push；A 重新检查原 PR |
| 切分支时提示未提交修改 | 先确认并保存当前改动；不要直接 Discard，也不要把 A 的底座带到成员分支 |
| 合并按钮不可用 | 检查是否 Draft、缺审批、未解决讨论、保护规则或冲突；不要通过强制推送绕过 |
| 同步后游戏打不开 | 保存报错、场景和分支信息，交给对应负责人；先修最小问题，不重写整个项目 |

冲突表示两边改动需要决定怎样同时保留。可让 Codex 读取冲突文件及公共接口，先解释差异，再做最小修复。`.tscn` 的节点和资源引用要一起检查；删掉冲突标记后，还需让 Godot 实际加载和运行。

## 10 给本机 Codex 的任务模板

把角色、分支、文件和目标换成自己的内容：

```text
我是本项目的 B，工作分支由 A 分配为 work/member-2。
先读取 AGENTS.md、docs/interfaces.md 和 docs/onboarding.md，检查当前分支及已有改动。
本次只实现一名保安的转身和背后偷卡。
只修改 scenes/staff/、scripts/card_manager.gd 和 scenes/tests/staff/。
沿用 GameManager.fail、CardManager.collect_card 和 setup(player) 接口。
缺少依赖时先说明，不重写 A/C/D 的模块，不覆盖已有工作。
完成后列出修改文件、Godot 测试入口、实际验证结果和未完成项。
本次 Git 操作由我在 GitHub Desktop 完成，请不要自行提交、推送、合并或删除分支。
```

每日记住两件事：**开工先同步 main 到自己的分支；交付先本机验证，再 Commit、Push、提 PR。**
