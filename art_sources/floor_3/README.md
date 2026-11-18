# 三楼分区美术源文件

`floor_3_layers.ora` 是可编辑 OpenRaster 源文件，Krita/GIMP 可打开。
画布 7680×940，按原图走廊布局的2倍坐标组装，生成细节按本机原生像素或缩小使用；没有把原3840整楼图放大充当成品。
4个图层组，组内每件家具、建筑部件和光效均为独立可移动图层。`generated/` 保留内置 image_gen 生成的完整原生画布；`prompts.json` 保留提示词；原图裁条仅供布局参考。
游戏PNG在 `../../assets/final/floor_3_layers/`，layout.json记录坐标与参考区域，validation.json记录Alpha与源文件核对。
人物已去除；门及门上壁灯不制作、不混入背景。门位暂为连续墙面，后续独立门资产叠加。
画像和圆形徽章中的装饰人物剪影属于静态装饰，保留。
左右楼梯为整张透明PNG，栏杆并入楼梯，完整柱帽与底座包含其中。
透明对象使用真实RGBA Alpha，没有绘制棋盘格。光晕与阴影独立输出；ORA与PNG预览使用正常Alpha混合，layout.json另提供screen/multiply建议。
只交付美术；未替换游戏场景、角色或交互，未合入main。

最终版本含24个独立生成部件、35个定位图层和29张游戏PNG。左端外侧黑柱已补齐，3F牌位于柱前；柱子也是独立透明PNG。参考裁块在reference_crops/，提示词使用相对路径。
