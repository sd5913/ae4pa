# D UI Refresh v2：Windows 验证（2026-11-19）

## 交付范围与来源

- 从项目根目录 Hotel_UI_Refresh_v2.zip 解压到项目外的 hotel-ui-refresh-v2-source。
- 包内实际有 assets（PNG 与 .import）、hotel_ui_refresh.patch、使用说明.txt、cover_intro.mp4。已查看按钮与工具条图片，并选择性复用其代码与素材；没有整包覆盖项目。
- 包内 MP4 和原验证文档来自 Linux/Godot 4.6.3，**不作为本轮 Windows 通过证据**。
- 原 D、旧冲突 worktree、角色整合工作区均保留。本轮目录 ae4pa-ui-refresh-v2、分支 work/member-D-ui-refresh-v2。
- 初始 main 为 8e64221，发布前整合 caf862d（含英文切换和长鼻客更新），保留 main 的语言选择、格式化通知和全部玩法。
- 主场景仅做 HUD 信号、提示显示、按钮反馈等 UI 接线，未更改管理器、发卡、怪物或存档结构。

## 本轮实现

居中容器排列标题与按钮，雨夜／闪电／两次短黑屏／标题上升渐显／按钮依次入场；期间真实禁用鼠标和焦点输入，并保护重复开始。返回菜单重播并恢复焦点。
统一正式按钮状态与绝对缩放反馈，旧 Tween 被取消，不积累位置或大小。
正式主场景实例化新版 HUD，工具栏接背包、渐进笔记、暂停；保留真实任务／卡片／组件进度，暂停继续与返回菜单使用既有 A 状态接口。
原手机剧情、头像、短信滚动、三收藏两佩戴保留。英文菜单和暂停语言入口继续存在。

## 实测环境与证据边界

实际引擎：C:/Users/lenovo/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe；
版本 4.7.2.stable.official.ed1daf0bf，Windows，NVIDIA Compatibility 渲染。

先从编辑器按 F5，在真实窗口观察居中封面，点击操作说明、关闭、开始，观察手机首条消息。
后续以同一正式 scenes/main.tscn 的图形运行检查完整 UI 路径、两种尺寸并抓取实际帧，不冒充全流程人工试玩。电脑工具期间出现应用程序错误弹窗并超时，未能完成全部原生鼠标走场；最终图形验证进程及日志退出 0。该限制保留，未代记全流程人工通过。

截图与 GIF 均为**最终整合版本在本机 Godot 4.7.2 的实际渲染**：
- [封面 1280×720](menu-1280x720.png)、[封面 960×540](menu-960x540.png)、[英文菜单](menu-english-960x540.png)
- [HUD 1280×720](hud-1280x720.png)、[HUD 960×540](hud-960x540.png)
- [真实空背包](bag-960x540.png)、[笔记](notebook-960x540.png)、[暂停](pause-960x540.png)、[手机](phone-960x540.png)
- [Windows 封面动画 GIF](cover_intro_windows.gif)：46 帧、640×360，来自本机连续真实渲染帧；包内原 MP4 未混用。

没有临时发卡。背包截图为空状态、HUD 未装备状态；未用夹具伪装正式获取卡片。

## 结果

| 项目 | 结果 |
|---|---|
| 整合后导入 | 退出 0，无脚本解析、丢失资源错误 |
| [图形验证](review.log) | 退出 0；动画误触保护、标题按钮不重叠、两尺寸居中、重复反馈无漂移、禁用恢复、Tab 焦点、菜单说明、手机剧情、运行时 HUD、空背包模态、笔记、暂停继续、返回重播及新局、语言选择通过 |
| [intro_flow](intro_flow.log) | 退出 0 |
| [foundation](foundation.log) | 退出 0 |
| [独立 UI](ui.log) | 退出 0 |
| [task_ui](task_ui.log) | 退出 1：Ordinary warning returns safely without opening task failure UI |
| [干净 main caf862d 对照](baseline-task_ui.log) | 同样退出 1、完全相同的普通门退回断言；不是本次新增 |
| git diff --check | 通过 |

既有测试在菜单刚创建时通过代码直接触发按钮，不会等待新增的真实入场动画。仓库外测试副本仅将 /private/tmp 配置路径换成可写临时目录，并在原有菜单操作前等待动画完成；**未删除、放宽或改写任何断言**。夹具、临时进度、用户设置、帧序列和脚本副本不提交。
独立 UI 使用既有 --ui-smoke；开场和基础使用等待动画的真实入口，无窗口结果不当作人工验收。

Windows 根证书读取诊断仍存在，单列为环境问题。普通门断言与新的强制相遇接线待 A 确认；没有改 A/C 规则来让它变绿。
