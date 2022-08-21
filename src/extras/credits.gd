extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			get_tree().quit()
		#for child in get_node("/root").get_children():
		#	if child.name != "Game" and child.name != "credits":
		#		child.queue_free()
		#var node = Node.new()
		#var global = load("res://src/global.gd")
		#node.set_script(global)
		#node.name = "Global"
		#get_node("/root").add_child(node)
		#get_tree().change_scene("res://menu.tscn")
