extends Decal

var decal_scale: float = 0.1;
var alpha: float = 1.0;

func _process(delta: float) -> void:
	decal_scale += 0.005;
	
	size = Vector3(decal_scale, 0.1, decal_scale);
	modulate = Color(1.0, 1.0, 1.0, alpha);
	
	if decal_scale >= 2.0:
		alpha -= 0.005;
		
	if alpha <= 0.0:
		queue_free();
		
