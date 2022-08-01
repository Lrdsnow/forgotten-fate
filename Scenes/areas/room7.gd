extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Playerglobal.chapter = "Chapter 1"
	Playerglobal.room = "Room 7 (Debug)"
	Playerglobal.update_activity()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
