extends Node3D

var decal_scale: float = 0.1;
var alpha: float = 1.0;

@onready var decal: MeshInstance3D = $Decal;

func _process(delta: float) -> void:
	decal_scale += 0.005;
	
	decal.mesh.top_radius = decal_scale;
	decal.mesh.bottom_radius = decal_scale;
	#decal.mesh.material = Color(1.0, 1.0, 1.0, alpha);
	
	if decal_scale >= 2.0:
		alpha -= 0.005;
		
	if alpha <= 0.0:
		queue_free();
		
