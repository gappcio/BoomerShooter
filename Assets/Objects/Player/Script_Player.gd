extends CharacterBody3D
class_name Player

@onready var head := $Head;
@onready var camera := $Head/Camera;
@onready var debug_arrow_velocity := $ArrowVelocityPivot;
@onready var weapon_attach := $Head/Camera/WeaponAttach;
@onready var weapon_viewmodel_node := $Head/Camera/WeaponAttach/ViewmodelControl/Weapon;
@onready var ceiling_detection: ShapeCast3D = $CeilingDetection
@onready var raycast: RayCast3D = $Head/Camera/Raycast

@onready var climb_area_top: Area3D = $Climb/ClimbAreaTop
@onready var climb_area_bottom: Area3D = $Climb/ClimbAreaBottom

@onready var hitbox: Area3D = $ComponentHitbox
@onready var health: Node = $ComponentHealth


const BASE_SPEED: float = 5.0;
const JUMP_VELOCITY: float = 4.75;
var spd: float = 0.0;

const MAX_SPEED: float = 15.0;
const MAX_ACCEL: float = 2 * MAX_SPEED;

const ACCEL_GROUND: float = 0.25;
const ACCEL_AIR: float = 0.04;
const DECCEL_GROUND: float = 0.25;
const DECCEL_AIR: float = 0.1;

const DASH_POWER: float = 20.0;

const TRIMP_SPEED_THRESHOLD = 15.0;
const TRIMP_FORCE_MULTIPLIER = 1.0;
const TRIMP_SLOPE_MAX_ANGLE = 40.0;

var GRAVITY_BASE: float = ProjectSettings.get_setting("physics/3d/default_gravity");

var gravity: float = GRAVITY_BASE;
var speed: float = BASE_SPEED;

var grounded: bool = false;

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
var dash_time_max: float = 0.025;
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

var camera_tilt: float;
var camera_bob_time: float = 0.0;

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


var wish_dir;

func _ready():
	Engine.time_scale = 1.0;
	camera.fov = 90;
	health.health_init();
	
func _process(delta):
	
	if Input.is_action_just_pressed("debug_timescale"):
		if Engine.time_scale == 1.0:
			Engine.time_scale = 0.5;
		else:
			Engine.time_scale = 1.0;
	
	
	
	var vec = Vector2(velocity.z, velocity.x);
	var l = vec.length();
	var r = vec.angle_to_point(Vector2(0, 1));

	debug_arrow_velocity.scale = Vector3(l, 1, l);
	debug_arrow_velocity.rotation = Vector3(0, r, 0);
	
	
	
	#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90));
	#camera.rotation.y = 0.0;
	#Draw.line(Vector3(position.x, 0, position.z), Vector3(position.x + velocity.x, 0, position.z + velocity.z), Color.BLACK, 1);

func _physics_process(delta: float) -> void:
	
	input_dir = Input.get_vector("left", "right", "forward", "back").normalized();
	wish_dir = global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y);
	
	if can_longjump && !grounded:
		input_dir = Vector2(0.0, 0.0);
	
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
			weapon_viewmodel_node.position.y = lerp(weapon_viewmodel_node.position.y, 0.05, 0.1);
	else:
		if !ceiling_detection.is_colliding() && grounded:
			$Collision.disabled = false;
			$CollisionCrouch.disabled = true;
			head.position.y = lerp(head.position.y, 0.6, 0.3);
			weapon_viewmodel_node.position.y = lerp(weapon_viewmodel_node.position.y, 0.0, 0.1);
			crouchjump_buffer = 0.0;
		
		
	#if grounded:
		#if Input.is_action_just_pressed("jump"):
			#velocity.y = jump_force;
		#movement(input_dir, delta);
	#else:
		#vertical_movement(delta);
		
	handle_jumping(delta);

	movement(input_dir, delta);
	
	#region trimping test
	
	#if dash_gravity_cancel:
		#gravity = 0.0;
	
	if grounded:
		var floor_normal = get_floor_normal();
		var normal_angle = floor_normal.angle_to(Vector3.UP);
		var can_trimp = normal_angle > deg_to_rad(TRIMP_SLOPE_MAX_ANGLE);
		
		if can_trimp and spd > TRIMP_SPEED_THRESHOLD:
			var slope_dir = (Vector3.UP - floor_normal).normalized();
			var trimp_force = velocity.length() * TRIMP_FORCE_MULTIPLIER;
			var launch_vector = slope_dir * trimp_force;
			
			velocity.x *= 1.1;
			velocity.z *= 1.1;
			
			velocity.y = 0.0;
			velocity.y += launch_vector.y

	#endregion
	
	move_and_slide();
	
	tilt_camera(input_dir);
	
	look();
	
	var pos = position + Vector3(0.0, -0.85, 0.0);
	DebugDraw3D.draw_line(pos, pos + Vector3(velocity.x, 0.0, velocity.z), Color(1.0, 0.0, 1.0));
	DebugDraw3D.draw_line(pos, pos + Vector3(velocity.x, 0.0, 0.0), Color(1.0, 0.0, 0.0));
	DebugDraw3D.draw_line(pos, pos + Vector3(0.0, 0.0, velocity.z), Color(0.0, 0.0, 1.0));
	
	
	#DebugDraw3D.draw_cylinder_ab(pos, pos + Vector3(0.0, 0.01, 0.0), Vector2(velocity.x, velocity.y).length(), Color(0.0, 0.0, 1.0));
	


func grounded_state():
	
	if is_on_floor():
		grounded = true;
		#if abs(get_real_velocity().y) < 3.0:
			#grounded = true;
	else:
		grounded = false;

func handle_jumping(delta: float):
	
	if !is_falling:
		if velocity.y < 2.0:
			# slow down during peak
			gravity = lerp(gravity, GRAVITY_BASE, .25);
		else:
			# we are moving upward
			var vel: Vector2 = Vector2(velocity.x, velocity.z);
			if vel.length() >= TRIMP_SPEED_THRESHOLD:
				gravity = lerp(gravity, GRAVITY_BASE * 0.75, .25);
			else:
				gravity = GRAVITY_BASE * 1.5;
	else:
		# we are falling!!!
		gravity = lerp(gravity, GRAVITY_BASE * 3, .25);
		
	var vel: Vector2 = Vector2(velocity.x, velocity.z);
	var rate = vel.length() / MAX_SPEED * .15;
		
	if grounded:
		accel = ACCEL_GROUND;
		deccel = DECCEL_GROUND;
		
		is_jumping = false;
		is_falling = false;
		jump_trigger = false;
	else:
		accel = ACCEL_AIR;
		if !can_longjump:
			deccel = DECCEL_AIR * rate;
		else:
			deccel = 0.0;

		if !is_dashing:
			velocity.y -= gravity * delta;
	
	if !jump_trigger:
		jump_force = JUMP_VELOCITY * ((abs(velocity.x) * .0015) + 1);
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_max;
	
	if jump_buffer > 0:
		jump_buffer -= 1;
		
		if (!jump_trigger && grounded):
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
	
	
	#if velocity.y > 1.0:
		#var _set = func(): crouchjump_buffer = 0.0;
		#_set.call_deferred();

func vertical_movement(delta: float):
	velocity.y -= GRAVITY_BASE * delta;
	
	var current_wish_dir_speed = velocity.dot(wish_dir);
	var capped_speed = min( (500.0 * wish_dir).length(),  0.85);
	
	var add_speed = capped_speed - current_wish_dir_speed;
	if add_speed > 0:
		var accel_speed = 800 * 500 * delta;
		accel_speed = min(accel_speed, add_speed);
		velocity += accel_speed * wish_dir;
		
	if is_on_wall():
		if get_wall_normal().angle_to(Vector3.UP) > floor_max_angle:
			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING;
		else:
			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
		clip_velocity(get_wall_normal(), 1, delta);
		
	if Input.is_action_just_pressed("sprint"):
		velocity *= Vector3(4.0, 1.0, 4.0);

func movement(input_dir: Vector2, delta: float) -> void:

	var direction = input_dir.rotated(-head.rotation.y);
	direction = Vector3(direction.x, 0.0, direction.y);
	
	spd = Vector2(velocity.x, velocity.z).length();
	
	#var wish_dir_speed = velocity.dot(wish_dir);
	#var add_speed = BASE_SPEED - wish_dir_speed;
	#if add_speed > 0.0:
		#var accel_speed = 11 * delta * BASE_SPEED;
		#accel_speed = min(accel_speed, add_speed);
		#velocity += accel_speed * wish_dir;
		#
	#var control = max(velocity.length(), 7);
	#var drop = control * 3.5 * delta;
	#var new_speed = max(velocity.length() - drop, 0.0);
	#if velocity.length() > 0.0:
		#new_speed /= velocity.length();
	#velocity *= new_speed;


	if Input.is_action_just_pressed("sprint"):
		dash_buffer = dash_buffer_max;
		
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
	
	#print("input_dir: %v" % input_dir)
	#print(-head.global_rotation.y)
	
	
	if is_dashing:
			
		if input_dir == Vector2(0.0, 0.0):
			velocity.x = (DASH_POWER * cos(-head.global_rotation.y - PI/2));
			velocity.z = (DASH_POWER * sin(-head.global_rotation.y - PI/2));
		else:
			velocity.x = (DASH_POWER * direction.x);
			velocity.z = (DASH_POWER * direction.z);
		
		
		if dash_time > dash_time_max:
			dash_time = 0.0;
			is_dashing = false;
			longjump_window_time = longjump_window_time_base;
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
		vel = accelerate(velocity, direction, delta);

		velocity.x = lerp(vel[0], direction.x * BASE_SPEED, accel);
		velocity.z = lerp(vel[2], direction.z * BASE_SPEED, accel);
		
		camera_bobbing(velocity, delta);
		
	else:
		velocity.x = lerp(velocity.x, 0.0, deccel);
		velocity.z = lerp(velocity.z, 0.0, deccel);
		
		camera_bobbing_reset();
	
	var pos = position + Vector3(0.0, -0.85, 0.0);
	#DebugDraw3D.draw_line(pos, pos + Vector3(cos(-head.global_rotation.y - PI/2), 0.0, sin(-head.global_rotation.y - PI/2)), Color(0.0, 1.0, 0.0));
	DebugDraw3D.draw_line(pos, pos + Vector3(direction.x, 0.0, direction.z), Color(1.0, 1.0, 1.0));

func accelerate(velocity: Vector3, move_direction: Vector3, delta: float) -> Vector3:
	
	velocity = lerp(velocity, Vector3(0.0, 0.0, 0.0), delta);
	
	var current_speed = velocity.dot(move_direction);
	var add_speed = clamp(MAX_SPEED - current_speed, 0.0, MAX_ACCEL * delta);
	
	
	return velocity + add_speed * move_direction;

func clip_velocity(normal: Vector3, overbounce: float, _delta: float) -> void:
	
	var backoff = velocity.dot(normal) * overbounce;
	
	if backoff >= 0.0: return;
	
	var change = normal * backoff;
	velocity -= change;
	
	var adjust = velocity.dot(normal);
	if adjust < 0.0:
		velocity -= normal * adjust;

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

func tilt_camera(input_dir):
	
	var tilt_strength: float = input_dir.x / MAX_SPEED;
	camera_tilt = lerp(camera_tilt, tilt_strength, 0.1);
	
	if abs(camera_tilt) < 0.001:
		camera_tilt = 0.0;
		
	camera.rotation.z = camera_tilt;

func camera_bobbing(velocity, delta) -> void:
	
	var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z);
	
	camera_bob_time += delta * velocity_2d.length() * float(grounded);

	camera.position.y = lerp(camera.position.y, 0.1 * -sin(camera_bob_time * 1.2), 0.1);

func camera_bobbing_reset() -> void:
	
	if abs(camera.position.y) < 0.001:
		camera.position.y = 0.0;
		return;
	
	camera.position.y = lerp(camera.position.y, 0.0, 0.1);
	
	camera_bob_time = 0.0;

func camera_shake():
	
	var tween = create_tween().set_parallel();
	var fov_change = 2.0;
	var time = 0.01;
	var rotation_amount = 0.05;

	tween.tween_property(camera, "rotation", Vector3(0, 0, time * Autoload.random_dir), rotation_amount).as_relative();
	tween.chain().tween_property(camera, "rotation", Vector3(0, 0, -time * Autoload.random_dir), rotation_amount).as_relative();
	
	if camera.fov > 1.0 && camera.fov < 179.0:
		tween.tween_property(camera, "fov", fov_change, time).as_relative();
		tween.chain().tween_property(camera, "fov", -fov_change, time).as_relative();

func hurt(collision_point, collision_normal):
	pass



func _on_area_step_up_bottom_body_entered(body):
	pass
	
	if body.is_in_group("wall"):
		step_up_bottom = true;
		
		#if velocity.x != 0 || velocity.z != 0:
		var i = 0.0;
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
		
		#print(direction)

		while test_move(global_transform, Vector3(direction.x / 10, i, direction.z / 10)):
			#print(str(global_position.y) + "/" + str(global_position.y + i))
			
			if (i > 1.0):
				i = 0.0;
				break;
			else:
				i += 0.05;
				
		if velocity.y <= 0.0:
			global_position.y += i

func _on_area_step_up_bottom_body_exited(body):
	
	if body.is_in_group("wall"):
		step_up_bottom = false;

func _on_climb_area_top_area_entered(area: Area3D) -> void:
	if area.is_in_group("climbable"):
		can_climb_top = true;

func _on_climb_area_top_area_exited(area: Area3D) -> void:
	if area.is_in_group("climbable"):
		can_climb_top = false;

func _on_climb_area_bottom_area_entered(area: Area3D) -> void:
	if area.is_in_group("climbable"):
		can_climb_bottom = true;

func _on_climb_area_bottom_area_exited(area: Area3D) -> void:
	if area.is_in_group("climbable"):
		can_climb_bottom = false;


func _on_component_hitbox_been_hit(body) -> void:
	health.hurt(1.0);

func _on_component_hitbox_area_entered(area: Area3D) -> void:
	
	var body = area.get_parent();
	if body != null && body.is_in_group("hurtarea"):
		health.hurt(body.damage);


func _on_component_hitbox_area_exited(area: Area3D) -> void:
	pass
