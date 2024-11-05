extends Area3D

@export var health: Node;

signal been_hit;

func _ready():
	pass 

func _process(delta):
	pass

func hurt(collision_point, collision_normal, damage_amount):
	health.hurt(damage_amount);
	been_hit.emit(collision_point, collision_normal);
