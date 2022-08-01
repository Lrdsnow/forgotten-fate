extends Spatial

onready var pglobal = get_node("/root/Playerglobal")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var objname = ""
var key = false
var room2 = Playerglobal.room2

signal room2

# Called when the node enters the scene tree for the first time.
func _ready():
	$room/door/anim.play_backwards("open")
	Playerglobal.objects = ["key", "hidebed", 0, 0]
	$".."/".."/".."/Player.connect("interact", self, "_on_interact")
	$".."/".."/".."/Player.connect("door", self, "_on_door")
	reset()
	Playerglobal.chapter = "Chapter 1"
	Playerglobal.room = "Room 1"
	Playerglobal.discord_image = "chapter-1"
	Playerglobal.update_activity()
	#pass
#pglobal.interactible = ["key"]

func reset():
	$".."/room2/things/boxes.hide()
	$".."/room2/things/boxes/box_0/collision.disabled = true
	$".."/room2/things/boxes/box_1/collision.disabled = true
	$".."/room2/things/boxes/box_2/collision.disabled = true
	$".."/room2/things/boxes/box_3/collision.disabled = true
	$".."/room2/things/boxes/box_4/collision.disabled = true
	$".."/room2/things/boxes/box_5/collision.disabled = true
	$".."/room2/things/boxes/box_6/collision.disabled = true
	$".."/room2/things/boxes/box_7/collision.disabled = true
	$".."/room2/things/boxes/box_8/collision.disabled = true
	$".."/room2/things/boxes/box_9/collision.disabled = true
	$".."/room2/things/lamp4/lamplight.light_energy = 0.1

func _on_door():
	if key and not Playerglobal.room2:
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Open"
		if Input.is_action_just_pressed("interact"):
			$room/door/anim.play("open")
			print("Opened door")
			key = false
			Playerglobal.room2 = true
			emit_signal("room2")
			Playerglobal.chapter = "Chapter 1"
			Playerglobal.room = "Room 2"
			Playerglobal.update_activity()
	else:
		if not Playerglobal.room2:
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "Locked"

func _on_interact():
	objname = $".."/".."/".."/Player.intobj
	print("Interacted with ", objname)
	if objname == "key":
		key = true
		$things/Counter/key.hide()
		$things/Counter/key/keycollision.disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
