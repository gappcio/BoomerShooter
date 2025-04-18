extends Control;
class_name HUD;

@onready var player: Player;
#@onready var pistol = $"../Player/Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol/ComponentWeapon";
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var label: Label = $CanvasLayer/Label
@onready var dash_bar: ProgressBar = $DashBar
@onready var health_bar: ProgressBar = $HealthBar
@onready var fx_rect: ColorRect = $FXRect
@onready var fx_rect_anim: AnimationPlayer = $FXRect/FXRectAnim

func _ready():
	player = get_tree().get_first_node_in_group("player");
	dash_bar.value = 100.0;

func hurt() -> void:
	fx_rect_anim.play("hurt");
	fx_rect_anim.seek(0.0);

func _process(delta):

	if is_instance_valid(player):
		health_bar.value = player.health.health;
		dash_bar.value = player.dash_cooldown / player.dash_cooldown_base * 100.0;
	
	#var viewmodel = player.get_node("Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol");
	
	#pistol = $"../Player/Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol/ComponentWeapon";
	#
	#if is_instance_valid(pistol):
		#label.text = "buffer: " + str(pistol.shoot_buffer)\
		#+ "\n"\
		#+ "buffer: " + str(pistol.is_shooting);

	#if is_instance_valid(player):
		#label.text = "tilt: " + str(player.crouchjump_buffer)

	#if is_instance_valid(player):
		#label.text = \
			#"velocity.x: " + str("%.2f" % float(player.velocity.x))\
			#+ "\n" + \
			#"velocity.y: " + str("%.2f" % float(player.velocity.y))\
			#+ "\n" + \
			#"velocity.z: " + str("%.2f" % float(player.velocity.z))\
			#+ "\n" + \
			#"global_position.x: " + str("%.2f" % float(player.global_position.x))\
			#+ "\n" + \
			#"global_position.y: " + str("%.2f" % float(player.global_position.y))\
			#+ "\n" + \
			#"global_position.z: " + str("%.2f" % float(player.global_position.z))\
			#+ "\n" + \
			#"head.rot.x: " + str("%.2f" % float(player.head.rotation.x))\
			#+ "\n" + \
			#"head.rot.y: " + str("%.2f" % float(player.head.rotation.y))\
			#+ "\n" + \
			#"head.rot.z: " + str("%.2f" % float(player.head.rotation.z))\
			#+ "\n" + \
			#"camera.rot.x: " + str("%.2f" % float(player.camera.rotation.x))\
			#+ "\n" + \
			#"camera.rot.y: " + str("%.2f" % float(player.camera.rotation.y))\
			#+ "\n" + \
			#"camera.rot.z: " + str("%.2f" % float(player.camera.rotation.z))
	if Autoload.debug_mode:
		if is_instance_valid(player):
			var player_speed: float = Vector2(player.velocity.x, player.velocity.z).length();
			var rate = player_speed / player.MAX_SPEED;
			var deccel = player.DECCEL_AIR * rate * .35;
			label.text = "camera.y: " + str(player_speed);
			label.text = \
				"velocity.x: " + str("%.2f" % float(player.get_real_velocity().x))\
				+ "\n" + \
				"velocity.y: " + str("%.2f" % float(player.get_real_velocity().y))\
				+ "\n" + \
				"velocity.z: " + str("%.2f" % float(player.get_real_velocity().z))\
				+ "\n" + \
				"speed: " + str("%.2f" % float(Vector2(player.velocity.x, player.velocity.z).length()))\
				+ "\n" + \
				"gravity: " + str(player.gravity)\
				+ "\n" + \
				"accel: " + str(player.accel)\
				+ "\n" + \
				"deccel: " + str(player.deccel)\
				+ "\n" + \
				"input_dir: " + str(player.input_dir)\
				+ "\n"
