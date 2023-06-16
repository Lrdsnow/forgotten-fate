extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("setup")

func setup():
	Global.player.stats.ammo_clip = 9999999999999
	Global.player.stats.ammo = 999
	Game.set_held_item("AK") # Sets Gun To The Unused AK-47
	Game.replace_questline([{
	"name":"Kill Everyone",
	"map":"player-training",
	"segments":[{
		"name":"Kill Everyone",
		"color":"blue",
		"orb":false,
		"type":"kill"
	}]}])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
