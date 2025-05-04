extends CharacterBody3D
class_name BasicEnemy

@export var health: Node;
@export var hitbox: Area3D;

@onready var label: Label3D = $Label3D;
@onready var nav: NavigationAgent3D = $NavigationAgent3D;
@onready var hurt_timer: Timer = $TimerHurt;

const BASE_SPEED: float = 2.0;
const JUMP_VELOCITY: float = 4.5;

const MAX_SPEED: float = 20.0;
const MAX_ACCEL: float = 4 * MAX_SPEED;

const ACCEL_GROUND: float = 0.5;
const ACCEL_AIR: float = 0.2;
const DECCEL_GROUND: float = 0.3;
const DECCEL_AIR: float = 0.2;
var GRAVITY_BASE: float = ProjectSettings.get_setting("physics/3d/default_gravity");

var gravity: float = GRAVITY_BASE;
var speed: float = BASE_SPEED;

var accel: float = 0.0;
var deccel: float = 0.0;

enum STATE {
	idle,
	chasing,
	hurt
}

var state = STATE.chasing;

func _ready():
	health.health_init();

func _process(delta):
	label.text = str(health.health_get());
	
	if hurt_timer.is_stopped():
		state = STATE.chasing;
		
	var _player = get_tree().get_nodes_in_group("player")[0];

	nav.set_target_position(_player.global_transform.origin);
	var nav_next = nav.get_next_path_position();
	
	
	match(state):
		STATE.idle:
			pass;
		STATE.chasing:
			velocity = (nav_next - global_transform.origin).normalized() * BASE_SPEED;
			#look_at(Vector3(_player.global_position.x, _player.global_position.y, _player.global_position.z), Vector3.UP);
		STATE.hurt:
			velocity.x = lerp(velocity.x, 0.0, 0.1);
			velocity.z = lerp(velocity.z, 0.0, 0.1);
	
	move_and_slide();

func hurt(collision_point, collision_normal):
	
	hurt_timer.start(1.0);
	state = STATE.hurt;

	var _player = get_tree().get_nodes_in_group("player")[0];
	
	var dir = _player.head.rotation.y;
	var knockback = Vector3(sin(dir), 0.0, cos(dir));
	
	if is_instance_valid(_player):
		velocity = -knockback * 2;
		
	#var texture = texture_node.texture;
	
	var fx = Autoload.FX_GORE1.instantiate();
	get_tree().current_scene.add_child(fx);
	
	fx.global_position = collision_point + (collision_normal / 10);
	
	if collision_normal.y == 0:
		fx.look_at(-collision_normal, Vector3.ONE);
	
func die():
	queue_free();

func _on_component_health_has_died():
	die();

func _on_component_hitbox_been_hit(collision_point, collision_normal):
	hurt(collision_point, collision_normal);
