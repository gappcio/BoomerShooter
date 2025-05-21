extends Node3D
class_name CLASSGameManager

@export var gore_texture: NoiseTexture2D;
var noise_offset: Vector3;
var noise: FastNoiseLite;

var gore_pos: float = 0.0;

func _ready() -> void:
	noise = gore_texture.noise;
	noise_offset = noise.offset;

func _process(delta: float) -> void:
	
	gore_pos += 2.0;
	
	noise_offset = Vector3(gore_pos, gore_pos, 0.0);
	
	gore_texture.noise.offset = noise_offset;
