# A交互／新手引导验证（2026-11-21）

Godot `4.7.2.stable.official.ed1daf0bf`，本机macOS／Compatibility，入口`scenes/main.tscn`。本轮在保留既有未提交功能的个人分支上增量实施，HEAD仍为`bb71226`，不是已发布版本。

## 自动检查

[最新矩阵](matrix.json)以原54项检查加`interaction_onboarding_smoke`组成55项。覆盖正常新局201—205、302批准、309真实CG、403／501、EXIT、检查点重试、卡／工作／门检测、基础移动、布局、本轮教学及角色姓名。完整主线仍使用原测试显式时钟推进，不能当作真人经历完整180秒／240秒的验收。

[初跑](matrix_initial.json)为53／55：202回归仍期待说明楼梯退回；中文UI预览检查受保存的英文语言影响。[第一轮复查](recheck.json)为54／55，确认202检查本身也没有明确中文语言前置，英文提示被它当作失败。最终两份只检查中文文本的测试明确自己的语言夹具，保留所有原断言；产品违规说明保留楼梯结果并补实际原因。最终四项复查见[复查结果](recheck_final.json)与`recheck_final/`日志，原始失败记录不删除。

实际命令逐项保存在JSON中，使用本机Godot二进制：

```sh
/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://scenes/tests/core/interaction_onboarding_smoke.gd -- --ui-smoke
/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://scenes/tests/core/interaction_onboarding_smoke.gd -- --ui-smoke --capture
/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://scenes/tests/core/interaction_onboarding_smoke.gd -- --ui-smoke --capture --english --small
```

## 专项先红后绿

`development/`保留失败基线、编译错误、真实输入夹具诊断与修正日志：

- `red2`确认范围／背后标记／胸牌／主场景渐进教学／拖放／后三怪笔记／302简化缺失。
- 评审发现提前装备后不提示第三卡，`review-red2`复现；改为跟踪新获得且未装备的具体卡，而非全局“已装备过”。
- `edge-red`复现当前槽移空缺Q提示、离门后怪物复习仍跟随；相应边界检查转绿。
- `visible-notice-red`证明HUD截断隐藏了原因；调整新反馈格式后，直接断言实际可见HUD保留原因。
- 原生输入最初混用了屏幕与viewport坐标，不能以那些失败画面算通过。最终通过Godot viewport本地GUI鼠标按下、移动、释放，实际拖动、命中、改变CardManager槽位，验证结束后拖放预览解除。headless仅验证状态与转发资格，不代替原生鼠标检查。

## 实际原生画面

最终图在` screenshots/cn1280/ `和` screenshots/en960/ `：楼梯范围、员工背后标记、首卡身份、收藏／拖动／装备结果、实际普通门怪物复习、302短对白、309分阶段指引、普通门违规后退回。`screenshots/initial/`保留较早输入诊断画面，不是最终结果。

已检查中英文上述两种尺寸，复用现有D控件／C怪物图，没有对白预览替代主场景。脚本中显式使用任务历史、位置、员工朝向和门相位夹具；302批准与普通门退回调用真实生产组件。

[字体报告](font_extension.json)：以原OFL同源字体补9字，664→673个映射，保留旧字宽和Hotel Staff CJK命名。相关脚本中文字符覆盖另核对。当前英文只承诺本轮相关显示，不代签全部剧情与全队英文内容。

## 保留与边界

测试使用独立用户目录`ae4pa-onboarding-check-20261121`，结束后原`project.godot`逐字节恢复。最终[源码指纹](source_sha256.json)和[画面指纹](screenshots_sha256.json)供复查。无提交、推送或合main；未运行Windows、导出安装包或代填真人表。

下次从正常新局人工观察引导是否足够明显，尤其首次员工转身、Q切身份和第三卡拖换；机制改版另行讨论。
