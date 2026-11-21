# Carol三身份外观接入

2026-11-21用户批准三种形象后实施：**保洁头巾、保安帽、经理仅换西装上衣**。本地个人A分支，未提交、推送或合入main。

## 实际表现

| 当前生效身份 | 实际外观 |
| --- | --- |
| 未装备／空槽 | 原黄外套，无头饰 |
| CLEANER | 原衣着＋米白紫边、后结头巾 |
| SECURITY | 原衣着＋紫金保安帽 |
| MANAGER | 深青西装上衣与米白领口；原棕裤、靴子、红挎包不换 |

旧胸前工作证图标组件已移除，经理不再用放大的证件卡表示。外观只读CardManager.active_card；持有／收藏／另一个槽不能叠穿。实际Q、背包装备、快照恢复和新局同步。卡变更在同一cards_changed事件更新；每帧只跟进原动画位置，卡片／任务真值、碰撞、步速和工作规则不改。

## 文件与实现

- `scenes/player/player_identity_outfit.gd`：Player的`Visual/Artwork/IdentityOutfit`子节点，继承同一左右镜像与父级移动。头饰位置取原静态／行走／清理的头部几何。
- `scenes/player/manager_jacket.gdshader`：原上衣色块与领口局部处理。原人物PNG和动作图集不覆盖；头、裤靴、红包、动作枢轴保留。材质保留原透明度／着色输入及默认光照。
- `scenes/character_visual.gd`：将原绘制选择提为只读`get_render_pose()`，原分支／坐标算法不变。普通员工不挂换装组件或材质。
- `assets/final/player/identity_outfits/`：两件正式透明头饰PNG及导入描述；内置imagegen来源、已批准预览与完整提示词见[素材记录](../art_sources/player_identity_outfits/README.md)。

生成的预览不是新人物图集：正式游戏复用原Carol动作，头饰叠加，上衣局部处理，避免重新生成脸和下半身。

## 验证

`player_identity_outfit_smoke.gd`覆盖真实CardManager／Player、唯一外观、无身份、Q、仅收藏、直接快照恢复、同事件同步、重开、左右镜像、六帧行走与清理姿势。原引导测试保留身份断言，仅把旧Badge定位改为实际新组件。

原生Compatibility对站立、六帧行走、清理共8种姿势逐像素比较：空身份与原默认绘制一致；三身份的原裤靴不变；经理头发／脸和红色挎包色块不变，上衣确实变化且领口可见；清理姿势不残留黄色衣角。半透明／染色先红后绿验证。

`player_outfit_main_smoke.gd`从正常菜单进入真实主场景，通过Q、D原装备按钮、移动、快照回调和重新开局检查换装；原生截图在[证据目录](qa_evidence/a_player_outfits_20261121/README.md)。取证／位置有明确夹具；这不代替真人验收。另回归基础、员工、201—205、309、403／501／EXIT、检查点与原引导。

## 下一步

双击根目录`play.command`或Godot F5，正常新局；优先人工看三种身份行走、转向和清理是否自然。美术若更新原人物图集，须同步新外观的头部／上衣几何并重新跑原生逐像素检查。Windows、真人易用性与实际长倒计时平衡仍未代签。
