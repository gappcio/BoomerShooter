extends Node3D
class_name player_weapon_fists

@onready var player: CharacterBody3D = null;
@onready var anim_hand: AnimationPlayer = $hand_viewmodel/AnimHand
@onready var punch_timer: Timer = $PunchTimer;
@onready var area: Area3D = $"../../../FistsArea";
@onready var camera: Camera3D;
@onready var audio: AudioStreamPlayer3D = $Audio

var punch_buffer_max: float = 0.25;
var punch_buffer: float = 0.0;

var is_punching: bool = false;

enum STATE {
	idle,
	attack,
	vault,
	vault_ready
}

var state = STATE.idle;

var punch_period: float = 0.7;


func _ready():
	player = get_tree().get_first_node_in_group("player");
	camera = get_tree().get_first_node_in_group("camera");
	area.monitoring = false;
	punch_timer.wait_time = punch_period;


func _process(delta):
	
	if punch_timer.is_stopped():
		if player.vault_raycast.is_colliding()\
		&& !player.vault_raycast_top.is_colliding()\
		&& !player.is_vaulting\
		&& !player.grounded:
			state = STATE.vault_ready;
		elif player.is_vaulting:
			state = STATE.vault;
		else:
			state = STATE.idle;
	
	if Input.is_action_just_pressed("punch"):
		punch_buffer = punch_buffer_max;
	
	if punch_buffer > 0.0:
		punch_buffer -= delta;
		
		if !is_punching:
			punch();
	
	match(state):
		STATE.idle:
			anim_hand.play("ref");
		STATE.attack:
			anim_hand.play("punch");
		STATE.vault:
			anim_hand.play("vault");
		STATE.vault_ready:
			anim_hand.play("vault_ready");


func punch():
	audio.pitch_scale = randf_range(0.9, 1.1);
	audio.play();
	is_punching = true;
	state = STATE.attack;
	punch_timer.start();
	area.monitoring = true;
	camera.camera_shake(0.1);
	camera.camera_shoot_effect();

func _on_anim_hand_animation_finished(anim_name: StringName) -> void:
	if anim_name == "vault":
		state = STATE.idle;
		anim_hand.seek(0);

func _on_punch_timer_timeout() -> void:
	state = STATE.idle;
	punch_timer.stop();
	is_punching = false;
	punch_timer.wait_time = punch_period;
	area.monitoring = false;
	anim_hand.seek(0);
