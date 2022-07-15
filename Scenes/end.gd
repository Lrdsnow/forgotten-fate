extends Control

func _ready():
	var world = get_node_or_null("/root/World")
	if world != null:
		world.queue_free()
	$Label.rect_size = get_viewport().size

func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().quit()
