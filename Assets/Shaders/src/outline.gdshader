shader_type spatial;

render_mode cull_front, unshaded;

global uniform vec4 outline_color;
global uniform float outline_width;

uniform float outline_depth;

varying float depth;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

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
			(outline_depth);
	POSITION = clip_position;
}

void fragment() {
	//depth = texture(depth_texture, SCREEN_UV).r;
	//depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	ALBEDO = outline_color.rgb;
}
