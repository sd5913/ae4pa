extends SceneTree
## Real player + CardManager. Explicit animation phase fixtures; GPU checks require native mode.
var failures: Array[String] = []
var cards: Node
var game: Node
var player: Node2D
var artwork: Node2D
var outfit: Node
var viewport: SubViewport
func _initialize() -> void:
	create_timer(70).timeout.connect(func(): print("FAIL: identity outfit timeout");quit(1))
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(3): await process_frame
func identity(id: String) -> void:
	var second := "MANAGER" if id != "MANAGER" else "SECURITY"
	cards.restore_snapshot({"owned_cards":["CLEANER","SECURITY","MANAGER"],"equipped_cards":[id,second],"active_slot":0})
	if is_instance_valid(outfit): check(outfit.get_outfit_view()["card_id"]==id,"Card change updates visible costume in the same event: "+id)
	await settle()
func render() -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()
func same_region(a: Image, b: Image, region: Rect2i) -> bool:
	for y in range(region.position.y,region.end.y):
		for x in range(region.position.x,region.end.x):
			if a.get_pixel(x,y) != b.get_pixel(x,y): return false
	return true
func preserved_red(a: Image,b: Image) -> bool:
	for y in a.get_height():
		for x in a.get_width():
			var c:=a.get_pixel(x,y)
			if c.a>0.5 and c.r>0.35 and c.r>c.g*1.6 and c.g<c.b*1.4 and c!=b.get_pixel(x,y): return false
	return true
func ivory_changes(a: Image,b: Image) -> int:
	var count:=0
	for y in a.get_height():
		for x in a.get_width():
			var c:=b.get_pixel(x,y)
			if c.a>0.5 and c.r>0.75 and c.g>0.70 and c.b>0.60 and c!=a.get_pixel(x,y): count+=1
	return count
func finish() -> void:
	for message in failures: print("FAIL: ",message)
	if failures.is_empty(): print("PASS: player_identity_outfit_smoke")
	quit(0 if failures.is_empty() else 1)
func run() -> void:
	game=root.get_node("GameManager")
	cards=root.get_node("CardManager")
	game.set_floor_host(null)
	game.start_game()
	viewport=SubViewport.new()
	viewport.size=Vector2i(512,256)
	viewport.transparent_bg=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	player=load("res://scenes/player/player.tscn").instantiate()
	viewport.add_child(player)
	player.get_node("Camera2D").enabled=false
	player.position=Vector2(256,230)
	player.set_physics_process(false)
	artwork=player.get_node("Visual/Artwork")
	artwork.set_process(false)
	await settle()
	outfit=artwork.get_node_or_null("IdentityOutfit")
	check(not player.has_node("IdentityBadge"),"Old floating card is removed from the real player")
	check(outfit!=null and outfit.has_method("get_outfit_view"),"Actual player has the approved role-specific outfit component")
	if outfit==null:
		finish();return
	var before: Dictionary=cards.export_snapshot()
	check(outfit.get_outfit_view()["card_id"]=="NONE","No active identity has no outfit")
	check(cards.export_snapshot()==before,"Visual component cannot mutate card state")
	for role in ["CLEANER","SECURITY","MANAGER"]:
		await identity(role)
		var view: Dictionary=outfit.get_outfit_view()
		check(view["card_id"]==role,"Snapshot-only restore updates "+role)
		check(view["headwear"]=={"CLEANER":"headscarf","SECURITY":"cap","MANAGER":"NONE"}[role],"Correct single headwear for "+role)
		check(view["jacket"]==(role=="MANAGER"),"Only manager changes upper garment")
		for frame in range(6):
			artwork.set_walking(true)
			artwork.set("_phase",float(frame)/6+0.01)
			await settle()
			var pose: Dictionary=artwork.get_render_pose()
			check(outfit.get_outfit_view()["frame"]==frame and pose["frame"]==frame,"Outfit uses exact walking frame %s/%d"%[role,frame])
		for direction in [-1,1]:
			player.facing_direction=direction
			player.visual.scale.x=direction
			await settle()
			check(signf(outfit.global_transform.x.x)==direction,"Outfit shares actual Visual mirror for "+role)
		artwork.set_walking(false)
		artwork.set_cleaning_visual(true)
		await settle()
		check(outfit.get_outfit_view()["frame"]==8,"Cleaning uses actual bent-head frame for "+role)
		artwork.set_cleaning_visual(false)
	# Q uses actual B state; collecting an inactive third card must not layer its costume.
	await identity("CLEANER")
	cards.switch_active()
	await settle()
	check(outfit.get_outfit_view()["card_id"]=="MANAGER","Real Q signal follows the active slot")
	cards.restore_snapshot({"owned_cards":["CLEANER","SECURITY","MANAGER"],"equipped_cards":["NONE","SECURITY"],"active_slot":0})
	await settle()
	check(outfit.get_outfit_view()["headwear"]=="NONE" and not outfit.get_outfit_view()["jacket"],"Owned cards in inactive slots cannot dress an empty active slot")
	# Native offscreen renders compare actual pixels, not a generated concept image.
	if DisplayServer.get_name()!="headless":
		player.facing_direction=1
		player.visual.scale.x=1
		var path:="res://docs/qa_evidence/a_player_outfits_20261121/renders"
		DirAccess.make_dir_recursive_absolute(path)
		var gallery_target:=SubViewport.new()
		gallery_target.size=Vector2i(1440,1100)
		gallery_target.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(gallery_target)
		var gallery:=CanvasLayer.new()
		gallery_target.add_child(gallery)
		var backdrop:=ColorRect.new()
		backdrop.color=Color("e8e0d1")
		backdrop.size=Vector2(1440,1100)
		gallery.add_child(backdrop)
		var poses: Array[int]=[-1,0,1,2,3,4,5,8]
		for column in poses.size():
			var frame: int=poses[column]
			artwork.set_walking(frame>=0 and frame<6)
			artwork.set_cleaning_visual(frame==8)
			artwork.set("_phase",maxi(0,frame)/6.0+0.01)
			await identity("NONE")
			var costume_material: Material=artwork.material
			artwork.material=null
			var original: Image=await render()
			if frame<0:
				artwork.modulate=Color(0.65,0.7,0.75,0.45)
				var faded_original: Image=await render()
				artwork.material=costume_material
				var faded_outfit: Image=await render()
				check(same_region(faded_original,faded_outfit,Rect2i(0,0,512,256)),"Outfit shader preserves inherited character tint/opacity")
				artwork.modulate=Color.WHITE
			artwork.material=costume_material
			var unchanged: Image=await render()
			check(same_region(original,unchanged,Rect2i(0,0,512,256)),"Empty identity preserves original renderer pixels at frame "+str(frame))
			for row in range(4):
				var role: String=["NONE","CLEANER","SECURITY","MANAGER"][row]
				await identity(role)
				var painted: Image=await render()
				var file: String=role.to_lower()+"_"+str(frame)+".png"
				check(painted.save_png(path+"/"+file)==OK,"Native render "+file)
				check(same_region(original,painted,Rect2i(150,194,210,40)),"Original trousers/boots unchanged for "+file)
				if role=="MANAGER":
					check(same_region(original,painted,Rect2i(150,40,210,70)),"Manager retains hair/face pixels "+file)
					check(preserved_red(original,painted),"Manager preserves red satchel/strap pixels "+file)
					check(not same_region(original,painted,Rect2i(230,120,70,60)),"Manager changes visible upper clothing "+file)
					check(ivory_changes(original,painted)>=3,"Manager has a readable ivory inner collar "+file)
					if frame==8:
						var old_gold:=0
						for y in range(180,184):
							for x in range(226,232):
								var c:=painted.get_pixel(x,y)
								if c.r>0.4 and c.g>0.22 and c.b<0.24 and c.g>c.b*1.65 and c.r>c.g*1.03: old_gold+=1
						check(old_gold==0,"Bent-pose jacket hem has no old yellow remnant")
				var sprite:=Sprite2D.new()
				sprite.texture=ImageTexture.create_from_image(painted)
				sprite.region_enabled=true
				sprite.region_rect=Rect2(150,0,210,250)
				sprite.position=Vector2(column*178+89,row*260+160)
				gallery.add_child(sprite)
				var label:=Label.new()
				label.position=Vector2(column*178+12,row*260+20)
				label.text=role+" / "+("idle" if frame<0 else "clean" if frame==8 else str(frame))
				label.add_theme_color_override("font_color",Color("302b26"))
				label.add_theme_font_size_override("font_size",16)
				gallery.add_child(label)
		await process_frame
		await RenderingServer.frame_post_draw
		check(gallery_target.get_texture().get_image().save_png(path+"/gallery.png")==OK,"Actual native all-pose gallery")
		gallery_target.queue_free()
	game.start_game()
	await settle()
	check(outfit.get_outfit_view()["card_id"]=="NONE" and outfit.get_outfit_view()["headwear"]=="NONE","New game clears all identity costume state")
	viewport.queue_free()
	await process_frame
	finish()
