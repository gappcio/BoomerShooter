extends Node3D

enum BULLET_TYPE {
	raycast,
	projectile
}

@onready var player_instance: CharacterBody3D = null;
@onready var camera: Camera3D = null;
@onready var raycast: RayCast3D = $"../../../../../Raycast";

@export_group("Properties")
@export var bullet_type: BULLET_TYPE;
@export_range(0, 1) var accuracy: float;
@export var always_hit_center: bool;
@export_range(0.01, 10, 0.01) var shooting_speed: float;
@export_range(0.01, 10, 0.01) var shooting_interval: float;
@export_range(0, 9) var bullet_amount: int;
@export_range(0, 100) var damage: float;

@export_group("Nodes")
@export var shoot_timer: Timer;
@export var audio: AudioStreamPlayer3D;
@export var anim_weapon: AnimationPlayer;
@export var anim_arms: AnimationPlayer;
@export var anim_tree_arms: AnimationTree;
@export var anim_tree_weapon: AnimationTree;
@export var anim_fx: AnimationPlayer;
@export var viewmodel_arms: Node3D;
@export var viewmodel_weapon: Node3D;
@export var viewmodel_anim: AnimationPlayer;
@export var model_node: Node3D;

@export_group("Animation Variables Arms")
@export var anim_hands_idle: String;
@export var anim_hands_walk: String;
@export var anim_hands_shoot: String;

@export_group("Animation Variables Weapon")
@export var anim_weapon_idle: String;
@export var anim_weapon_walk: String;
@export var anim_weapon_shoot: String;

var is_shooting: bool = false;
var shooting_anim_finished: bool = false;
var can_shoot: bool = true;

var shoot_buffer_max: float = 8.0;
var shoot_buffer: float = 0.0;

var mouse_input: Vector2;

enum STATE {
	idle,
	walk,
	shoot,
	air
}

var state = STATE.idle;

func _ready():
	Autoload.player_landed.connect(_on_player_landed);
	
	shoot_timer.wait_time = shooting_interval;
	player_instance = get_tree().get_first_node_in_group("player");
	camera = get_tree().get_first_node_in_group("camera");
	#animation_tree["parameters/playback"].travel("idle");
	anim_weapon.play(anim_weapon_idle);
	anim_arms.play(anim_hands_idle);
	anim_tree_arms["parameters/playback"].travel("idle");
	anim_tree_weapon["parameters/playback"].travel("idle");
	anim_fx.play("none");
	
func _process(delta):
	
	sprite_animation();

func _physics_process(delta: float) -> void:
	
	var player_speed: float = Vector2(player_instance.velocity.x, player_instance.velocity.z).length();
	#DebugDraw3D.draw_line(player_instance.muzzle_point.global_position, to_global(player_instance.raycast.target_position), Color(1.0, 0.0, 1.0));
	if is_instance_valid(player_instance):
		
		if !is_shooting:
			if player_instance.grounded:
				if player_speed < 1.0:
					state = STATE.idle;
				else:
					state = STATE.walk;
			else:
				state = STATE.air;
		else:
			state = STATE.shoot;
			
	
		viewmodel_arms.rotation.x = camera.camera_tilt * 2.0;
		viewmodel_weapon.rotation.x = viewmodel_arms.rotation.x;
		
		
		
		mouse_input = lerp(mouse_input, Vector2.ZERO, 10.0 * delta);
		model_node.rotation.x = lerp(model_node.rotation.x, mouse_input.y * 0.0025, 5.0 * delta);
		model_node.rotation.y = lerp(model_node.rotation.y, mouse_input.x * 0.0025, 5.0 * delta);
		
		
		
	if Input.is_action_pressed("mouse_left"):
		shoot_buffer = shoot_buffer_max;
	
	if shoot_buffer > 0.0:
		shoot_buffer -= 1.0;
		
		if !is_shooting:
			shoot();

func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var viewport_transform: Transform2D = get_tree().root.get_final_transform();
			mouse_input = event.xformed_by(viewport_transform).relative;

func shoot():

	is_shooting = true;
	shooting_anim_finished = false;
	shoot_timer.start();
	
	var tracer = Autoload.FX_BULLET_TRACER.instantiate();
	get_tree().get_first_node_in_group("world").add_child(tracer);
	tracer.global_transform = player_instance.muzzle_point.global_transform;
	tracer.endpoint = to_global(player_instance.raycast.target_position);
	
	audio.pitch_scale = randf_range(0.9, 1.1);
	audio.play();
	
	if is_instance_valid(player_instance):
		camera.camera_shoot_effect();
		camera.camera_shake(0.1);
	
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
				
				if _target is GridMap: break;
				
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
						tracer.endpoint = col_point_list[_i];
						break;
					if _target.is_in_group("hitbox") && _target.has_method("hurt"):
						target = _target;
						target.hurt(col_point_list[_i], col_normal_list[_i], damage);
						tracer.endpoint = col_point_list[_i];
						break;
				_i += 1;
		
			target_list.clear();
			col_point_list.clear();
			col_normal_list.clear();
			
		raycast.force_raycast_update();
		
	raycast.position = Vector3(0.0, 0.0, 0.0);
	raycast.rotation = Vector3(0.0, 0.0, 0.0);
	tracer.set_lifetime(tracer.endpoint);

func sprite_animation():
	
	match(state):
		STATE.idle:
			#anim_weapon.play(anim_weapon_idle);
			#anim_arms.play("idle");
			anim_tree_arms["parameters/playback"].travel("idle");
			anim_tree_arms.set("parameters/idle/TimeScale/scale", 1.0);
			
			anim_tree_weapon["parameters/playback"].travel("idle");
			anim_tree_weapon.set("parameters/idle/TimeScale/scale", 1.0);
			
			#anim_weapon.speed_scale = 1.0;
			anim_fx.play("none");
		STATE.walk:
			#var player_speed: float = Vector2(player_instance.velocity.x, player_instance.velocity.z).length();
			
			var anim_speed: float = clamp(player_instance.spd / 10.0, 0.0, 1.5);
			
			#anim_weapon.play(anim_weapon_idle);
			#anim_arms.play("walk");
			anim_tree_arms["parameters/playback"].travel("walk");
			anim_tree_arms.set("parameters/walk/TimeScale/scale", anim_speed);
			
			anim_tree_weapon["parameters/playback"].travel("walk");
			anim_tree_weapon.set("parameters/walk/TimeScale/scale", anim_speed);
			
			#anim_weapon.speed_scale = 1.0;
			anim_fx.play("none");
			
		STATE.shoot:
			#anim_weapon.play(anim_weapon_shoot);
			#anim_arms.play("shoot");
			anim_tree_arms["parameters/playback"].travel("shoot");
			anim_tree_arms.set("parameters/shoot/TimeScale/scale", shooting_speed);
			
			anim_tree_weapon["parameters/playback"].travel("shoot");
			anim_tree_weapon.set("parameters/shoot/TimeScale/scale", shooting_speed);
			
			#anim_weapon.speed_scale = shooting_speed;
			anim_fx.play("fire");
			anim_fx.speed_scale = shooting_speed / 2;
			
		STATE.air:

			if is_instance_valid(player_instance):
				if player_instance.velocity.y > 0.0:
					viewmodel_anim.play("jump");
				if player_instance.velocity.y < 0.0:
					viewmodel_anim.play("fall");

			anim_tree_arms["parameters/playback"].travel("idle");
			anim_tree_arms.set("parameters/idle/TimeScale/scale", 0.0);
			
			anim_tree_weapon["parameters/playback"].travel("idle");
			anim_tree_weapon.set("parameters/idle/TimeScale/scale", 0.0);
			
			anim_fx.play("none");

func _on_player_landed() -> void:
	viewmodel_anim.play("land");
	viewmodel_anim.seek(0);
	if is_instance_valid(player_instance):
		player_instance.land_anim();
		
func _on_shoot_timer_timeout() -> void:
	is_shooting = false;
	shoot_timer.stop();
	shoot_timer.wait_time = shooting_interval;

func _on_anim_pistol_animation_finished(anim_name: StringName) -> void:
	if anim_name == anim_weapon_shoot:
		shooting_anim_finished = true;
		is_shooting = false;


func _on_anim_action_animation_finished(anim_name: StringName) -> void:
	if anim_name == "land": 
		viewmodel_anim.play("stop");
		viewmodel_anim.seek(0);
