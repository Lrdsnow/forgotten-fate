extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pglobal = get_node("/root/Playerglobal")
var objname = ""
var doorname = ""
var sprint = false

var room5 = load("res://Scenes/hospitalfloor1rooms/room5.tscn").instance()

signal room5
signal cutscene

func _ready():
	get_node("/root/World/Terrains/hospitalfloor1/room1").connect("room2", self, "_on_room2")

# Called when the node enters the scene tree for the first time.
func _on_room2():
	get_node("/root/World/Player").connect("interact", self, "_on_interact")
	get_node("/root/World/Player").connect("door", self, "_on_door")
	get_node("/root/World/Terrains/hospitalfloor1/room3").connect("done", self, "_on_room3_done")

func _on_door():
	doorname = get_node("/root/World/Player").doorname
	if doorname == "door":
		if $".."/room3.ad == false:
			get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "Locked"
		else:
			get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "E - Open"
			if Input.is_action_just_pressed("interact"):
				$room/door.hide()
				$room/door/doorcollison.disabled = true
				print("Opened door")
				get_node("/root/World/Terrains/hospitalfloor1").add_child(room5)
				emit_signal("room5")
	elif doorname == "beddoor":
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "E - Open"
		if Input.is_action_just_pressed("interact"):
			$room/beddoor.hide()
			$room/beddoor/doorcollison.disabled = true
			print("Opened door")
			Playerglobal.chapter = "Chapter 1"
			Playerglobal.room = "Room 3"
			Playerglobal.update_activity()
	elif doorname == "exitdoor":
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "E - Open"
		if Input.is_action_pressed("interact"):
			if ! Playerglobal.dend:
				get_tree().change_scene("res://Scenes/end.tscn")
			else:
				get_node("../room5/room/exitdoor/").hide()
				get_node("../room5/room/exitdoor/doorcollison").disabled = true
	else:
		get_node("/root/World/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction").text = "Locked"

func _on_interact():
	objname = get_node("/root/World/Player").intobj
	if objname == "hidebed":
		emit_signal("cutscene")
	elif objname == "screwdriver":
		$things/screwdriver.hide()
		$things/screwdriver/CollisionShape.disabled = true
		pglobal.inv.append("screwdriver")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sprinty_body_entered(body):
	print(body.name)
	if body.name == "Player":
		if not sprint:
			get_node("/root/World/Player/menus/info").text = "Hold Shift To Sprint"
			var t = Timer.new()
			t.set_wait_time(1)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
			get_node("/root/World/Player/menus/info").text = ""
			sprint = true


func _on_room3_done():
	pglobal.objects = ["screwdriver", 0, 0, 0]
	get_node("../room1").queue_free()
	$".."/room2/things/boxes.show()
	$".."/room2/things/boxes/box_0/collision.disabled = false
	$".."/room2/things/boxes/box_1/collision.disabled = false
	$".."/room2/things/boxes/box_2/collision.disabled = false
	$".."/room2/things/boxes/box_3/collision.disabled = false
	$".."/room2/things/boxes/box_4/collision.disabled = false
	$".."/room2/things/boxes/box_5/collision.disabled = false
	$".."/room2/things/boxes/box_6/collision.disabled = false
	$".."/room2/things/boxes/box_7/collision.disabled = false
	$".."/room2/things/boxes/box_8/collision.disabled = false
	$".."/room2/things/boxes/box_9/collision.disabled = false
	$".."/room2/things/lamp4/lamplight.light_energy = 1
