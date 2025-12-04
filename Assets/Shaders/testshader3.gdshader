shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_back;

varying vec2 dot_uv;
uniform sampler2D dot_tex;
uniform sampler2D tex : source_color;

vec3 linear_light(vec3 A, vec3 B) {
    return clamp(A + 2.0 * B - 1.0, 0.0, 1.0);
}

void fragment() {
	
	dot_uv = SCREEN_UV * 40.0;
	
	float aspect_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	dot_uv.x *= aspect_ratio;
	
	vec4 albedo = texture(tex, UV);
	ALBEDO = albedo.rgb;
}

void light() {
	float diffuse = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
	float specular = pow(dot(NORMAL, normalize(LIGHT + VIEW)), 5.0);
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	
	//diffuse = smoothstep(0.4, 0.45, diffuse);
	specular = smoothstep(0.85, 0.9, specular);
	rim = step(0.5, rim);
	
	float light_value = step(texture(dot_tex, dot_uv).r, diffuse);
	
	DIFFUSE_LIGHT += ((light_value + (rim * 0.5)) * LIGHT_COLOR * ATTENUATION) / PI;
	SPECULAR_LIGHT += specular;

	//DIFFUSE_LIGHT += light_value;
}