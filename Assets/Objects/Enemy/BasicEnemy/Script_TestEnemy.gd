extends CharacterBody3D
class_name BasicEnemy

@export var health: Node;
@export var hitbox: Area3D;

@onready var label: Label3D = $Label3D;
@onready var nav: NavigationAgent3D = $NavigationAgent3D;
@onready var hurt_timer: Timer = $TimerHurt;
@onready var ragdoll: PhysicalBoneSimulator3D = $Model/enemy_model_2/metarig/Skeleton3D/PhysicalBoneSimulator3D
@onready var collision: CollisionShape3D = $Collision
@onready var collision_shape_3d: CollisionShape3D = $ComponentHitbox/CollisionShape3D

@export_group("Collision Bones")
@export var bone_head: PhysicalBone3D;
@export var bone_body: PhysicalBone3D;
@export var bone_upper_arm_left: PhysicalBone3D;
@export var bone_lower_arm_left: PhysicalBone3D;
@export var bone_upper_arm_right: PhysicalBone3D;
@export var bone_lower_arm_right: PhysicalBone3D;
@export var bone_thigh_left: PhysicalBone3D;
@export var bone_thigh_right: PhysicalBone3D;
@export var bone_shin_left: PhysicalBone3D;
@export var bone_shin_right: PhysicalBone3D;
@export var bone_foot_left: PhysicalBone3D;
@export var bone_foot_right: PhysicalBone3D;

const BASE_SPEED: float = 3.0;
const JUMP_VELOCITY: float = 4.5;

const MAX_SPEED: float = 20.0;
const MAX_ACCEL: float = 4.0 * MAX_SPEED;

const ACCEL_GROUND: float = 0.5;
const ACCEL_AIR: float = 0.2;
const DECCEL_GROUND: float = 0.3;
const DECCEL_AIR: float = 0.2;
var GRAVITY_BASE: float = ProjectSettings.get_setting("physics/3d/default_gravity");

var gravity: float = GRAVITY_BASE;
var speed: float = BASE_SPEED;

var accel: float = 0.0;
var deccel: float = 0.0;

var player_node: Player;

var force: bool = false;

enum STATE {
	idle,
	chasing,
	hurt,
	dead
}

var state = STATE.chasing;

func _ready():
	player_node = get_tree().get_nodes_in_group("player")[0];
	health.health_init();
	ragdoll.active = false;
	#ragdoll.physical_bones_stop_simulation();

func _process(delta):
	label.text = str(health.health_get());
	
	match(state):
		STATE.idle:
			pass;
		STATE.chasing:
			nav.set_target_position(player_node.global_transform.origin);
			var nav_next = nav.get_next_path_position();
			velocity = (nav_next - global_transform.origin).normalized() * BASE_SPEED;
			
			
			var dir = global_position.direction_to(player_node.global_transform.origin);
			var target_rotation = Basis.looking_at(-dir);
			basis = basis.slerp(target_rotation, 0.1);
			rotation.x = 0.0;
			rotation.z = 0.0;
		STATE.hurt:
			velocity.x = lerp(velocity.x, 0.0, 0.1);
			velocity.z = lerp(velocity.z, 0.0, 0.1);
		STATE.dead:
			velocity.x = lerp(velocity.x, 0.0, 0.1);
			velocity.z = lerp(velocity.z, 0.0, 0.1);
	
	gravity = GRAVITY_BASE;
	velocity.y -= gravity * delta;
	
	
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
		
	var fx_blood = Autoload.FX_BLOOD1.instantiate();
	get_tree().current_scene.add_child(fx_blood);
	
	fx_blood.global_position = collision_point + (collision_normal / 10);
	
	
func die():
	state = STATE.dead;
	ragdoll.active = true;
	ragdoll.physical_bones_start_simulation();
	
	if !force:
		var _player = get_tree().get_nodes_in_group("player")[0];
		
		var dir = _player.head.rotation.y;
		var knockback = Vector3(sin(dir), 0.0, cos(dir));
		
		if is_instance_valid(_player):
			bone_body.linear_velocity = -knockback * 6.0;
			
			force = true;
	
	#bone_body.linear_velocity.x = lerp(bone_body.linear_velocity.x, 0.0, 0.015);
	#bone_body.linear_velocity.z = lerp(bone_body.linear_velocity.z, 0.0, 0.015);
	
	set_collision_layer_value(3, false);
	set_collision_mask_value(2, false);
	set_collision_mask_value(3, false);
	
	hitbox.set_collision_layer_value(3, false);
	hitbox.set_collision_mask_value(2, false);
	hitbox.set_collision_mask_value(3, false);


func _on_component_health_has_died():
	die();

func _on_component_hitbox_been_hit(collision_point, collision_normal):
	hurt(collision_point, collision_normal);


func _on_timer_hurt_timeout() -> void:
	state = STATE.chasing;
	var blood_decal = Autoload.FX_BLOOD_DECAL.instantiate();
	get_tree().current_scene.add_child(blood_decal);
	
	blood_decal.global_position = bone_foot_left.global_position + Vector3(randf_range(-0.5, 0.5), -0.1, randf_range(-0.5, 0.5));
