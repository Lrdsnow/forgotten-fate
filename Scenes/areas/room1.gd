extends Spatial

onready var pglobal = get_node("/root/Playerglobal")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var objname = ""
var key = false
var room2 = false

signal room2

# Called when the node enters the scene tree for the first time.
func _ready():
	pglobal.objects = ["key", "hidebed", 0, 0]
	$".."/".."/".."/Player.connect("interact", self, "_on_interact")
	$".."/".."/".."/Player.connect("door", self, "_on_door")
	reset()
	#pass
#pglobal.interactible = ["key"]

func reset():
	$".."/room2/things/boxes.hide()
	$".."/room2/things/boxes/box/CollisionShape.disabled = true
	$".."/room2/things/boxes/box2/CollisionShape.disabled = true
	$".."/room2/things/boxes/box3/CollisionShape.disabled = true
	$".."/room2/things/boxes/box4/CollisionShape.disabled = true
	$".."/room2/things/boxes/box5/CollisionShape.disabled = true
	$".."/room2/things/boxes/box6/CollisionShape.disabled = true
	$".."/room2/things/boxes/box7/CollisionShape.disabled = true
	$".."/room2/things/boxes/box8/CollisionShape.disabled = true
	$".."/room2/things/boxes/box9/CollisionShape.disabled = true
	$".."/room2/things/lamp4/lamplight.light_energy = 0.1

func _on_door():
	if key and not room2:
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Open"
		if Input.is_action_just_pressed("interact"):
			$room/door.hide()
			$room/door/doorcollison.disabled = true
			print("Opened door")
			key = false
			room2 = true
			emit_signal("room2")
	else:
		if not room2:
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
