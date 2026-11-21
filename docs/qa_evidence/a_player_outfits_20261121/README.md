# A三身份外观验证（2026-11-21）

Godot4.7.2标准版，macOS／Compatibility。已批准保洁头巾、保安帽和经理仅换上衣，原人物PNG／动作图集未改。与上次引导不同，本轮移除了旧胸前证件图标。

## 检查入口

```sh
/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot --headless --path . --script res://scenes/tests/core/player_identity_outfit_smoke.gd
/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://scenes/tests/core/player_identity_outfit_smoke.gd
/Users/xiaxiabao/Downloads/Godot.app/Contents/MacOS/Godot --path . --script res://scenes/tests/core/player_outfit_main_smoke.gd -- --capture
```

首条只检查状态／姿势／镜像。第二条使用GPU实际渲染，不以headless或概念预览代替视觉检查。第三条在正式主场景输入Q、移动、使用D原装备按钮、恢复卡快照和重新开局。

## 原生逐像素与画面

`renders/gallery.png`是原生绘制出的原样／三身份×站立／六行走／清理共32格，不是imagegen人物预览。逐帧核对：

- NONE与未挂换装材质的原绘制全图像素一致；原裤子、靴子全部相同。
- 经理保留原头发／脸与红挎包色块，上衣实际变色，米白领口可见，弯腰衣角无旧黄色残留。
- 半透明与染色仍保持原绘制行为；头饰继承Visual左右镜像和实际动作。
- 清理姿势对全部身份做防御性绘制检查，不意味着保安／经理可以绕过工作资格清理。

主场景图在`main/`，包含保洁站立／向左行走、保安向右行走、经理上衣以及切回保洁还原黄外套。其取证与位置为显式QA夹具；实际Q／装备／快照／新局调用原组件。

## 回归与失败保留

[矩阵](matrix.json)由上轮55项加两份外观专项组成57项，逐项命令与结果在JSON及`regression/`。包括foundation、员工与工作、二楼五怪、三楼登记、309、403／501／EXIT、重试、原新手引导与姓名；完整主线使用显式时间推进，不当作真人实际长倒计时通关。

`development/`保留原始RED与后续检查：

- 初始RED确认旧卡牌仍在、缺少三种外观。
- 首次编译暴露新素材导入时序和绘制API名称错误，修正并重新导入；不计通过。
- 原生细节RED发现走路一帧领口不足，改用实际头部定位；另单测清理姿势小衣角，精确补原上衣片段且不改拖把／裤靴。
- 卡变更即时RED确认曾延后一帧，接cards_changed后同事件更新，含不发identity_changed的快照恢复。
- 只读评审无重要问题，指出材质透明度／染色兼容细节；加原生失败例后保留原调制输入与默认光照，再检查通过。

`asset_sources_sha256.json`记录原人物图与新素材指纹，[生成来源与完整提示词](../../../art_sources/player_identity_outfits/README.md)记录内置imagegen及批准边界。最终源码／截图指纹另存，测试用户目录配置在收尾逐字节恢复；未提交或推送。

本轮未测试Windows、导出包、真人观感或实际180／240秒平衡；没有代填验收表。
