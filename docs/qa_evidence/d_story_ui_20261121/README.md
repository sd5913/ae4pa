# D：剧情界面与运行版本修正（2026-11-21）

## 根因和运行入口

原目录 `ae4pa-monster-dialogue-current` 在 `e9e4536`，旧菜单只有按钮事件；新版动效在已合并的 main。Fetch 成功后，本目录建立 `work/member-D-story-ui-v3`，安全 fast-forward 到 `bb71226799b8f0d81a45f073e306623e3869b857`。未复制其他旧工作区，未重做封面。原本机 project.godot 差异和无关未跟踪文件保留，不纳入提交。

实际入口为 `C:/Users/lenovo/Documents/ChatGPT/hotel/ae4pa-monster-dialogue-current/scenes/main.tscn`，Godot `4.7.2.stable.official.ed1daf0bf`，Windows / NVIDIA Compatibility。正常启动不带 `--ui-smoke`。

## 本次范围

- 手机可见高度约600逻辑像素，正文18、标题21，气泡按可用屏幕宽度计算，保留头像、历史和自动滚动。
- 删除对白的 ContinueButton 节点、连接、焦点和脚本依赖；怪物现场对白亦移除独立按钮；309仅保留拍数，无“继续”提示。
- SMS只认聊天区点击释放；人物对白只认框及立绘合理重叠区；旁白可点空白；309只认底部对白板。拖动、滚轮、按键回显、触摸重复鼠标、转场输入不连跳。
- 半身图按透明边界裁切显示并等比底对齐；姓名框距人物约20px；跳过在右下24px，正文避开跳过区域。309完整CG不裁切。
- 键盘沿用 interact 中配置的键；兼容旧配置指定键盘device ID的情况，不改变项目输入映射。
- 不改任务、卡权限、五怪教学、309 JSON/36拍内容、结算或跟随逻辑。

## 实际证据和限制

[封面5秒录屏GIF](cover-intro.gif) 来自正常正式主场景的 Godot MovieWriter，150帧/30FPS，无跳动画参数；GIF为每3帧取1帧、缩至640×360。原始AVI与录制日志在项目外 `../story-ui-validation/`。这不是独立菜单重建。

[手机](phone.png)、[1280对白](dialogue-1280.png)、[1920对白](dialogue-1920.png)、[960对白](dialogue-960.png)、[经理](manager.png)、[旁白](narration.png)、[封面](menu.png) 均来自真实 main 实例的 Compatibility图形运行及实际渲染帧；自动驱动剧情，不代记人工新局通关。三种窗口尺寸的对白边界、立绘底边、跳过24px与文本容纳断言通过。

Windows前台实际点击核验：新版居中封面；开始进入手机震动；点击房间背景无推进；聊天区点击只新增一条；拖动不新增消息。桌面键盘注入未能可靠观察到E推进，因此人工键盘/长按仍待复核；物理E、回显、单拍和释放隔离由自动输入用例验证。语言切换的人工操作、本轮真人从新局完整309通关、真实触屏硬件及所有表情/语言/窗口组合未逐项人工验证。

## 回归

命令均使用上述实际Godot可执行文件，`--headless --path . --script res://… -- --ui-smoke`，场景测试用对应tscn代替script。ui-smoke仅用于自动回归；图形截图、录屏和前台启动不带它。隔离APPDATA/LOCALAPPDATA在项目外 `../story-ui-validation/`；序章用独立临时配置，仅移除本次创建文件，用户正式已读状态未清理。

- `core/intro_flow_smoke.gd`：退出0，真实序章/经理/模态隔离/无卡门槛/新局清理通过。
- `ui/ui_test.tscn`：退出0，现有任务面板、HUD、失败、通关及模态请求覆盖通过。
- `ui/intro_preview.tscn`：退出0，首次锁定、短信、逐拍、两个完成ID、已读保存和重播跳过通过。首次补跑因旧测试在布局前点击失败，补容器布局等待后通过，断言保留。
- `ui/story_surface_smoke.gd`：无窗口和Compatibility图形均退出0，点击范围、拖动/滚轮、触摸去重、物理E/回显、三尺寸、首次/已读及菜单返回通过。
- `ui/english_layout_smoke.gd`：退出0，中英正文与面板边界、无隐藏继续控件覆盖通过。
- `ui/monster_dialogue_smoke.gd`：退出0，现场对白单次完成、任务/模态交接、真实工作后交付覆盖保留。
- `ui/reunion_309_smoke.gd`：退出0，CLEANER及登记前置、36拍、点击/E、取消不救援、结束后单次结算/跟随/4F及重访通过。前置由公开API准备，不代记人工全流程。

完整日志保存在本目录同名log；Windows根证书读取错误仍出现，未阻断检查。git diff --check通过。早期调试日志保留在项目外，没有把首次失败伪记通过。
