extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pglobal = get_node("/root/Playerglobal")
var objname = ""
var doorname = ""
var sprint = false

signal room5
signal cutsene

# Called when the node enters the scene tree for the first time.
func _on_room2():
	$".."/".."/".."/Player.connect("interact", self, "_on_interact")
	$".."/".."/".."/Player.connect("door", self, "_on_door")

func _on_door():
	doorname = $".."/".."/".."/Player.doorname
	if doorname == "door":
		if $".."/room3.ad == false:
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "Locked"
		else:
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Open"
			if Input.is_action_just_pressed("interact"):
				$room/door.hide()
				$room/door/doorcollison.disabled = true
				print("Opened door")
				emit_signal("room5")
	elif doorname == "beddoor":
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "E - Open"
		if Input.is_action_just_pressed("interact"):
			$room/beddoor.hide()
			$room/beddoor/doorcollison.disabled = true
			print("Opened door")
	else:
		$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/interaction.text = "Locked"

func _on_interact():
	objname = $".."/".."/".."/Player.intobj
	if objname == "hidebed":
		emit_signal("cutsene")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_sprinty_body_entered(body):
	print(body.name)
	if body.name == "Player":
		if not sprint:
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/info.text = "Hold Shift To Sprint"
			var t = Timer.new()
			t.set_wait_time(1)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			t.queue_free()
			$".."/".."/".."/Player/CollisionShape/Neck/Head/Camera/cent/crosshair/info.text = ""
			sprint = true


func _on_room3_done():
	pglobal.objects = [0, 0, 0, 0]
