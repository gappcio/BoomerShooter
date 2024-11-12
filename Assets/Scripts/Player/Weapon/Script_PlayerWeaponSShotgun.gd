extends Node3D
class_name player_weapon_sshotgun

@onready var player_instance: CharacterBody3D = null;
@onready var anim: AnimationTree = $CanvasLayer/Control/AnimatedSprite2D/AnimationTree;
@onready var sprite_anim: AnimatedSprite2D = $CanvasLayer/Control/AnimatedSprite2D;
@onready var shoot_timer: Timer = $ShootTimer;
@onready var raycast: RayCast3D = $"../../../../Raycast";
@onready var audio: AudioStreamPlayer3D = $Audio;

@onready var control: Control = $CanvasLayer/Control;

@onready var weapon: Node3D = $"ComponentWeapon";

enum STATE {
	idle,
	shoot
}

func _on_animated_sprite_2d_animation_finished():
	pass
	
func set_canvas_position(pos: Vector2):
	weapon.set_canvas_position(pos);
