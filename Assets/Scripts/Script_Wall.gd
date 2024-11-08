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
	
	#print(collision_point)
	#print(collision_normal)
	#print(decal.global_transform.origin)

	#if collision_normal.dot(Vector3.UP) > 0.001:
	if collision_normal.y == 0:
		fx.look_at(-collision_normal, Vector3.ONE);
		decal.look_at(collision_point + collision_normal, Vector3.UP);
		
	fx.apply_texture(texture);
	
	if collision_normal != Vector3.UP && collision_normal != Vector3.DOWN:
		decal.rotate_object_local(Vector3.LEFT, 90);
	#decal.global_rotation = collision_normal;
	#print(decal.global_rotation_degrees)
