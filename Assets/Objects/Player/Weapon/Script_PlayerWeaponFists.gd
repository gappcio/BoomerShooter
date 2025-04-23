extends Node3D
class_name player_weapon_fists

@onready var player: CharacterBody3D = null;
@onready var anim_hand: AnimationPlayer = $hand_viewmodel/AnimHand
@onready var shoot_timer: Timer = $PunchTimer;
@onready var area: Area3D = $"../../../FistsArea";

enum STATE {
	idle,
	attack,
	vault,
	vault_ready
}

var state = STATE.idle;

var shoot_period: float = 1.0;


func _ready():
	player = get_tree().get_first_node_in_group("player");
	area.monitoring = false;


func _process(delta):
	
	if shoot_timer.is_stopped():
		if player.vault_raycast.is_colliding()\
		&& !player.vault_raycast_top.is_colliding()\
		&& !player.is_vaulting\
		&& !player.grounded:
			state = STATE.vault_ready;
		elif player.is_vaulting:
			state = STATE.vault;
		else:
			state = STATE.idle;
	
	if Input.is_action_pressed("punch") && (state == STATE.idle || state == STATE.vault_ready):
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

	print(state)
func punch():
	
	state = STATE.attack;
	shoot_timer.start();
	area.monitoring = true;


func _on_anim_hand_animation_finished(anim_name: StringName) -> void:
	if anim_name == "punch":
		state = STATE.idle;
		shoot_timer.stop();
		shoot_timer.wait_time = shoot_period;
		area.monitoring = false;
	if anim_name == "vault":
		state = STATE.idle;

func _on_punch_timer_timeout() -> void:
	pass
