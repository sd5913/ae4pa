# 403／501／EXIT 验证证据

2026-11-21，main@bb71226上的A本地后段整合。未提交／推送。功能范围见[交接](../../late_mainline_handoff_20261121.md)。

## 最终结果

- [最新矩阵](matrix.json)：51/51，原49项＋新任务核心／正式后段主场景。按影响复用不受最后显示修复影响的通过项，受影响10项以[复查矩阵](matrix_recheck.json)为准。
- [正常新局整链](full_escape_final.log)：PASS，正常菜单、真实201—205、302、36拍309 CG、403、501、实际EXIT成功页；无前序完成／救援API夹具。后段普通门调度保持运行。
- [原生Compatibility最终检查](native_final.log)：PASS，真实窗口及实际E／I／Q／工作组件、重试、成功页、新局对白重播和返回菜单。
- [生产源文件指纹](source_sha256.json)及[截图指纹](screenshots_sha256.json)。查看了[巡房成果](screenshots/patrol_ready.png)、[501批准后](screenshots/exit_approved.png)、[成功页](screenshots/escaped.png)。

全部运行使用本机Godot4.7.2，实际命令在各矩阵的command字段。正式源码在独立A工作区验证后按哈希同步回常用本地项目；用户原project.godot差异保留。测试专用用户目录`ae4pa-late-check-20261121`配置已恢复，不混入产品配置。

## 失败、修复和复查

- [核心RED](core_red.log) → [GREEN](core_green.log)：原HAS_FRIEND前置失效、空卡要求、未启用后段及缺EXIT API。
- [场景RED](main_red.log)和[中间检查](main_mid.log)：缺正式组件／安全点／对白接取。
- [重复提醒RED](reminder_red.log) → [主场景GREEN](main_green.log)：接取后自动重复进度对白阻塞工作，改自动通知、主动E对白。
- [独立评审RED](review_red.log) → [GREEN](review_green.log)：新局对白缓存未清理、成功返回菜单残留同行、救援目标不一致，均已修复。
- [实际画面提示RED](notice_red.log)、[层级RED](visual_red.log) → [原生最终GREEN](native_final.log)：新增员工／工作点被布景盖住，批准后残留错误身份旧提示，均已修复。
- [初跑矩阵](matrix_initial.json)：只记录完成的50项，5项失败；其最后一个主场景因测试按钮名写错而中断，错误保留在`regression/late_mainline_main_flow_smoke.godot.log`，不是51项全部完成。
- [整套复跑矩阵](matrix_final.json)：49/51，剩余为新增目标文字缺字及旧身份提示；最终10项复查全部通过，构成最新51项矩阵。不要把此文件名里的final当作全绿结论。
- 旧安全退回、美术遍历、换层检查显式准备“后段已解锁”的测试状态；没有移除原本有效的移动、退回、资源、普通规则断言。新任务路障和未交付拒绝由新主场景用例验证。

最初沙箱运行有大量FreeType系统字体错误；正常Godot权限下未复现，无需修改字体二进制。大日志只压缩重复错误，完整本机副本在`/private/tmp/ae4pa-late-original-logs-20261121`；压缩文件仍保留所有FAIL／PASS／TRACE和各类错误计数。

## 验证边界

位置、朝向和任务时钟是明确的测试控制。独立后段检查用前序事实夹具，整链检查真实完成八项任务与309 CG。超时是推进真实任务时钟，不是实际等待180秒。自动化不代记真人完整通关、Windows、完整英文或时限平衡。

近距离巡房奖励提示与角色标签仍有重叠，留D后续排版；外景结尾CG、最终剧情润色与统计未在本轮完成。


同步后验证边界：18个源码／场景／检查文件均与已验证隔离工作区哈希一致，原project.godot校验值不变。常用项目的一次额外核心复跑未执行：自动审批因使用额度达到上限而无法完成审查（非安全判定），未改用其他路径绕过；隔离区51项、正常整链和原生检查的实际通过记录保留。
