extends Node3D
class_name player_weapon_pistol

@onready var player_instance: CharacterBody3D = null;
@onready var anim: AnimationTree = $CanvasLayer/Control/AnimatedSprite2D/AnimationTree;
@onready var sprite_anim: AnimatedSprite2D = $CanvasLayer/Control/AnimatedSprite2D;
@onready var shoot_timer: Timer = $ShootTimer;
@onready var raycast: RayCast3D = $"../../../../Raycast";
@onready var audio: AudioStreamPlayer3D = $Audio;

@onready var control: Control = $CanvasLayer/Control;

enum STATE {
	idle,
	shoot
}

var state = STATE.idle;

var shoot_period: float = 0.1;

func _ready():
	
	player_instance = $"../../../../../../";
	anim["parameters/playback"].travel("idle");
	anim.active = true;
	shoot_timer.wait_time = shoot_period;

func _process(delta):
	
	var player_speed: float = Vector2(player_instance.velocity.x, player_instance.velocity.z).length();
	
	if player_speed > 1:
		anim["parameters/playback"].travel("walk");
		anim["parameters/walk/TimeScale/scale"] = player_speed / 10;
	elif player_speed < 1:
		anim["parameters/playback"].travel("idle");
		
	if Input.is_action_pressed("mouse_left") && state == STATE.idle:
		shoot();
		
	sprite_animation();

func shoot():

	state = STATE.shoot;
	shoot_timer.start();
	
	audio.play();
	
	if is_instance_valid(player_instance):
		player_instance.camera_shake();
	
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
			
			_i += 1;
	
		target_list.clear();
		col_point_list.clear();
		col_normal_list.clear();
		

func _on_shoot_timer_timeout():
	pass
	#state = STATE.idle;
	#shoot_timer.stop();
	#shoot_timer.wait_time = shoot_period;

func sprite_animation():
	
	match(state):
		STATE.idle:
			sprite_anim.play("idle");
		STATE.shoot:
			sprite_anim.play("shoot");


func _on_animated_sprite_2d_animation_finished():
	state = STATE.idle;
	shoot_timer.stop();
	shoot_timer.wait_time = shoot_period;
	
func set_canvas_position(pos: Vector2):
	control.position = pos;
