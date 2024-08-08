extends GPUParticles3D
class_name hit_particles

func _ready():
	
	emitting = true;

func _on_finished():
	
	queue_free();

func apply_texture(texture):
	
	var mat = self.draw_pass_1.surface_get_material(0);
	var _mat = mat.duplicate();
	self.draw_pass_1.surface_set_material(0, _mat);
	
	_mat.set_texture(0, texture);
	_mat.set_uv1_offset(Vector3(Autoload.random_texture_offset, Autoload.random_texture_offset, 1));
