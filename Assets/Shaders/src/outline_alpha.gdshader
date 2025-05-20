shader_type spatial;

render_mode cull_front, unshaded, depth_draw_never;

global uniform vec4 outline_color;
global uniform float outline_width;
uniform vec3 player_pos;

void vertex() {
	vec4 clip_position = 
			PROJECTION_MATRIX *
			(MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal =
			mat3(PROJECTION_MATRIX) *
			(mat3(MODELVIEW_MATRIX) * NORMAL);
	clip_position.xy +=
			normalize(clip_normal.xy) /
			VIEWPORT_SIZE *
			clip_position.w *
			outline_width;
	POSITION = clip_position;
}

void fragment() {
	
	float fade_distance = length(VERTEX);

	float fade = clamp(smoothstep(0.5, 3.0, fade_distance), 0.5, 1.0);

	ALPHA *= fade;
	
	ALBEDO = outline_color.rgb;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
	ALPHA_HASH_SCALE = 0.1;
}
