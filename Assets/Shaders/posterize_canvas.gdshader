shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float depth_level      : hint_range(0.0, 1.0, 0.01);
uniform float posterize_level  : hint_range(1.0, 256.0, 1.0);

float lerp_f(float a, float b, float t) {
	return a * (1.0 - t) + b * t;
}

vec3 lerp_v(vec3 a, vec3 b, vec3 t) {
	return a * (1.0 - t) + b * t;
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);

	float gray = max(color.r, max(color.g, color.b));
	float poster = floor(gray * posterize_level) / posterize_level;

	float depth = texture(screen_texture, SCREEN_UV).r;
	depth = clamp(depth * depth_level, 0.0, 1.0);

	float depth_step = floor(depth * 5.0) / 5.0;

	vec3 posterized = floor(color.rgb * posterize_level) / posterize_level;

	color.rgb = lerp_v(color.rgb, posterized, vec3(depth_step));

	COLOR = color;
	COLOR = vec4(posterized, 1.0);
}
