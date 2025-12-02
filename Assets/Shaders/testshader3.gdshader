shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_back;

void fragment() {
	ALBEDO = vec3(0.5, 0.21, 0.63);
}

void light() {
	float diffuse = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
	float specular = pow(dot(NORMAL, normalize(LIGHT + VIEW)), 5.0);
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	
	diffuse = smoothstep(0.4, 0.45, diffuse);
	specular = smoothstep(0.85, 0.9, specular);
	rim = step(0.5, rim);
	
	DIFFUSE_LIGHT += ((diffuse + (rim * 0.5)) * LIGHT_COLOR * ATTENUATION) / PI;
	SPECULAR_LIGHT += specular;
}