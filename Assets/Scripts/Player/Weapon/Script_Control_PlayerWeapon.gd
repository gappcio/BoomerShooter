extends Node
class_name player_weapon_control

@onready var change_weapon_timer: Timer = $ChangeWeaponTimer;

enum WEAPON {
	none,
	pistol,
	shotgun
}

enum STATE {
	ready,
	draw,
	holster
}

var weapon_stack: Array = [WEAPON.none, WEAPON.pistol, WEAPON.shotgun];
var weapon_variation: int = 0;

var current_weapon: int = WEAPON.none;
var new_weapon: int = WEAPON.none;

var weapon_change_time: float = 0.1;

var state = STATE.ready;

var assets = [
	preload("res://Assets/Objects/Player/Viewmodels/SC_Viewmodel_None.tscn"),
	preload("res://Assets/Objects/Player/Viewmodels/SC_Viewmodel_Pistol.tscn"),
	preload("res://Assets/Objects/Player/Viewmodels/SC_Viewmodel_SShotgun.tscn")
];

var node_name = [
	"VIEWMODEL_None",
	"VIEWMODEL_Pistol",
	"VIEWMODEL_SShotgun"
];

func _ready():
	pass
	
func _process(delta):
	# Weapon Changing
	
	# Next weapon
	if Input.is_action_just_pressed("scroll_down"):
		if current_weapon < weapon_stack.size() - 1:
			change_weapon(current_weapon + 1);
			
	# Previous weapon
	if Input.is_action_just_pressed("scroll_up"):
		if current_weapon > WEAPON.none:
			change_weapon(current_weapon - 1);

func change_weapon(weapon):
	
	state = STATE.holster;
	change_weapon_timer.start(weapon_change_time);
	new_weapon = weapon;
	
	change_weapon_anim(false);


func set_new_weapon():

	# remove old weapon
	$"../Weapon".get_node(node_name[current_weapon]).queue_free();
	
	# instantiate new weapon
	var viewmodel_scene = assets[new_weapon];
	var viewmodel = viewmodel_scene.instantiate();
	
	# get new viewmodel control and set position
	
	var vw = $"../Weapon".call_deferred("add_child", viewmodel);
	
	match(new_weapon):
		WEAPON.pistol:
			viewmodel.position = Vector3(0.036, -0.508, 0.984);
		WEAPON.shotgun:
			viewmodel.position = Vector3(0.036, -0.508, -0.036);
	
	current_weapon = new_weapon;
	
	call_deferred("change_weapon_anim", true);


func get_weapon():
	return current_weapon;

func change_weapon_anim(up: bool):
	var tween = create_tween();
	var weapon = $"../Weapon".get_node(node_name[current_weapon]);
	
	match(current_weapon):
		WEAPON.none:
			tween.tween_property(weapon, "position", Vector3(0.0, -0.4 if up == false else 0.4, 0.0), 0.05).as_relative();
		WEAPON.pistol:
			tween.tween_property(weapon, "position", Vector3(0.0, -0.4 if up == false else 0.4, 0.0), 0.05).as_relative();
		WEAPON.shotgun:
			tween.tween_property(weapon, "position", Vector3(0.0, -0.4 if up == false else 0.4, 0.0), 0.05).as_relative();
	
	

func _on_change_weapon_timer_timeout():
	state = STATE.draw;
	set_new_weapon();
