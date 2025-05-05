extends Node3D
class_name wall

@onready var texture_node = $Texture;



func on_hit(collision_point, collision_normal):
	
	var texture = texture_node.texture;
	
	var fx = Autoload.FX_HITPARTICLE.instantiate();
	get_tree().current_scene.add_child(fx);
	
	var decal = Autoload.FX_BULLETHOLE.instantiate();
	get_tree().current_scene.add_child(decal);
	
	fx.global_position = collision_point + (collision_normal / 10);
	decal.global_position = collision_point;
	
	fx.look_at(fx.global_position + collision_normal, Vector3.UP);
	fx.rotate_object_local(Vector3.RIGHT, -PI/2);
	
	fx.apply_texture(texture);
	
	decal.look_at(decal.global_position + collision_normal, Vector3.UP);
	decal.rotate_object_local(Vector3.RIGHT, -PI/2);
