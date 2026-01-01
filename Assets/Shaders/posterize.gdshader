shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;
uniform float depth_level : hint_range(0.0, 1.0, 0.01);
uniform float posterize_level : hint_range(0.0, 256.0, 0.1);
uniform vec2 gamma;

float lerp(float a, float b, float t) {
	return (((1.0 - t) * a) + t * b);
}
vec3 lerp(vec3 a, vec3 b, vec3 t) {
	return (((1.0 - t) * a) + t * b);
}

void vertex() {
	//POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	//color.rgb = pow(color.rgb, vec3(gamma.x));
	
	float gray = max(color.r, max(color.g, color.b));
	float low = floor(gray * posterize_level) / posterize_level;
	float high = ceil(gray * posterize_level) / posterize_level;
	
	float diff_low = abs(low - gray);
	float diff_high = abs(high - gray);
	
	float level = diff_low < diff_high ? diff_low : diff_high;
	float adjust = level / gray;
	
	//color.rgb = floor(color.rgb * posterize_level) / posterize_level;
	float depth = texture(depth_texture, SCREEN_UV).r;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	//depth += VERTEX.z;
	
	vec3 color_depth = vec3(depth * depth_level);
	color_depth = floor(color_depth * 5.0) / 5.0;
	vec3 color_posterize = floor(color.rgb * posterize_level) / posterize_level;
	
	//color.rgb = vec3(depth * depth_level);
	color.rgb = lerp(color.rgb, color_posterize, color_depth);
	//color.rgb = color_posterize;
	//color.rgb = color_depth;
	
	//color.rgb *= adjust;
	//color.rgb = pow(color.rgb, vec3(gamma.y));
	
	ALBEDO = color.rgb;
	ALPHA = color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
