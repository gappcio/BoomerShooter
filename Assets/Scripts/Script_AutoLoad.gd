extends Node

var random = RandomNumberGenerator.new();
var random_texture_offset: float = 0.0;
var random_dir: int = 1;
var random_dir_list: Array = [-1, 1];

func _ready():
	random.seed = hash("spucha");
	
func _process(delta):
	random_texture_offset = random.randf_range(0, 1);
	random_dir = random_dir_list[randi() % random_dir_list.size()];
