extends Node3D

signal unload

func load_stairs(): 
	var stairs = load("res://src/rooms/story/story_stairs.tscn").instantiate()
	add_child(stairs)
	await unload
	$base_room.queue_free()
	$room_doors.queue_free()
	$room_items.queue_free()
