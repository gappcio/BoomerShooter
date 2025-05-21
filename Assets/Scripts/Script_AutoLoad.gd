extends Node

var debug_mode: bool = false;

var FX_HITPARTICLE = preload("res://Assets/Objects/World/Particles/SC_HitParticles.tscn");
var FX_HITPARTICLE2 = preload("res://Assets/Objects/World/Particles/SC_HitParticles2.tscn");
var FX_BULLETHOLE = preload("res://Assets/Objects/World/SC_BulletHole.tscn");
var FX_BULLET_TRACER = preload("res://Assets/Objects/World/Particles/SC_BulletTracer.tscn");
var FX_BULLET_HIT_PARTICLE = preload("res://Assets/Objects/World/Particles/SC_BulletHitParticles.tscn");

var FX_GORE1 = preload("res://Assets/Objects/World/Particles/SC_GoreParticles.tscn");
var FX_BLOOD1 = preload("res://Assets/Objects/World/Particles/SC_BloodParticles.tscn");

var random = RandomNumberGenerator.new();
var random_texture_offset: float = 0.0;
var random_dir: int = 1;
var random_dir_list: Array = [-1, 1];

signal player_landed;

func _ready():
	random.seed = hash("spucha");
	
func _process(delta):
	random_texture_offset = random.randf_range(0, 1);
	random_dir = random_dir_list[randi() % random_dir_list.size()];
