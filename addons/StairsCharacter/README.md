# Stairs Character 3D

A simple class based on Godot's default CharacterBody3D with very simple stair stepping ability.
Just call "move_and_stair_step()" instead of "move_and_slide()".

Only tested with cylinder colliders. Works best with "0.01" collider margin.

There are a couple signals you can connect to:
- on_stair_step (any step, up or down)
- on_stair_step_down
- on_stair_step_up

Example usage:
```gdscript

extends StairsCharacter3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# call move_and_stair_step instead of default move_and_slide
	move_and_stair_step()
```

# Note
This plugin is basically just [Andricraft's GDScript Stairs Character](https://github.com/Andicraft/stairs-character) translated into C++.
I made it as a learning exercise for GDExtension.
