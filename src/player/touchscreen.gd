extends Button

func _ready():
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		hide()
