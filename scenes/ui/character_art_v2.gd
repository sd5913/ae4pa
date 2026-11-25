extends RefCounted
## Approved 2026-11-25 identities. Texture slicing only; source PNGs stay untouched.
const ROOT := "res://assets/final/characters/refresh_v2/"
const EXPRESSIONS := ["neutral", "smile", "surprised", "worried", "suspicious", "stern"]
const ROLES := {"an":"carol", "friend":"terese", "manager":"manager"}
static var _portraits: Dictionary = {}
static var _bounds: Dictionary = {}

static func solid_bounds(image: Image) -> Rect2i:
	# Ignore faint alpha fringes when aligning feet / the portrait's waist baseline.
	var lo := image.get_size()
	var hi := Vector2i(-1, -1)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a >= 0.5:
				lo = lo.min(Vector2i(x, y))
				hi = hi.max(Vector2i(x, y))
	return Rect2i(lo, hi - lo + Vector2i.ONE) if hi.x >= 0 else Rect2i()

static func portrait(role: String, expression: String = "neutral") -> Texture2D:
	if not ROLES.has(role): return null
	if not _portraits.has(role):
		var sheet: Texture2D = load(ROOT + "portraits/" + ROLES[role] + "_expressions.png")
		var source := sheet.get_image()
		var cell := Vector2i(source.get_width() / 3, source.get_height() / 2)
		var frames: Array[Image] = []
		var bounds: Array[Rect2i] = []
		var common := Vector2i.ZERO
		for i in range(6):
			var frame := source.get_region(Rect2i(Vector2i(i % 3, i / 3) * cell, cell))
			var rect := solid_bounds(frame)
			frames.append(frame)
			bounds.append(rect)
			common = common.max(rect.size)
		var textures: Dictionary = {}
		for i in range(6):
			# Translate into one common canvas; NEVER resize one expression separately.
			# A change of expression cannot move the centre or the waist baseline.
			var canvas := Image.create(common.x, common.y, false, Image.FORMAT_RGBA8)
			canvas.fill(Color.TRANSPARENT)
			canvas.blit_rect(frames[i], bounds[i], Vector2i((common.x - bounds[i].size.x) / 2, common.y - bounds[i].size.y))
			textures[EXPRESSIONS[i]] = ImageTexture.create_from_image(canvas)
		_portraits[role] = textures
	return _portraits[role].get(expression, _portraits[role]["neutral"])

static func avatar(role: String) -> Texture2D:
	var atlas := AtlasTexture.new()
	if role == "friend":
		atlas.atlas = load(ROOT + "source/terese_halfbody.png")
		atlas.region = Rect2(260, 20, 510, 510)
	else:
		atlas.atlas = load(ROOT + "source/carol_halfbody.png")
		atlas.region = Rect2(285, 25, 520, 520)
	return atlas
