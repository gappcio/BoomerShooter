shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, unshaded, shadows_disabled;

uniform sampler2D gradient_tex : source_color, filter_nearest;

void fragment() {
// ColorConstant:4
	vec4 n_out4p0 = vec4(1.000000, 1.000000, 1.000000, 1.000000);


	vec4 n_out2p0;
// Texture2D:2
	n_out2p0 = texture(gradient_tex, UV);


// Output:0
	ALBEDO = vec3(n_out4p0.xyz);
	ALPHA = n_out2p0.x;


}
