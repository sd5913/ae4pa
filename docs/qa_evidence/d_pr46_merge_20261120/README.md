# PR46 与最新 main 整合证据

基线：PR51 合并后 main 78ce578；原PR46 c202ff8。用户授权本轮推送并合入main。

Windows / Godot 4.7.2.stable.official.ed1daf0bf，Compatibility。独立 APPDATA／LOCALAPPDATA；未改用户存档。

- 导入退出0；外部原始日志：ae4pa-pr46-validation/import.log。
- [图形菜单与工具栏检查](review.log)：退出0。真实开场Tween、禁用和恢复、菜单重播、原序章入口、背包／笔记／暂停。
- [图形HUD多尺寸](hud_layout_smoke.log)：退出0，使用 --ui-smoke 只跳过菜单开场等待，原HUD断言不改。
- [无窗口309](reunion_309_smoke.log)：退出0；原前置夹具、真实309 E／36拍／取消／结算／同行／换层／新局断言保留。
- [UI回归](ui.log)：退出0。
- [菜单截图](menu.png)／[HUD和工具栏截图](hud.png)：本轮真实图形运行，已查看；非人工从新局完整通关。

冲突：进度记录保留两侧；HUD以PR51新版为底，增加46工具栏，不回滚新版显示。交互进度保留InteractionArea。原46整体旧HUD已被用户后续新版取代，保留其有效按钮／正式素材与菜单反馈，不能复原旧重复文字和错误完成倒计时。A/B/C管理器、关卡、员工、怪物规则、309 CG与跟随实现均和78ce578一致。

第一次将依赖frame_post_draw的HUD检查用headless运行，等待未完成，已中断；改为图形模式通过。此中断不是通过或游戏失败。旧task_ui在caf862d的普通门退回失败仍在原46历史记录中，本轮未重新运行该全量检查，不把其历史结果改成通过。

回归使用原测试脚本，序章／卡片／位置的既有夹具边界同原记录。外部图形菜单脚本只为等待真实菜单动画和检查工具栏；日志副本仅整理末尾空行。git diff --check通过。
