# 2026-11-21 PR50 与最新 main 的合并检查

目标：main@e4b2685（含PR46、51、52、53）与二楼五怪试玩修复@7dc3f88。用户本轮明确授权解决冲突并合入main；本页记录合并前的实际证据，最终远端提交以Git回读为准。

## 冲突处理

8处文本冲突：docs/interfaces.md、docs/progress.md、docs/qa.md、localization/en.po、scenes/doors/v4_door_catalog.gd、scenes/levels/floor.gd、scenes/ui/hud.gd、scenes/ui/interaction_progress.gd。保留双方历史和独立翻译条目，逐段整合，不整份覆盖。

- 2F沿用本次用户确认的完整预警、接取后留场、交付后退场；不改回旧的执行期间关门规则。
- 3F保留302强制通路与独立登记；403／501按后续任务编号调度，不依赖已经前移的FIRST表。3F以上普通门违规保留C的新本层左楼梯退回。
- 保留D新HUD、工具栏、309重逢CG／跟随和C五楼正式分层美术。I和工具栏背包共用205核验限制，防止新入口绕过规则。
- 504／505从实际目录和随机池一并移除，305仍保留不用；当前公共房门总数17。不存在隐藏的504／505检测。
- 补齐新HUD计时／下一目标及309提示的必要英文；新五怪剧情的完整英文仍未交付。字体661→664，只补“帕希防”，保留旧661字宽度及Hotel Staff CJK命名，OFL不变。

## 自动验证

[49项最新结果矩阵](matrix.json)：49/49通过，包含原42项与floor_flow、2F／5F布局、v4_doors、v4_identity、309重逢、任务门生命周期。矩阵按同名检查的最近运行合成；不是声称初跑全部通过。原始初跑结果、stdout／stderr在[initial](initial/)，失败项复查在[recheck](recheck/)，202最后复查见[task02_recheck.log](task02_recheck.log)。初次超时只有结果索引，未完整保存其进程stdout；异常原因由运行日志定位后修复。

测试迁移保持原有效断言：HUD结构使用唯一节点名；界面／组件检查加--ui-smoke跳过不相关菜单动画；完整五怪主流程真实等待动画可交互后开始。普通门期望更新为新左楼梯退回，302接受前不能假定可穿过303／304；其专门验证保留。UI完成状态夹具同时准备完成记录；309／旧普通门回归显式用API补二楼新前置，不作为完整教学证据。

## 原生Compatibility主场景

- [五怪主流程](native_five_monster.stdout.log)：正常菜单到201—205实际偷证、I/Q装备、真实工作、E交付及3F，退出0。截图为实际main而非对白预览。
- [309重逢](native_reunion_309.stdout.log)：二楼前置为明确API夹具，实际3F入口验证权限、36拍CG、输入、取消、救援结算、跟随、下层封锁与重开清理，退出0。
- [HUD最终复查](native_hud_recheck.log)：1280／1920／960宽度、状态／时钟／长文案、背包／暂停／对白，退出0。保留[native初跑索引](native_initial_results.json)，其HUD旧接取夹具失败未掩盖；修正为明确offer夹具后通过。
- 实际截图位于[screenshots](screenshots/)，[截图哈希](screenshots_sha256.json)。已查看203怪物对白、205批准台及309同行画面。

测试使用独立user目录ae4pa-merge-check-20261121，项目配置已恢复生产原文且不提交测试路径。[生产源码哈希](production_source_sha256.json)与[补字说明](font_extension.json)保留。原49项矩阵中的通过结果按影响复用；目录／UI／字体失败逐项复查，最终原生再次走五怪与309；未将字体命名元数据整理冒充额外整套回归。

## 范围与发布

没有VERSION、GitHub Actions或在线部署配置；不新增发布框架，不导出安装包。GitHub连接器在准备合并时返回token_expired；Git传输仍有效，若API未恢复则使用普通Git合并／非强制推送，保留服务器分支保护。

原工作区的project.godot本机差异及93个未跟踪文件保留，不混入提交。真人新教学、实际长时限、Windows、完整英文、04／05与最终逃脱仍待后续；本轮原生309属于自动化夹具，不代记真人验收。任务差异化仍是建议，未借合并改玩法。

入库日志仅规范化文件末尾空行以通过Git空白检查；完整原始副本保留在本机临时证据目录，运行内容和失败消息不改。
