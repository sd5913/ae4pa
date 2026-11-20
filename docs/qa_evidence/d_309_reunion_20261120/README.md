# 309 新版 CG 本轮证据

Windows／Godot 4.7.2.stable.official.ed1daf0bf，Compatibility。工作分支 work/member-D-monster-dialogue-current，HUD 的既有本地修改保留；未提交、推送或合并。

先核对 origin/main=a802721，仅已合入本轮先前的 PR48，没有额外309实现；本地309只有接入占位与受保护的 rescue_friend()，没有跟随者，故原测试中帕希卡不会出现。

## 实际运行

| 本次运行 | 结果 | 日志 |
|---|---|---|
| 图形模式真实 main，309正式E和36拍、取消、结算、跟随、重复交互、新局与换层 | 退出0 | [main.log](main.log) |
| 独立 reunion_cg.tscn 图形场景启动（F6同一入口） | 退出0 | [standalone.log](standalone.log) |
| 原任务03核心权限／结算 | 退出0 | [task03.log](task03.log) |
| 原序章／经理真实输入回归 | 退出0 | [intro.log](intro.log) |
| 现有 UI 回归 | 退出0 | [ui.log](ui.log) |

命令：godot --path . --script res://scenes/tests/ui/reunion_309_smoke.gd；环境变量 AE4PA_309_EVIDENCE 指定截图输出。独立预览用 --scene res://cg309_reunion/reunion_cg.tscn --quit-after 120。其余脚本 --headless 运行。序章脚本的外部副本仅替换 Mac 临时路径为本机隔离目录，断言不改。全部用户配置使用独立 APPDATA／LOCALAPPDATA，没有改玩家已有进度。

初次新测试未给物理E回显事件发送释放，取消后测试取到空CG引用并报错，见 [attempt1.log](attempt1.log)；补上真实键释放及重开检查后最终 main.log 完整通过。Windows 根证书读取错误仍出现，没有阻断测试。旧失败不当作通过。

主线场景里的任务01／02／03前置通过真实公开 API 准备，卡片、位置和前置工作报告明确作为测试夹具；不是从新局人工走完三层偷证任务。309实际选择路由、输入事件、权限拒绝、CG与原救援结算接口、跟随移动、返回菜单／新局和3F→4F均在真实main运行。并非只在独立预览页验证，也不代记完整五任务通关。

## 已验证

- 未获登记批准拒绝；当前经理即使拥有保洁卡也拒绝；当前保洁才触发CG。
- 36拍与原包一致，无跳过按钮；E／鼠标每次一拍，键回显和转场内输入不跨拍。
- CG隐藏HUD，持统一模态，尚未读完时has_friend=false、4F未开放。取消不发成功，能够重新开启。
- 全部读完只发一次完成，调用原rescue_friend()；帕希卡生成一次，实际移动跟随。重复309交谈不重播，不重复生成。换层仍同行；新局清空救援／跟随者。
- 960×540长句保持24逻辑字号并换行，已查看末行和按钮提示。既有HUD修改与新的救援目标共存。
- git diff --check通过。

## 图形截图

- [接近](approach.png) · [拥抱](hug.png) · [牵手](leave.png)
- [960×540长句](small-long-line.png)
- [真实309门前，结束后帕希卡同行](following.png)

截图为本轮实际Godot图形渲染并查看，非设计合成。没有增加开锁／衣料音效、手臂骨骼／嘴型／眼泪动画；帕希卡随行使用此前正式Q版静态正面图。完整04／05及EXIT仍待团队既有主线，不因本CG完成而直通。

## 修改范围

- cg309_reunion/：原JSON、三张新版图、演出脚本／场景、必要导入／UID和来源说明。
- scenes/room309_reunion.gd、persica_follower.gd：宿主接线和纯视觉跟随。
- scenes/main.gd、scenes/levels/floor.gd：309公开事件／校验及目标提示；GameManager和卡片权限实现未改。
- scenes/ui/dialogue.gd/.tscn、scenes/notebook.gd、localization/en.po：可见姓名帕希卡／Persica及旧立绘／短信角色别名兼容。
- scenes/ui/hud.gd：保留当前HUD改动，读取真实has_friend后显示五楼总目标。
- assets/final/characters/persica/q_views.png 与导入：复用已选Q版。
- scenes/tests/ui/reunion_309_smoke.gd、QA／进度及本证据目录。

提交收尾：最新 origin/main 为 a802721，201／202 怪物对白已由 PR48 合入，本轮不重复提交。本文件上方为验证时记录；本轮按新授权整理提交／推送并准备新的 main 审查 PR，未重跑已通过测试，实际提交和 PR 状态见对应 PR。
