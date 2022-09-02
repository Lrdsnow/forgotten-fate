extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_nurse_killzone_body_entered(body):
	if body.name == "Player":
		if Global.can_move:
			Global.health = 0
