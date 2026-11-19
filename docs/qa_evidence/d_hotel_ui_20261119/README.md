# 黄铜旅馆 UI 审查证据（2026-11-19）

Windows，Godot 4.7.2.stable.official.ed1daf0bf，Compatibility。
补丁最初应用于 98e8130，本轮已接到最新 main 2538f11；只在进度文档合并双方追加记录，保留 main 的任务、门和管理器实现。

## 画面来源

本轮在正式 scenes/main.tscn 中使用真实渲染器截图，非设计稿。此前在本机从编辑器按 F5 目视确认雨夜菜单及中英标题，本轮重新渲染确认最终分支。
带画面脚本记录手机角度随时间变化，随后归零、显示聊天；两种头像均出现，新增短信后滚动位置为 513。
本轮不将脚本驱动画面核验说成全流程人工试玩。

| 画面 | 证据 |
|---|---|
| 雨夜封面和中英标题 | [menu.png](menu.png) |
| 手机通知震动阶段 | [phone-vibration.png](phone-vibration.png) |
| 双方头像和短信滚动 | [phone-chat.png](phone-chat.png) |
| 三收藏位、两装备位 | [bag.png](bag.png) |
| 正式主场景 HUD 生效槽高亮 | [hud.png](hud.png) |

**背包和 HUD 截图中的三张卡由仓库外验证脚本通过 CardManager.collect_card()/equip_card() 准备，是测试夹具，不是正式剧情取得记录。夹具脚本、进度配置、缓存和临时文件均未提交，不改变正式游戏发卡逻辑。**

## 本轮运行结果

- 资源导入退出 0。
- [intro_flow.log](intro_flow.log)：退出 0，真实序章、经理对白、输入隔离、无卡上楼和新局清理通过。
- [foundation.log](foundation.log)：退出 0，底座通过。
- [ui.log](ui.log)：退出 0，独立 UI 通过。
- [rendered.log](rendered.log)：退出 0，手机震动至摆正、双方头像、短信滚动、三收藏两装备以及 HUD 生效槽通过。
- [task_ui.log](task_ui.log)：退出 1，仅报 Ordinary warning returns safely without opening task failure UI。保留原测试及断言，未改为 PASS。
- 最新 main 的 managed_cycle 怪物门通过 request_monster_encounter 发出首次相遇事件；旧 task_ui 第 212 行仍期待 202 直接安全退回。该对接点待 A 复核，本 PR 不修改管理器或 C 的门规则。
- 本机 Windows 根证书读取诊断出现在日志中，单独列明；上述通过项未受阻。

无窗口开场和任务 UI 使用仓库既有脚本，Windows 临时配置路径只在仓库外的脚本副本中调整，用户存档保留。图形验证脚本也留在仓库外。


干净的 main 2538f11 对照实跑：[main-task-ui.log](main-task-ui.log) 同样退出 1，报告完全相同的普通门退回断言。它没有应用 UI 补丁。
当前分支的 [encounter_flow.log](encounter_flow.log) 退出 0，最新强制相遇流程通过。
本轮 git diff --check 通过。
