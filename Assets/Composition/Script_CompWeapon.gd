extends Node3D

enum BULLET_TYPE {
	raycast,
	projectile
}

@onready var shoot_timer: Timer = $"ShootTimer";
@onready var player_instance: CharacterBody3D = null;
@onready var raycast: RayCast3D = $"../../../../../Raycast";

@export_group("Properties")
@export var bullet_type: BULLET_TYPE;
@export_range(0, 1) var accuracy: float;
@export var always_hit_center: bool;
@export_range(0.01, 4, 0.01) var shooting_speed: float;
@export_range(0, 9) var bullet_amount: int;
@export_range(0, 100) var damage: float;

@export_group("Nodes")
@export var animated_sprite: AnimatedSprite2D;
@export var animation_tree: AnimationTree;
@export var audio: AudioStreamPlayer3D;
@export var control: Control;

enum STATE {
	idle,
	shoot
}

var state = STATE.idle;

func _ready():
	shoot_timer.wait_time = shooting_speed;
	player_instance = $"../../../../../../../";
	animation_tree["parameters/playback"].travel("idle");
	animation_tree.active = true;

func _process(delta):
	var player_speed: float = Vector2(player_instance.velocity.x, player_instance.velocity.z).length();
	
	if player_speed > 1:
		animation_tree["parameters/playback"].travel("walk");
		animation_tree["parameters/walk/TimeScale/scale"] = player_speed / 10;
	elif player_speed < 1:
		animation_tree["parameters/playback"].travel("idle");
		
	if Input.is_action_pressed("mouse_left") && state == STATE.idle:
		shoot();
		
	sprite_animation();

func shoot():

	state = STATE.shoot;
	shoot_timer.start();
	
	audio.play();
	
	if is_instance_valid(player_instance):
		player_instance.camera_shake();
	
	for i in bullet_amount:
	
		var random = RandomNumberGenerator.new();
		var random_bullet_spread: Array = [
			random.randf_range(-0.18, 0.18),
			random.randf_range(-0.18, 0.18),
			random.randf_range(-0.18, 0.18)
		];
	
		if i > 0:
			raycast.position = Vector3(
				cos(raycast.rotation.y) * random_bullet_spread[0],
				cos(raycast.rotation.x) * random_bullet_spread[1],
				cos(raycast.rotation.z) * random_bullet_spread[2]
			);
			raycast.rotation = Vector3(
				random_bullet_spread[0] / 4,
				random_bullet_spread[1] / 4,
				random_bullet_spread[2] / 4
			);
			
		#print(raycast.position);
	
		if raycast.is_colliding():
			
			var target = null;
			var collision_point = null;
			var collision_normal = null;
			
			var target_list = [];
			var col_point_list = [];
			var col_normal_list = [];
			
			while raycast.is_colliding():
				
				var _target = raycast.get_collider();
				
				target_list.append(_target);
				
				raycast.add_exception(_target);
				
				collision_point = raycast.get_collision_point();
				collision_normal = raycast.get_collision_normal();
				
				col_point_list.append(collision_point);
				col_normal_list.append(collision_normal);
				
				#print(col_point_list);
				
				raycast.force_raycast_update();
						
				
			for _target in target_list:
				
				raycast.remove_exception(_target);
			
			var _i = 0;
			
			for _target in target_list:
				
				if _target != null:
					if _target.is_in_group("wall") && _target.has_method("on_hit"):
						target = _target;
						target.on_hit(col_point_list[_i], col_normal_list[_i]);
						break;
					if _target.is_in_group("hitbox") && _target.has_method("hurt"):
						target = _target;
						target.hurt(col_point_list[_i], col_normal_list[_i], damage);
						break;
				
				_i += 1;
		
			target_list.clear();
			col_point_list.clear();
			col_normal_list.clear();
			
		#random.free();
		raycast.force_raycast_update();
		
	raycast.position = Vector3(0.0, 0.0, 0.0);


func sprite_animation():
	
	match(state):
		STATE.idle:
			animated_sprite.play("idle");
		STATE.shoot:
			animated_sprite.play("shoot");

func _on_animated_sprite_2d_animation_finished():
	state = STATE.idle;
	shoot_timer.stop();
	shoot_timer.wait_time = shooting_speed;
	
func set_canvas_position(pos: Vector2):
	control.position = pos;
