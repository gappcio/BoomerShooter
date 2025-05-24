extends CharacterBody3D
class_name Player

@onready var head := $Head;
@onready var camera := $Head/Camera;
@onready var weapon_attach := $Head/Camera/WeaponAttach;
@onready var weapon_viewmodel_node := $Head/Camera/WeaponAttach/ViewmodelControl/Weapon;
@onready var ceiling_detection: ShapeCast3D = $CeilingDetection
@onready var raycast: RayCast3D = $Head/Camera/Raycast

@onready var hitbox: Area3D = $ComponentHitbox
@onready var health: Node = $ComponentHealth

@onready var vault_node: Node3D = $Vault
@onready var vault_check: Area3D = $Vault/VaultCheck
@onready var vault_raycast: RayCast3D = $Vault/VaultRaycast
@onready var vault_raycast_top: RayCast3D = $Vault/VaultRaycastTop

@onready var step: Node3D = $Step
@onready var step_below_raycast: RayCast3D = $Step/StepBelowRaycast
@onready var step_ahead_raycast: RayCast3D = $Step/StepAheadRaycast

@onready var audio_dash: AudioStreamPlayer3D = $AudioDash
@onready var muzzle_point: Node3D = $Head/Camera/WeaponAttach/MuzzlePoint

var visual_helper = preload("res://Assets/Objects/Player/VisualHelper.tscn");
var player_visual_helper = preload("res://Assets/Objects/Player/VisualHelperPlayer.tscn");

const BASE_SPEED: float = 5.5;
const JUMP_VELOCITY: float = 6.5;
var spd: float = 0.0;

const MAX_SPEED: float = 15.0;
const MAX_ACCEL: float = 2 * MAX_SPEED;

const ACCEL_GROUND: float = 0.25;
const ACCEL_AIR: float = 0.1;
const DECCEL_GROUND: float = 0.25;
const DECCEL_AIR: float = 0.25;

const DASH_POWER: float = 20.0;

const TRIMP_SPEED_THRESHOLD = 14.0;
const TRIMP_FORCE_MULTIPLIER = 1.2;
const TRIMP_SLOPE_MAX_ANGLE = 40.0;

var GRAVITY_BASE: float = ProjectSettings.get_setting("physics/3d/default_gravity");

var gravity: float = GRAVITY_BASE;
var speed: float = BASE_SPEED;

var grounded: bool = false;
var just_landed: bool = false;

var is_trimping: bool = false;

var mouse_sensitivity = 0.17;

var accel: float = 0.0;
var deccel: float = 0.0;

var is_falling: bool = false;
var is_jumping: bool = false;
var is_crouched: bool = false;
var is_sprinting: bool = false;

var jump_force: float = JUMP_VELOCITY;
var jump_trigger: bool = false;
var jump_buffer_max = 7.0;
var jump_buffer = 0.0;

var jump_accel: float = 0.4;
var jump_accel_max: float = 10.0;
var jump_accel_time: float = jump_accel_max;

var jump_time: float = 0.0;
var jump_time_max: float = 100.0;

var dash_time: float = 0.0;
var dash_time_max: float = 0.25;
var is_dashing: bool = false;

var dash_buffer_max: float = 5.0;
var dash_buffer: float = 0.0;

var dash_gravity_cancel: bool = false;
var dash_gravity_cancel_time_base: float = 0.25;
var dash_gravity_cancel_time: float = dash_gravity_cancel_time_base;

var post_dash_time_base: float = 1.0;
var post_dash_time: float = post_dash_time_base;

var dash_cooldown_base: float = 0.5;
var dash_cooldown: float = dash_cooldown_base;
var dash_cooldown_active: bool = false;

var longjump_window_time_base: float = 0.3;
var longjump_window_time: float = longjump_window_time_base;
var can_longjump: float = false;

var dash_head_dir: float;
var dash_direction: Vector3;

var coyote_time: float = 0.0;
var coyote_max: float = 8.0;

var mesh_instance;
var im_mesh;
var material;

var input_dir = 0;
var mouse_input: Vector2;

var step_up_top: bool = false;
var step_up_middle: bool = false;
var step_up_bottom: bool = false;

var crouchjump_buffer_max: float = 16.0;
var crouchjump_buffer: float = 0.0;

var can_climb_top: bool = false;
var can_climb_bottom: bool = false;

var vault_check_colliding: bool = false;
var vault_body;

var vault_visual_helper = [];

var is_vaulting: bool = false;
var vault_timer_max: float = 0.5;
var vault_timer: float = vault_timer_max;

var wish_dir;

func _ready():
	Engine.time_scale = 1.0;
	camera.fov = 90;
	health.health_init();
	vault_visual_helper.resize(100);


func _process(delta):
	
	if Input.is_action_just_pressed("debug_timescale"):
		if Engine.time_scale == 1.0:
			Engine.time_scale = 0.25;
		else:
			Engine.time_scale = 1.0;
	
	if health.flux:
		#print(health.invis_frame)
		if health.invis_frame == health.invis_seconds:
			hurt(0.0, 0.0);
			


func _physics_process(delta: float) -> void:
	
	if !is_dashing:
		input_dir = Input.get_vector("left", "right", "forward", "back").normalized();
	wish_dir = global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y);
	
	spd = Vector2(velocity.x, velocity.z).length();
	
	is_crouched = Input.is_action_pressed("crouch");
	is_sprinting = Input.is_action_pressed("sprint");
	
	is_falling = velocity.y < 0.0;
	
	#if Input.is_action_just_pressed("crouch") && grounded:
		#crouchjump_buffer = crouchjump_buffer_max;
	
	grounded_state();
	
	if is_crouched:
		if grounded:
			crouchjump_buffer -= 1.0;
			if crouchjump_buffer <= 0.0:
				crouchjump_buffer = 0.0;
			
			$Collision.disabled = true;
			$CollisionCrouch.disabled = false;
			head.position.y = lerp(head.position.y, -0.1, 0.3);
			weapon_viewmodel_node.position.y = lerp(weapon_viewmodel_node.position.y, 0.02, 0.1);
	else:
		if !ceiling_detection.is_colliding() && grounded:
			$Collision.disabled = false;
			$CollisionCrouch.disabled = true;
			head.position.y = lerp(head.position.y, 0.6, 0.3);
			weapon_viewmodel_node.position.y = lerp(weapon_viewmodel_node.position.y, 0.0, 0.1);
			crouchjump_buffer = 0.0;
		
		
	handle_jumping(delta);

	movement(input_dir, delta);
	
	#region trimping test
	
	if grounded:
		var floor_normal = get_floor_normal();
		var normal_angle = floor_normal.angle_to(Vector3.UP);
		var can_trimp = false;
		
		if normal_angle > deg_to_rad(TRIMP_SLOPE_MAX_ANGLE)\
		&& normal_angle < deg_to_rad(60.0):
			can_trimp = true;
		
		if can_trimp and spd > TRIMP_SPEED_THRESHOLD:
			var slope_dir = (Vector3.UP - floor_normal).normalized();
			var trimp_force = velocity.length() * TRIMP_FORCE_MULTIPLIER;
			var launch_vector = slope_dir * trimp_force;
			
			is_trimping = true;
			
			velocity.x *= 1.5;
			velocity.z *= 1.5;
			
			velocity.y = launch_vector.y

	#endregion
	
	vault();
	
	move_and_slide();
	
	look();
	
	if is_vaulting:
		vault_timer -= delta;
		if vault_timer <= 0.0:
			vault_timer = vault_timer_max;
			is_vaulting = false;
	
	if Autoload.debug_mode:
		var pos = position + Vector3(0.0, -0.85, 0.0);
		DebugDraw3D.draw_line(pos, pos + Vector3(velocity.x, 0.0, velocity.z), Color(1.0, 0.0, 1.0));
		DebugDraw3D.draw_line(pos, pos + Vector3(velocity.x, 0.0, 0.0), Color(1.0, 0.0, 0.0));
		DebugDraw3D.draw_line(pos, pos + Vector3(0.0, 0.0, velocity.z), Color(0.0, 0.0, 1.0));
		
	
	#DebugDraw3D.draw_cylinder_ab(pos, pos + Vector3(0.0, 0.01, 0.0), Vector2(velocity.x, velocity.y).length(), Color(0.0, 0.0, 1.0));


func grounded_state():
	
	if is_on_floor():
		if !grounded:
			Autoload.player_landed.emit();
		grounded = true;
		is_trimping = false;
		coyote_time = coyote_max;
	else:
		grounded = false;


func handle_jumping(delta: float):
	
	if !is_falling:
		if velocity.y < 2.0:
			# slow down during peak
			gravity = lerp(gravity, GRAVITY_BASE * 1.25, .25);
		else:
			# we are moving upward
			var vel: Vector2 = Vector2(velocity.x, velocity.z);
			if vel.length() >= TRIMP_SPEED_THRESHOLD:
				gravity = lerp(gravity, GRAVITY_BASE, .25);
			else:
				gravity = GRAVITY_BASE * 1.5;
	else:
		# we are falling!!!
		gravity = lerp(gravity, GRAVITY_BASE * 3, .25);
		
	var vel: Vector2 = Vector2(velocity.x, velocity.z);
	var rate = vel.length() / MAX_SPEED * .15;
	
	if vel.length() > 12.0:
		rate = 0.08;

	if grounded:
		accel = ACCEL_GROUND;
		deccel = DECCEL_GROUND;
		
		is_jumping = false;
		is_falling = false;
		jump_trigger = false;
	else:
		accel = ACCEL_AIR;
		
		if is_dashing:
			deccel = DECCEL_AIR;
		else:
			velocity.y -= gravity * delta;
			deccel = DECCEL_AIR * rate;
	
	if !jump_trigger:
		var add_force: float = 0.0;
		if spd > MAX_SPEED:
			add_force = 1.0;
		jump_force = (JUMP_VELOCITY * ((spd * .015) + 1)) + add_force;
	
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_max;
	
	if jump_buffer > 0:
		jump_buffer -= 1;
		
		if vault_raycast.is_colliding()\
		&& !vault_raycast_top.is_colliding():
			jump_buffer = 0.0;
			grounded = false;
			is_vaulting = true;
			velocity.y = jump_force;
		
		if (!jump_trigger && grounded):
			jump_trigger = true;
			jump_accel_time = jump_accel_max;
	
	if !grounded:
		
		if coyote_time > 0.0:
			coyote_time -= 1.0;
			
			if Input.is_action_just_pressed("jump") && !jump_trigger:
				jump_trigger = true;
				jump_accel_time = jump_accel_max;
	
	if jump_trigger:
		if jump_accel_time <= 0.0:
			jump_accel_time = 0.0;
		else:
			jump_accel_time -= 1.0;
			
	if jump_trigger:
		if jump_accel_time > 0.0 && jump_accel_time < jump_accel_max:
			velocity.y = lerp(velocity.y, jump_force, jump_accel);
		
	if Input.is_action_just_released("jump"):
		if jump_trigger && !grounded:
			velocity.y *= 0.8;
			jump_accel_time = 0.0;


func movement(input_dir: Vector2, delta: float) -> void:

	var rot = 0.0;
	rot = -head.rotation.y;
	
	var direction = input_dir;
	direction = direction.rotated(rot);
	direction = Vector3(direction.x, 0.0, direction.y);
	
	#region step up
	
	#step.rotation.y = direction.angle_to(Vector3.UP)
	#
	#if step_ahead_raycast.is_colliding() && step_below_raycast.is_colliding():
		#if spd > 0.0:
			#position.y = step_ahead_raycast.get_collision_point().y + 0.8;
	#
	#endregion
	
	
	if Input.is_action_just_pressed("sprint"):
		dash_buffer = dash_buffer_max;
		dash_head_dir = -head.rotation.y;
		dash_direction = direction;
		
		if dash_cooldown == 0.5:
			audio_dash.play();
		
	if dash_buffer > 0.0:
		dash_buffer -= 1.0;
		
		if !is_dashing && !dash_cooldown_active:
			is_dashing = true;
			dash_cooldown_active = true;
			dash_cooldown = 0.0;
			dash_gravity_cancel = true;
			can_longjump = true;
	
	if dash_gravity_cancel:
		dash_gravity_cancel_time -= delta;
		if dash_gravity_cancel_time <= 0.0:
			dash_gravity_cancel_time = dash_gravity_cancel_time_base;
			dash_gravity_cancel = false;
	
	if !is_dashing:
		post_dash_time -= delta;
		if post_dash_time <= 0.0:
			post_dash_time = post_dash_time_base;
			
	
	if dash_cooldown_active:
		dash_cooldown += delta;
		if dash_cooldown >= dash_cooldown_base:
			dash_cooldown = dash_cooldown_base;
			dash_cooldown_active = false;
	
	
	if is_dashing:
			

		if input_dir == Vector2(0.0, 0.0):
			velocity.x = (DASH_POWER * cos(dash_head_dir - PI/2));
			velocity.z = (DASH_POWER * sin(dash_head_dir - PI/2));
		else:
			velocity.x = (DASH_POWER * dash_direction.x);
			velocity.z = (DASH_POWER * dash_direction.z);
		
		
		if dash_time > dash_time_max:
			dash_time = 0.0;
			is_dashing = false;
			longjump_window_time = longjump_window_time_base;
			
			if !is_trimping:
				velocity.z *= 0.4;
				velocity.x *= 0.4;
		else:
			dash_time += delta;
	
	
	if longjump_window_time <= 0.0:
		longjump_window_time = 0.0;
	else:
		longjump_window_time -= delta;
	
	if longjump_window_time > 0.0\
	&& longjump_window_time < longjump_window_time_base:
		can_longjump = true;
	else:
		can_longjump = false;
	
	
	if direction:
		var vel: Vector3;
		
		if is_dashing:
			vel = accelerate(velocity, dash_direction, delta);
			velocity.x = lerp(vel[0], dash_direction.x * BASE_SPEED, accel);
			velocity.z = lerp(vel[2], dash_direction.z * BASE_SPEED, accel);
		else:
			vel = accelerate(velocity, direction, delta);
			velocity.x = lerp(vel[0], direction.x * BASE_SPEED, accel);
			velocity.z = lerp(vel[2], direction.z * BASE_SPEED, accel);
			
		camera.camera_bobbing(velocity, delta);
		
	else:
		velocity.x = lerp(velocity.x, 0.0, deccel);
		velocity.z = lerp(velocity.z, 0.0, deccel);
		
		camera.camera_bobbing_reset();
	
	if Autoload.debug_mode:
		var pos = position + Vector3(0.0, -0.85, 0.0);
		#DebugDraw3D.draw_line(pos, pos + Vector3(cos(-head.global_rotation.y - PI/2), 0.0, sin(-head.global_rotation.y - PI/2)), Color(0.0, 1.0, 0.0));
		DebugDraw3D.draw_line(pos, pos + Vector3(direction.x, 0.0, direction.z), Color(1.0, 1.0, 1.0));


func accelerate(velocity: Vector3, move_direction: Vector3, delta: float) -> Vector3:
	
	velocity = lerp(velocity, Vector3(0.0, 0.0, 0.0), delta);
	
	var current_speed = velocity.dot(move_direction);
	var add_speed = clamp(MAX_SPEED - current_speed, 0.0, MAX_ACCEL * delta);
	
	
	return velocity + add_speed * move_direction;


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			#mouse_input.x += event.relative.x;
			#mouse_input.y += event.relative.y;
			var viewport_transform: Transform2D = get_tree().root.get_final_transform();
			mouse_input = event.xformed_by(viewport_transform).relative;


func look() -> void:
	
	head.rotation_degrees.x -= mouse_input.y * mouse_sensitivity;
	head.rotation_degrees.y -= mouse_input.x * mouse_sensitivity;
	#rotate_y(deg_to_rad(-mouse_input.x * mouse_sensitivity));
	
	#motion = Vector2(0.0, 0.0);
	mouse_input = Vector2(0.0, 0.0);
	
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89.99), deg_to_rad(89.99));


func vault() -> void:
	
	vault_node.rotation.y = head.rotation.y;
	#vault_check.rotation.y = head.rotation.y;
	#vault_raycast.rotation.y = head.rotation.y;
	
	var body = vault_raycast.get_collider();
	
	if vault_check_colliding:
		if body == vault_body:
			
			if vault_raycast_top.get_collider() == null:
				pass
				# disable movement
				
				# play animation
			
				# at the end teleport (where???)
				# enable movement
				
				
				#for i in range(0, 2, 0.25):
					#var offset = Vector3(0.0, i, 0.0);
					#test_move(transform, velocity + offset)
			#
			#if !is_instance_valid(vault_visual_helper[0]):
				#vault_visual_helper[0] = visual_helper.instantiate();
				#self.add_child(vault_visual_helper[0]);
				#vault_visual_helper[0].global_position = vault_raycast.get_collision_point();
			#else:
				#vault_visual_helper[0].global_position = vault_raycast.get_collision_point();
				#
			#if !is_instance_valid(vault_visual_helper[1]):
				#vault_visual_helper[1] = visual_helper.instantiate();
				#self.add_child(vault_visual_helper[1]);
				#vault_visual_helper[1].global_position = vault_raycast_top.get_collision_point();
			#else:
				#vault_visual_helper[1].global_position = vault_raycast_top.get_collision_point();
				#
		#else:
			#if is_instance_valid(vault_visual_helper[0]):
				#vault_visual_helper[0].queue_free();


func land_anim() -> void:
	var tween = create_tween().set_parallel();
	var offset = -0.2;
	tween.tween_property(head, "position", Vector3(0.0, offset, 0.0), 0.05).as_relative();
	tween.chain().tween_property(head, "position", Vector3(0.0, -offset, 0.0), 0.1).as_relative();


func hurt(collision_point, collision_normal):
	var hud = get_tree().get_first_node_in_group("hud");
	hud.hurt();


func _on_component_hitbox_area_entered(area: Area3D) -> void:
	var body = area.get_parent();
	if body != null && body.is_in_group("hurtarea"):
		health.hurtflux(body.damage);


func _on_component_hitbox_area_exited(area: Area3D) -> void:
	var body = area.get_parent();
	if body != null && body.is_in_group("hurtarea"):
		health.flux_end();


func _on_vault_check_body_entered(body: Node3D) -> void:
	if body.is_in_group("wall"):
		vault_check_colliding = true;
		vault_body = body;


func _on_vault_check_body_exited(body: Node3D) -> void:
	if body.is_in_group("wall"):
		vault_check_colliding = false;
		vault_body = null;
