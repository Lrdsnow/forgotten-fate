extends StaticBody3D

func _ready():
	Global.load_complete.connect(self._load)

func _load():
	if not "key0" in Global.grab_items:
		self.call("queue_free")

func interact(interact):
	if interact == self:
		Global.grab_items.erase("key0")
		Global.inv.append("key0")
		self.hide()
		self.call("queue_free")


func _on_room_1_door_body_entered(body):
	if body.name == "player":
		for door_lock in Global.doors_lock_status:
			print("DoorHandler: "+door_lock)
			if Global.doors_lock_status[door_lock] == "key0":
				Global.doors[door_lock].get_node(Global.doors[door_lock].get_meta("anim")).play_backwards("open_fast")
				break
