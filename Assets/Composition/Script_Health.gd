extends Node

@export var max_health: int;
var health: int;

signal has_died;

func _ready():
	pass


func _process(delta):
	
	if health <= 0:
		health = 0;
		die();

func health_init():
	health = max_health;
	
func health_get():
	return health;

func health_set(new_health):
	health = new_health;
	
func hurt(damage):
	health_set(health - damage);
	
func die():
	has_died.emit();
