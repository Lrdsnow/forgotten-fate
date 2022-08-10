extends Node3D

signal collide

var door_globals = []

func _on_room_area_entered(area):
	print("COLLIDING AREA:"+str(area.get_node("..").name))
	emit_signal("collide", area)
