# D UI 修复 v4 · 2026-11-22

UI代码提交：`35b2400245cfb3bce6e4183dae7c71e9a76d3bcd`；最终快捷键代码／测试提交：`36a4a7742468e615c94f289dfaee7943873ae924`。基线为当时最新main `569b5d0941aaef73a327eaa19def1b0b95bcb798`，分支 `work/member-D-ui-polish-v4`。

实际运行目录：`C:\Users\lenovo\Documents\ChatGPT\hotel\ae4pa-d-delivery-closeout`。正式入口 `scenes/main.tscn`，Godot `4.7.2.stable.official.ed1daf0bf`，Windows 11／NVIDIA RTX3070 Laptop／Compatibility。自动化使用隔离临时用户配置，未覆盖玩家游玩存档。

## 素材核对与映射

已安全解压用户给出的微信目录ZIP到临时目录，检查条目没有越界路径。五张PNG的SHA256与最新main `assets/final/monster_dialogue_portraits_v1/` 完全相同，复用现有正式路径，没有重复存储。原始1024×1536 RGBA及AI来源记录保持不变，新增必要导入描述，不提交.godot缓存。

| 角色ID | 源图 | 固定裁切（x,y,w,h） |
|---|---|---|
| NOSE | nose_halfbody.png | 100,90,825,1374 |
| EYE | eye_halfbody.png | 20,120,984,1340 |
| HAT | hat_halfbody.png | 60,20,900,1490 |
| EAR | ear_halfbody.png | 35,260,954,1040 |
| CHECKER | checker_halfbody.png | 55,45,910,1455 |

`dialogue_roles.gd` 使用明确ID和本地化名称。立绘在原始透明图上用AtlasTexture裁切，不重编码、不拉伸。共用Portrait槽，按比例缩放并右对齐槽位，底部0.95与正文框一致；姓名牌和正文从同一左线开始，距人物槽约19逻辑像素。Carol、经理、员工与Terese每套表情先求整套共同轮廓区域，再固定裁切，避免按当前一句或表情重算尺度。

## 修复

- 全局按钮使用黄铜矢量边框与独立状态，去掉整张卷纹按钮的拉伸。中心文字、鼠标点击区和状态尺寸一致；OptionButton沿用同组状态。保留面板与卡牌正式美术。
- 短信每次原有推进仍只加一条消息；等待四帧容器布局稳定，再滚到最终底部。生成号淘汰旧滚动请求，没有叠加滚动Tween。原剧情最长现有消息未超过聊天区；没有删文字或为截图注入台词。
- HUD运行时原实例保留节点路径和信号，右侧先放四入口，下方放楼层和两槽。楼层牌用KEEP_ASPECT_CENTERED背景，不再压缩整图。四个按钮短名补英文。A的task_hud继承该场景，未改A任务脚本。
- 笔记根控制与正文容器明确宽度，内容进入受限高度的滚动区；关闭／翻页控件固定在外。保留原笔记继承脚本的数据读取，关闭键／H只处理已有页面并释放原help模态。

## 实际运行截图

| 项目 | 中文1280×720 | 英文960×540 |
|---|---|---|
| 封面 | [cover](zh1280/cover.png) | [cover](en960/cover.png) |
| 完整最新短信 | [sms](zh1280/sms.png) | [sms](en960/sms.png) |
| Carol剧情 | [carol](zh1280/carol.png) | [carol](en960/carol.png) |
| Terese剧情 | [terese](zh1280/terese.png) | [terese](en960/terese.png) |
| 两行HUD | [hud](zh1280/hud.png) | [hud](en960/hud.png) |
| 笔记工作证页 | [card](zh1280/notebook_card.png) | [card](en960/notebook_card.png) |
| 翻页 | [next](zh1280/notebook_next.png) | [next](en960/notebook_next.png) |
| 未知住客页 | [unknown](zh1280/notebook_unknown.png) | [unknown](en960/notebook_unknown.png) |

五怪真实201—205任务入口截图（由既有正常新局五怪回归实际走偷取／工作／交付）：[NOSE](formal_tasks/201_intro.png)、[EYE](formal_tasks/202_intro.png)、[HAT](formal_tasks/203_intro.png)、[EAR](formal_tasks/204_intro.png)、[CHECKER](formal_tasks/205_intro.png)。

英文各怪物显示检查：[nose](en960/monster_nose.png)、[eye](en960/monster_eye.png)、[hat](en960/monster_hat.png)、[ear](en960/monster_ear.png)、[checker](en960/monster_checker.png)。这组是正式main场景内调用明确的对白review入口，没有执行对应任务；不能拿这组替代前面的真实任务接线证据。

1920×1080：[HUD](zh1920/hud.png)、[Carol](zh1920/carol.png)、[笔记](zh1920/notebook_card.png)。

历史对照：[201改前](../d_monster_surface_20261122/zh1280/201-introduction.png) → [改后](formal_tasks/201_intro.png)；[HUD改前](../d_delivery_closeout_20261122/screenshots/hud/after-none.png) → [改后](zh1280/hud.png)。历史图来自前一提交的实际捕获，场景状态／角色位置不完全相同，没有伪造同帧对照。

补充按钮显示检查：[背包](zh1280/bag.png)、[暂停](zh1280/pause.png)、[任务详情](zh1280/task_details.png)。成功／失败页的原请求信号由现有完整UI回归覆盖；本轮未人工触发完整结局。

## 短录屏

[story_ui_review.avi](../../../outputs/ui_polish_v4/story_ui_review.avi)：Godot Movie Maker捕获，20FPS／402帧，约20.1秒，包含正常封面入场、原短信逐拍推进、Carol／Terese表情布局和五怪review。来源是实际main场景的定向自动化，不是F6独立预览，也不是人工完整任务通关录像；review部分不代表此时1F能触发全部怪物任务。AVI较大，可下载本地播放。未新增音效或逐帧人物动画。

## 验证结果

- PASS／退出0：资源导入、既有help_refinement、story_surface、本地化、完整ui_test；最终本地化复测、monster_dialogue、HUD布局；真实five_monster_main_flow（201—205正常新局／偷证／工作／E交付／提醒／重试）。日志在logs/。
- PASS／退出0：新增ui_polish_v4_smoke中文、英文960×540、1920×1080；覆盖最新短信17拍完整底部、Carol／Terese表情框位置稳定、五怪同底基线／连续台词位置稳定、review不改任务结算、笔记连续10次开关和模态释放、按钮关闭、返回菜单后重新开始与再打开笔记。
- 最初英文边界断言把逻辑坐标与物理960窗口宽混比，产生10个失败；保留 `review_en_coordinate_mismatch.log`。改为同坐标系的完整Control边界包围检查，英文复跑退出0；没有去掉边界断言。
- 目视：已查看中文／英文截图中的五怪、Carol／Terese、短信、HUD、工作证页；英文正文和姓名牌无裁切，1280图无白底，耳朵／礼帽顶部保留。正常启动的真实窗口确认新封面，鼠标实际点击开始进入手机震动通知。未做八任务人工完整通关。

## 限制与交接

- 门OPEN原图烘焙的小怪剪影仍在世界背景中，D半身已使用新正式图；清除烘焙剪影需A/C与美术负责人提供无人物门图，本轮未改门规则／世界布局。
- 原图自身带轻微半透明暖色边缘，保持原alpha，未抠掉细节。美术负责人可复核此风格；没有宣称光边完全不存在。
- 302／403／501依旧走原公开对白映射，复用同一新人物查找；未为此重配任务或修改发卡。正式五怪测试不等于人工302／309／403／501／EXIT全流程。本轮未重跑先前已知失败的完整八任务逃脱和旧task_ui夹具；这些历史缺项保持原记录。
- 操作由现有映射与主场景接线管理。窗口注入H未观察到打开，补充按既有InputMap匹配物理／逻辑键后，真实InputEventKey的H打开、H／Esc关闭十次复测及help／ui_test回归均退出0（physical_keys.log、help_keys.log、ui_test_keys.log）。桌面注入H／E仍未观察到对应键盘响应，鼠标实际点击开始正常；键盘注入或输入法因素未定，真实硬件键盘人工复核仍待完成，未记人工PASS。
- 原有无关未跟踪文件未清理。只暂存本轮D代码、必要导入、证据和录屏。PR交A审查，不自动合并。