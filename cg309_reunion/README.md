# 309 重逢 CG v2 接入

原包：用户本机 `Downloads/Room309_Reunion_Pack`。三张图均为用户提供的 AI 生成／定向编辑正式图，顺直内扣短发成年安与帕希卡（Persica）；见 source_notes.txt。未使用旧版外翘短发 CG，未复制 MP4 或项目配置。

dialogue.json 为原包完整 36 拍，SHA256 为 `94ED00948D743FB1C760FA9304937E172BE5C5437CD39B2DDDE2457397215227`，未重写台词。story_cn.txt 保存原文。仅使用三张关键帧叠化与轻推，不是逐帧或骨骼动画；无正式声音资源，本轮静音。

- 独立预览：打开 reunion_cg.tscn 按 F6；本次实际使用命令行图形运行同一场景，未代称编辑器按键验证。
- 正式主线：floor.gd 真实 309 E 路由校验已完成 TASK_03_AUTHORIZE、registration_309_approved、当前 active_card=CLEANER 后发 rescue_open_requested；经理仍负责原登记授权。
- 主场景 Room309Reunion 控制器加载本场景到独立 CanvasLayer，登记 ROOM309_REUNION 模态，隐藏旧 HUD 等层。读卡确认后开始播放，首次无跳过。输入读取 interact，一次推进一拍，回显／转场额外输入不跳句。
- 只有 rescue_cg_finished 后调用原 GameManager.rescue_friend()，成功才写救援事实、生成帕希卡并依原条件开放4F。cancel()、新局、菜单、失败和换层清理演出与自身模态，不伪造救援。
- 本组件不调用 GameManager。独立预览不能解锁或生成跟随者；游戏状态在宿主负责。
- 旧 dialogue.gd 的 RESCUE_309 两句兼容预览仍保留，正式309已走本36拍CG，不切回旧卧室／前台。
- 后续04／05任务及最终EXIT依旧由团队原规则控制；本轮没有绕过它们直开5F。

跟随素材复用用户先前选定的 `Hotel_Intro_Selected_Assets/image(20261112-083753).png`，复制至 assets/final/characters/persica/q_views.png，以正面站姿平移随行，不声称新增行走逐帧动画。内部 friend／has_friend／旧素材路径未重命名。
