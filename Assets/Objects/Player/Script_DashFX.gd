extends GPUParticles3D

var player;
var shader_material: ShaderMaterial;
var gradient: GradientTexture2D;
var color: Color;

@export var alpha_curve: Curve;

@onready var dashing_fx: Node3D = $".."

func _ready() -> void:
	player = owner;
	shader_material = draw_pass_1.surface_get_material(0);
	gradient = shader_material.get_shader_parameter("gradient_tex");
	color = gradient.gradient.colors[1];


func _process(delta: float) -> void:
	
	if shader_material:
		
		var spd = clamp(player.spd, 0.0, 20.0);
		var alpha = alpha_curve.sample(spd);
		
		color = Color(alpha, alpha, alpha, 1.0);
		gradient.gradient.colors[1] = color;
		shader_material.set_shader_parameter("gradient_tex", gradient);
		
		if is_instance_valid(player):
			if player.input_dir.x == 1.0\
			|| player.input_dir.x == -1.0:
				dashing_fx.rotation.y = PI/2;
			else:
				dashing_fx.rotation.y = 0.0;
				
			dashing_fx.visible = true;
			#dashing_fx.visible = player.spd > 11.0;
