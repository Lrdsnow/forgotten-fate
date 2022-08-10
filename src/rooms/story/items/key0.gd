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
