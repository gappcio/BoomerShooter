extends Camera3D
class_name PlayerCamera

@export var noise: FastNoiseLite;

@onready var head: Node3D = $".."

var player;
var camera_tilt: float;
var camera_bob_time: float = 0.0;

var trauma: float = 0.0;
var init_rotation: Vector3 = rotation_degrees;
var time: float;


func _ready() -> void:
	player = owner;


func _process(delta: float) -> void:
	
	var tilt_strength: float = player.input_dir.x / player.MAX_SPEED;
	camera_tilt = lerp(camera_tilt, tilt_strength, 0.1);
	
	if abs(camera_tilt) < 0.001:
		camera_tilt = 0.0;
	
	time += delta;
	trauma = max(trauma - delta * 1.0, 0.0);
	
	var _rotation_z := 0.0;
	
	if trauma > 0.0:
		rotation_degrees.x = (init_rotation.x + 10.0) * trauma * get_random_noise(123);
		rotation_degrees.y = (init_rotation.y + 10.0) * trauma * get_random_noise(2137);
		_rotation_z = camera_tilt + (init_rotation.z + 5.0) * trauma * get_random_noise(69);
		
	rotation_degrees.z = rad_to_deg(camera_tilt) + _rotation_z;


func get_random_noise(_seed: int) -> float:
	return noise.get_noise_1d(time * _seed);


func camera_shake(trauma_amount) -> void:
	
	trauma += clamp(trauma_amount, 0.0, 1.0);


func camera_bobbing(velocity, delta) -> void:
	
	camera_bob_time += delta * player.spd * float(player.grounded);
	
	self.position.y = lerp(self.position.y, 0.05 * -sin(camera_bob_time * 1.2), 0.1);


func camera_bobbing_reset() -> void:
	
	if abs(self.position.y) < 0.001:
		self.position.y = 0.0;
		return;
	
	self.position.y = lerp(self.position.y, 0.0, 0.1);
	
	camera_bob_time = 0.0;


func camera_shoot_effect():
	
	var tween = create_tween().set_parallel();
	var fov_change = 5.0;
	var time = 0.025;
	
	if self.fov > 1.0 && self.fov < 179.0:
		tween.tween_property(self, "fov", fov_change, time).as_relative();
		tween.chain().tween_property(self, "fov", -fov_change, time).as_relative();
