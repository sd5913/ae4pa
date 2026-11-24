extends RefCounted
const MAXIMUM := 100.0
const MULTIPLIER := 1.35
const DRAIN := 100.0 / 3.0
const RECOVERY := 100.0 / 6.0
const DELAY := 1.0
const RESTART := 30.0
var value := MAXIMUM
var running := false
var exhausted := false
var rest := 0.0
func toggle() -> void:
 if running: running = false
 elif not exhausted: running = true
func tick(delta: float, moved: bool) -> void:
 if running and moved:
  value = maxf(0.0, value-DRAIN*delta)
  rest = 0.0
  if value <= 0.00001:
   value = 0.0
   running = false
   exhausted = true
 else:
  var before := rest
  rest += delta
  value = minf(MAXIMUM,value+RECOVERY*(maxf(0.0,rest-DELAY)-maxf(0.0,before-DELAY)))
 if value >= RESTART: exhausted = false
func capture() -> Dictionary:
 return {"value":value,"rest":rest,"exhausted":exhausted}
func restore(data: Dictionary) -> void:
 value = clampf(float(data.get("value",MAXIMUM)),0,MAXIMUM)
 rest = maxf(0,float(data.get("rest",0)))
 exhausted = bool(data.get("exhausted",value<RESTART)) and value<RESTART
 running = false
