extends Node3D
class_name player_weapon_pistol

@onready var player_instance: CharacterBody3D = null;
@onready var shoot_timer: Timer = $ShootTimer;
@onready var raycast: RayCast3D = $"../../../../Raycast";
@onready var audio: AudioStreamPlayer3D = $Audio;

@onready var weapon: Node3D = $"ComponentWeapon";

enum STATE {
	idle,
	shoot
}
