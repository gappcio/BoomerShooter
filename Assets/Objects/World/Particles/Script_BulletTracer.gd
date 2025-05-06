extends Node3D

@onready var _mesh: MeshInstance3D = $MeshInstance3D;
var endpoint: Vector3;
var time = 0.1;

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	
	var vec = endpoint - global_position;
	var add = vec.normalized() * 100.0 * delta;
	add.limit_length(vec.length());
	global_position += add;
	
	time -= delta;
	if time <= 0.0:
		queue_free();

func set_lifetime(endpoint: Vector3) -> void:
	var length = (endpoint - global_position).length();
	time = length / 40.0;
