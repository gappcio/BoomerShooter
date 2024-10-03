extends Node
class_name player_weapon_control

@onready var change_weapon_timer: Timer = $ChangeWeaponTimer;

enum WEAPON {
	none,
	pistol,
	shotgun
}

var weapon_stack: Array = [WEAPON.none, WEAPON.pistol];
var weapon_variation: int = 0;

var current_weapon: int = WEAPON.none;
var new_weapon: int = WEAPON.none;

var weapon_change_time: float = 0.1;

var assets = [
	preload("res://Assets/Objects/Player/Viewmodels/SC_Viewmodel_None.tscn"),
	preload("res://Assets/Objects/Player/Viewmodels/SC_Viewmodel_Pistol.tscn")
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
	
	change_weapon_timer.start(weapon_change_time);
	new_weapon = weapon;
	
	draw_weapon(false);

func set_new_weapon():

	$"../Weapon".get_node(node_name[current_weapon]).queue_free();
	
	var viewmodel_scene = assets[new_weapon];
	var viewmodel = viewmodel_scene.instantiate();
	# get new viewmodel control and set position
	$"../Weapon".call_deferred("add_child", viewmodel);
	
	current_weapon = new_weapon;
	
	call_deferred("draw_weapon", true);

func get_weapon():
	return current_weapon;

func draw_weapon(up: bool):
	var tween = create_tween();
	var weapon_canvas = $"../Weapon".get_node(node_name[current_weapon]).get_node("CanvasLayer").get_node("Control");
	#weapon_canvas.position = Vector2(0.0, 0.0);

	tween.tween_property(weapon_canvas, "position", Vector2(0.0, 128.0 if up == false else 0.0), 0.05).as_relative();

func _on_change_weapon_timer_timeout():
	set_new_weapon();
