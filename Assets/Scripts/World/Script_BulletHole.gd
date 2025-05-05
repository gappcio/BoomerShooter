extends Decal
class_name bullet_hole_decal

@onready var tex = $Texture;
var time = 1.0;

func _ready():
	self.texture_albedo = tex.texture;
	
func _process(delta):
	
	time -= delta;
	if time <= 0.0:
		self.albedo_mix -= delta;
		
		if albedo_mix <= 0.0:
			queue_free();
