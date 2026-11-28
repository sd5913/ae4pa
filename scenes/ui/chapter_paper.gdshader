shader_type canvas_item;
render_mode unshaded;
uniform sampler2D scene_screen : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D paper_grain : source_color, repeat_enable, filter_linear;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec3 scene = texture(scene_screen, SCREEN_UV).rgb;
	float grain = dot(texture(paper_grain, UV).rgb, vec3(0.299, 0.587, 0.114));
	// Retain the scene's RGB beneath translucent warm-brown paper; never
	// replace its color with luminance. The title gets a softer, darker area.
	vec2 title_distance = (UV - vec2(0.5, 0.49)) * vec2(1.0, 1.45);
	float title_focus = 1.0 - smoothstep(0.04, 0.57, length(title_distance));
	float transmission = 0.91 - 0.22 * title_focus;
	float texture_light = 1.0 + (grain - 0.24) * 0.12;
	float vignette = 1.0 - 0.08 * smoothstep(0.3, 0.72, distance(UV, vec2(0.5)));
	vec3 shaded_scene = scene * transmission * texture_light * vignette;
	float brown_opacity = 0.35 + 0.10 * title_focus;
	vec3 paper = mix(shaded_scene, vec3(0.15, 0.09, 0.048), brown_opacity);
	COLOR = vec4(mix(scene, paper, strength), 1.0);
}
