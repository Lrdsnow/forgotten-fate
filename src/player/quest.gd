extends Label

var quest = Global.quests[Global.quest[0]]
var subquest = Global.quests[Global.quest[0]].segments[Global.quest[1]]

var shaking = false

var color = {
	"white":Color(1,1,1),
	"red":Color(1,0,0),
	"blue":Color(0,0,1),
	"green":Color(0,1,0)
}

var prev_orb = null

func _ready():
	shaking = false

func check_quest(interact_item=null):
	if Global.gamejolt:
		Gamejolt.api().ping_session()
	subquest = Global.quests[Global.quest[0]].segments[Global.quest[1]]
	if str(subquest.type) == "grab":
		var items = []
		for item in subquest.item_names:
			if item in Global.inv:
				print("QuestHandler: subquest complete: " + subquest.name)
				Global.save_checkpoint()
				if subquest.has("trophy"):
					if Global.gamejolt:
						Global.trophys[subquest.trophy] = true
						Gamejolt.trophy(subquest.trophy)
					else:
						Global.trophys[subquest.trophy] = true
				if prev_orb != null:
					prev_orb.queue_free()
				if Global.quest[1] + 1 != Global.quests[Global.quest[0]].segments.size():
					Global.quest[1] = Global.quest[1] + 1
				else:
					if Global.quest[0] + 1 != Global.quests.size():
						Global.quest[0] = Global.quest[0] + 1
						Global.quest[1] = 0
					else:
						print("QuestHandler: All Quests Completed")
						get_tree().change_scene("res://src/extras/credits.tscn")
						Global.quit_game("quest")
			else:
				print("QuestHandler: subquest vaild: " + subquest.name)
	elif str(subquest.type) == "door":
		if subquest.door != null:
			if subquest.door == interact_item:
				print("QuestHandler: subquest complete: " + subquest.name)
				Global.save_checkpoint()
				if subquest.has("trophy"):
					if Global.gamejolt:
						Global.trophys[subquest.trophy] = true
						Gamejolt.trophy(subquest.trophy)
					else:
						Global.trophys[subquest.trophy] = true
				if prev_orb != null:
					prev_orb.queue_free()
				if Global.quest[1] + 1 != Global.quests[Global.quest[0]].segments.size():
					Global.quest[1] = Global.quest[1] + 1
				else:
					if Global.quest[0] + 1 != Global.quests.size():
						Global.quest[0] = Global.quest[0] + 1
						Global.quest[1] = 0
					else:
						print("QuestHandler: All Quests Completed")
						get_tree().change_scene("res://src/extras/credits.tscn")
						Global.quit_game("quest")
			else:
				print("QuestHandler: subquest vaild: " + subquest.name)
	elif str(subquest.type) == "hide":
		if subquest.complete:
			print("QuestHandler: subquest complete: " + subquest.name)
			Global.save_checkpoint()
			if subquest.has("trophy"):
					if Global.gamejolt:
						Global.trophys[subquest.trophy] = true
						Gamejolt.trophy(subquest.trophy)
					else:
						Global.trophys[subquest.trophy] = true
			if Global.quest[1] + 1 != Global.quests[Global.quest[0]].segments.size():
					Global.quest[1] = Global.quest[1] + 1
			else:
				if Global.quest[0] + 1 != Global.quests.size():
					Global.quest[0] = Global.quest[0] + 1
					Global.quest[1] = 0
				else:
					print("QuestHandler: All Quests Completed")
					get_tree().change_scene("res://src/extras/credits.tscn")
					Global.quit_game("quest")
			#print("QuestHandler: Quest info: "+str(Global.current_quest()))
		else:
			print("QuestHandler: subquest vaild: " + subquest.name)
	call_deferred("update_quest_info")
	if not Global.cinematic_mode:
		call("nurse_hide")

func update_quest_info():
	self.modulate = color[Global.quests[Global.quest[0]].segments[Global.quest[1]].color]
	if self.modulate == color.red:
		shaking = true
		$quest_anim.play("shake")
		#get_node("/root/World/Player/collision/neck/head/player_camera/cam_anim").play("shake")
	else:
		shaking = false
	if Global.quests[Global.quest[0]].segments[Global.quest[1]].orb:
		if Global.quests[Global.quest[0]].segments[Global.quest[1]].type == "grab":
			for spot in Global.quests[Global.quest[0]].segments[Global.quest[1]].items:
				if spot.has_meta("quest_orb"):
					var orb = load("res://src/extras/orb.tscn").instantiate()
					spot.add_child(orb)
					orb.position = spot.get_meta("quest_orb")
					prev_orb = orb
		elif Global.quests[Global.quest[0]].segments[Global.quest[1]].type == "door":
			pass
		elif Global.quests[Global.quest[0]].segments[Global.quest[1]].type == "hide":
			for spot in Global.quests[Global.quest[0]].segments[Global.quest[1]].hiding_spots:
				#spot = get_node_or_null(spot)
				if spot != null:
					if spot.has_meta("quest_orb"):
						var orb = load("res://src/extras/orb.tscn").instantiate()
						spot.add_child(orb)
						orb.position = spot.get_meta("quest_orb")
						prev_orb = orb
	text = Global.quests[Global.quest[0]].name
	$desc.text = Global.quests[Global.quest[0]].segments[Global.quest[1]].name


func _on_cam_anim_animation_finished(anim_name):
	if shaking:
		$quest_anim.play("shake")
		#get_node("/root/World/Player/collision/neck/head/player_camera/cam_anim").play("shake")

# extras:
func nurse_hide():
	subquest = Global.quests[Global.quest[0]].segments[Global.quest[1]]
	if subquest.name == "HIDE":
		var t = Timer.new()
		t.set_wait_time(3)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		await t.timeout
		t.queue_free()
		if not Global.anims.anim0:
			Global.get_floor().init_animation("bed0", true)
