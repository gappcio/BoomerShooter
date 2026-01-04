extends Camera3D

@export var viewport: SubViewport;
@export var viewport_container: SubViewportContainer;
var player_camera: Camera3D = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_camera = get_tree().get_first_node_in_group("camera");
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_transform = player_camera.global_transform;
	self.fov = player_camera.fov;
	#viewport.size = Vector2(get_window().size);
	#viewport_container.size = Vector2(get_window().size);
	#print(get_window().size)
