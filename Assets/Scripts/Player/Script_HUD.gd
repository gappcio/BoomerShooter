extends CanvasLayer;
class_name hud;

@onready var label = $Label;
@onready var player = $"../Player";
#@onready var pistol = $"../Player/Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol/ComponentWeapon";

func _ready():
	pass

func _process(delta):
	pass
	#var viewmodel = player.get_node("Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol");
	
	#pistol = $"../Player/Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol/ComponentWeapon";
	#
	#if is_instance_valid(pistol):
		#label.text = "buffer: " + str(pistol.shoot_buffer)\
		#+ "\n"\
		#+ "buffer: " + str(pistol.is_shooting);

	if is_instance_valid(player):
		label.text = "tilt: " + str(player.input_dir)

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
	#if is_instance_valid(player):
		#var player_speed: float = Vector2(player.velocity.x, player.velocity.z).length();
		#label.text = "camera.y: " + str(player_speed);
		#if is_instance_valid(viewmodel):
			#label.text = \
				#"velocity.x: " + str("%.2f" % float(player.velocity.x))\
				#+ "\n" + \
				#"velocity.y: " + str("%.2f" % float(player.velocity.y))\
				#+ "\n" + \
				#"velocity.z: " + str("%.2f" % float(player.velocity.z))\
				#+ "\n" + \
				#"speed: " + str("%.2f" % float(Vector2(player.velocity.x, player.velocity.z).length()))\
				#+ "\n";
