extends Node3D

@export var test:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if test:
		Game.replace_questline([{
		"name":"Test",
		"map":"unknown",
		"segments":[{
			"name":"Unknown Test",
			"color":"blue",
			"orb":false,
			"type":"kill"
		}]}])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
