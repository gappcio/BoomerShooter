
extends Node3D
class_name CLASSWeatherManager

@export var wind_texture: NoiseTexture2D;
var noise_offset: Vector3;
var noise: FastNoiseLite;

var wind_pos: float = 0.0;

func _ready() -> void:
	noise = wind_texture.noise;
	noise_offset = noise.offset;

func _process(delta: float) -> void:
	
	wind_pos += 0.1;
	
	noise_offset = Vector3(wind_pos, wind_pos, 0.0);
	
	wind_texture.noise.offset = noise_offset;

	#for node in get_tree().get_nodes_in_group("vegetation"):
		#var onscreen: VisibleOnScreenNotifier3D = node.find_child("OnScreen")
		#if onscreen:
			#if !onscreen.is_on_screen():
				#node.visible = false;
			#else:
				#node.visible = true;
