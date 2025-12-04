shader_type spatial;
render_mode cull_disabled;

uniform sampler2D noise;
uniform float patch_scale = 5.0;
varying float patch_factor;

uniform sampler2D wind_noise;
uniform float wind_str = 0.1;
uniform vec2 wind_dir = vec2(1.0, 0.0);

varying float wind_bend;
uniform float wind_bend_str = 2.0;

uniform float size_min = 0.2;
uniform float size_max = 1.0;

uniform float size = 0.5;
uniform float blade_bend = 0.5;

uniform vec3 color_old = vec3(0.6, 0.8, 0.2);
uniform vec3 color_new = vec3(0.3, 0.8, 0.1);

varying float bottom_to_top;

void vertex() {
	bottom_to_top = 1.0 - UV.y;
	
	vec2 wind_pos = NODE_POSITION_WORLD.xz / 10.0;
	wind_pos -= (TIME * 0.25) * wind_dir * wind_str;
	
	wind_bend = texture(wind_noise, wind_pos).x;
	wind_bend *= wind_str;
	wind_bend *= bottom_to_top * 2.0;
	
	mat4 inv_model = inverse(MODEL_MATRIX);
	vec2 local_dir = (inv_model * vec4(wind_dir.x, 0.0, wind_dir.y, 0.0)).xz;
	
	VERTEX.xz += wind_bend * local_dir;
	
	VERTEX.z += blade_bend + pow(bottom_to_top / 1.4, 2.0);
	//VERTEX.z += bottom_to_top * 0.3;
	VERTEX *= size;
	
	patch_factor = texture(noise, NODE_POSITION_WORLD.xz / patch_scale).r;
	
	VERTEX *= mix(size_min, size_max, patch_factor);
}

void fragment() {
	
	if (!FRONT_FACING) NORMAL = -NORMAL;
	
	AO = bottom_to_top - wind_bend;
	AO_LIGHT_AFFECT = 1.0;
	BACKLIGHT = vec3(0.2, 0.4, 0.3);
	ROUGHNESS = 0.4;
	NORMAL = mix(NORMAL, vec3(0.0, 0.1, 0.0), bottom_to_top);
	SPECULAR = 0.2;
	
	ALBEDO = mix(color_new, color_old, patch_factor);
}
