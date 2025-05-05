extends Node

@export var max_health: float;
@export var invis_seconds: float;

var health: float = 1.0;
var flux: bool = false;
var flux_damage: float;


var invis_frame: float;
var is_invis: bool = false;

signal has_died;

func _ready():
	invis_frame = invis_seconds;

func _process(delta):
	
	if health <= 0.0:
		health = 0.0;
		die();
	
	if is_invis:
		invis_frame -= delta;
	else:
		invis_frame = invis_seconds;
	
	if invis_frame <= 0.0:
		invis_frame = invis_seconds;
		is_invis = false;
	
	if flux:
		hurt(flux_damage);

func health_init():
	health = max_health;

func health_get():
	return health;

func health_set(new_health):
	health = new_health;

func hurt(damage):
	if !is_invis:
		health_set(health - damage);
	is_invis = true;

func hurtflux(damage):
	flux = true;
	flux_damage = damage;

func flux_end():
	flux = false;

func die():
	has_died.emit();
