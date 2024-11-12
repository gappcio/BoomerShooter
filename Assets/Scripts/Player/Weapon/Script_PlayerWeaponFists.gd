extends Node3D
class_name player_weapon_fists

@onready var player_instance: CharacterBody3D = null;
@onready var sprite_anim: AnimatedSprite2D = $CanvasLayer/Control/AnimatedSprite2D;
@onready var shoot_timer: Timer = $ShootTimer;
@onready var area: Area3D = $"../../../FistsArea";

@onready var control: Control = $CanvasLayer/Control;

enum STATE {
	idle,
	attack
}

var state = STATE.idle;

var shoot_period: float = 0.2;

func _ready():
	area.monitoring = false;
	
func _process(delta):

	if Input.is_action_pressed("punch") && state == STATE.idle:
		shoot();

	match(state):
		STATE.idle:
			sprite_anim.play("idle");
		STATE.attack:
			sprite_anim.play("attack");

func shoot():
	
	state = STATE.attack;
	shoot_timer.start();
	area.monitoring = true;


func _on_animated_sprite_2d_animation_finished():
	state = STATE.idle;
	shoot_timer.stop();
	shoot_timer.wait_time = shoot_period;
	area.monitoring = false;


func _on_shoot_timer_timeout():
	pass
