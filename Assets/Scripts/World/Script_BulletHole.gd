extends Decal
class_name bullet_hole_decal

@onready var tex = $Texture;
@onready var timer = $Timer;

func _ready():
	
	self.texture_albedo = tex.texture;
	timer.start();
	
func _process(delta):
	
	if timer.is_stopped():
		self.albedo_mix -= delta;
		
		if albedo_mix <= 0.0:
			queue_free();
