extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$"../anim".play("float")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_anim_animation_finished(anim_name):
	$"../anim".play("float")
