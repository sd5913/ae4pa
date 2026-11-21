shader_type canvas_item;

// Applied only to Carol's Artwork; source geometry and lower-body pixels stay intact.
uniform bool manager_active = false;
uniform vec4 coat_rect = vec4(0.0);
uniform vec4 hem_rect = vec4(0.0);
uniform vec2 collar_top = vec2(0.0);
uniform vec2 collar_bottom = vec2(0.0);
varying vec2 sprite_position;
varying vec4 item_modulate;

void vertex() {
	sprite_position = VERTEX;
	item_modulate = COLOR;
}

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec3 color = original.rgb;
	if (manager_active && original.a > 0.0) {
		bool upper_body = sprite_position.x >= coat_rect.x && sprite_position.x <= coat_rect.x + coat_rect.z
			&& sprite_position.y >= coat_rect.y && sprite_position.y <= coat_rect.y + coat_rect.w;
		bool lower_hem = sprite_position.x >= hem_rect.x && sprite_position.x <= hem_rect.x + hem_rect.z
			&& sprite_position.y >= hem_rect.y && sprite_position.y <= hem_rect.y + hem_rect.w;
		upper_body = upper_body || lower_hem;
		// Original mustard cloth only: excludes skin, red bag, outlines and brown trousers.
		bool cloth = color.r > 0.4 && color.g > 0.22 && color.b < 0.24
			&& color.g > color.b * 1.65 && color.r > color.g * 1.03;
		if (upper_body && cloth) {
			float light = clamp((color.g - 0.22) / 0.64, 0.0, 1.0);
			color = mix(vec3(0.105, 0.165, 0.175), vec3(0.265, 0.385, 0.395), light);
		}
		// Keep source outline and skin; turn the existing dark inner blouse ivory.
		float length_y = max(collar_bottom.y - collar_top.y, 0.01);
		float t = (sprite_position.y - collar_top.y) / length_y;
		float center_x = mix(collar_top.x, collar_bottom.x, t);
		bool inner_blouse = t >= 0.0 && t <= 1.0 && abs(sprite_position.x - center_x) < mix(3.0, 0.5, t);
		if (inner_blouse && original.r > 0.14 && original.r < 0.40 && original.g > 0.075 && original.b < 0.26) {
			color = vec3(0.91, 0.84, 0.72);
		}
	}
	COLOR = vec4(color, original.a) * item_modulate;
}
