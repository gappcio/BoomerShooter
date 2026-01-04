shader_type spatial;
render_mode unshaded;

uniform float posterize_level = 8.0;
uniform float max_distance = 50.0;

void fragment() {
	float dist = length((INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz);
	float t = clamp(dist / max_distance, 0.0, 1.0);
	float levels = mix(posterize_level, 1.0, t);
	vec3 col = ALBEDO;
	col = floor(col * levels) / levels;

	ALBEDO = col;
}
