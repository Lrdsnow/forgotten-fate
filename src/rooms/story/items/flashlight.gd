extends StaticBody3D

func _ready():
	Global.load_complete.connect(self._load)

func _load():
	if "basic_flashlight" in Global.inv:
		self.call("queue_free")

func interact(obj):
	if obj == self:
		Global.grab_items.erase("basic_flashlight")
		Global.inv.append("basic_flashlight")
		Global.player.obj.flashlight.show()
		self.hide()
		self.call("queue_free")


func _on_area_3d_body_entered(body):
	if body == Global.player.obj:
		get_node("/root/World/map/floor1").close_staircase_door()
