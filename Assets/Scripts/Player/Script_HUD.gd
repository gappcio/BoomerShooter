extends CanvasLayer;
class_name hud;

@onready var label = $Label;
@onready var player = $"../Player";
#@onready var pistol = $"../Player/Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol";

func _ready():
	pass

func _process(delta):
	pass
	#var viewmodel = player.get_node("Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol");
	
	#pistol = $"../Player/Head/Camera/WeaponAttach/ViewmodelControl/Weapon/VIEWMODEL_Pistol";
	
	if is_instance_valid(player):
		
		
		
		label.text = "state: " + str(player.camera_bob_time);
	
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
