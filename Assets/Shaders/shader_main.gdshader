shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_back;

uniform sampler2D dot_tex;
uniform sampler2D tex : source_color;
uniform float max_distance = 50.0;
uniform bool enable_rim = true;
uniform float dot_size : hint_range(1.0, 100.0, 0.1) = 6.0;

vec3 linear_light(vec3 A, vec3 B) {
    return clamp(A + 2.0 * B - 1.0, 0.0, 1.0);
}

float lerp(float a, float b, float t) {
	return (((1.0 - t) * a) + t * b);
}

vec3 lerp(vec3 a, vec3 b, vec3 t) {
	return (((1.0 - t) * a) + t * b);
}

void fragment() {

	vec4 albedo = texture(tex, UV);

	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	float dist = -pixel_position.z;

	float t = clamp(dist / max_distance, 0.0, 1.0);
	float posterize_level = 8.0;
	float max_posterize_level = 256.0;
	float levels = 4.0;
	//levels = lerp(4.0, 256.0, 1.0 - t);
	//levels = (3.0 * pow(value, 2.0)) - (2.0 * (pow(value, 3.0))) + 4.0;
	float smooths = smoothstep(0.0, 1.0, t);
	levels = lerp(posterize_level, max_posterize_level, 1.0 - pow(t, 0.15));

	vec3 col = albedo.rgb;
	col = floor(col * levels) / levels;

	ALBEDO = col;
}

void light() {
	float diffuse = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
	float specular = pow(dot(NORMAL, normalize(LIGHT + VIEW)), 5.0);
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);

	diffuse = smoothstep(0.1, 0.40, diffuse);
	//diffuse = step(0.5, diffuse);
	//diffuse = smoothstep(0.1, 0.5, diffuse);
	specular = smoothstep(0.85, 0.9, specular);
	rim = smoothstep(0.4, 0.5, rim);

	vec2 dot_uv = FRAGCOORD.xy / dot_size;

	float light_value = step(texture(dot_tex, dot_uv).r, diffuse);
	//float specular_value = step(texture(dot_tex, dot_uv).r, specular);
	float rim_value = enable_rim ? step(texture(dot_tex, dot_uv).r, rim) : 0.0;

	DIFFUSE_LIGHT += ((light_value + (specular * .75) + (rim_value * 0.5)) * LIGHT_COLOR * ATTENUATION) / (PI * 1.0);
	SPECULAR_LIGHT += specular * .01;

	//DIFFUSE_LIGHT += light_value;
}