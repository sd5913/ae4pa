# Carol身份外观来源

用户已批准：保洁头巾、保安帽；经理只换深青西装上衣与米白内搭，原棕裤／靴子不动。`headwear_approved_preview.png`第三列早期胸牌方案已被`manager_upper_body_approved_preview.png`取代，不能再据旧第三列制作。

## 本轮素材与方法

内置imagegen依据已批准头饰概念生成两件独立透明素材，原始输出未做额外位图重绘，分别保存：

- `assets/final/player/identity_outfits/cleaner_headscarf.png`
- `assets/final/player/identity_outfits/security_cap.png`

正式运行保留原Carol静态／动作源图。头饰按原头部位置叠加并继承左右镜像；经理上衣用局部CanvasItem着色与原领口处理，保留原源像素几何。生成的经理预览不被当作新的整套人物图集。

## 生成提示词

**保洁头巾（内置imagegen，透明背景）：**

Generate ONE isolated game wearable asset on genuinely TRANSPARENT background. Reference image is approved design sheet. Extract/re-create ONLY the ivory/plum tied headscarf in the LEFT column, in the exact RIGHT-FACING SIDE PROFILE shape seen worn by Carol there. No heroine, head, hair, skin, body or other content. This must be a standalone fabric headscarf that can be layered onto existing short angular hair. Cream/ivory triangular cloth drapes over top and rear of head; plum narrow edge along opening; small plum tie knot and two short tails at the REAR LEFT. Opening/forehead end is on the RIGHT, slightly higher than rear to keep eye/face unobstructed. A gently sloping dome, not a tall bonnet, not a frontal symmetric hood. Use bold clean dark brown outlines and simple warm cel shading exactly like reference. Entire cloth and knot fully visible centered with a modest transparent margin, large on canvas. No labels, no border, no checkerboard pixels, no background glow, no shadow outside fabric, no extra objects. Single accessory only, no duplicate front views or alternate variations. Keep silhouette legible when reduced to about 85x58 pixels on a 190px tall game character.

**保安帽（内置imagegen，透明背景）：**

Generate ONE isolated game wearable asset on genuinely TRANSPARENT background. Reference image is approved design sheet. Extract/re-create ONLY the fitted violet/gold security cap in the MIDDLE column, in the exact RIGHT-FACING SIDE PROFILE angle seen worn by Carol. No heroine, head, hair, skin or body. A low structured purple hotel security cap, golden yellow narrow band at lower edge, single small gold hotel key/emblem on side near front, modest short brim pointing RIGHT and subtly down. Rear is on LEFT; low fitted shape, not a tall cylinder, not a crown or police helmet. Bold clean dark brown outlines, flat violet colors, angular plum highlights and gold details exactly like reference, legible at small sprite scale. Entire cap and short brim fully visible centered with modest transparent margins, large on canvas. No labels, no border, no checkerboard pixels, no background, glow, external shadow or other props. Single accessory only, no duplicates or front view. Designed to layer naturally on the crown of existing right-facing short hair, approximately 85px wide and 35px tall on a 190px character.
