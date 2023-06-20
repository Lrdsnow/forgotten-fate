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
	subquest = Global.quests[Global.quest[0]].segments[Global.quest[1]]
	if str(subquest.type) == "grab":
		#var items = []
		for item in subquest.item_names:
			if item in Global.inv:
				Global.debug_log("QuestHandler: subquest complete: " + subquest.name)
				Saves.save_game(Saves.get_global_save())
				if subquest.has("trophy"):
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
						Global.debug_log("QuestHandler: All Quests Completed")
						get_tree().change_scene("res://src/extras/credits.tscn")
						Global.quit_game("quest")
			else:
				Global.debug_log("QuestHandler: subquest vaild: " + subquest.name)
	elif str(subquest.type) == "door":
		if subquest.door != null:
			if subquest.door == interact_item:
				Global.debug_log("QuestHandler: subquest complete: " + subquest.name)
				Saves.save_game(Saves.get_global_save())
				if prev_orb != null:
					prev_orb.queue_free()
				if Global.quest[1] + 1 != Global.quests[Global.quest[0]].segments.size():
					Global.quest[1] = Global.quest[1] + 1
				else:
					if Global.quest[0] + 1 != Global.quests.size():
						Global.quest[0] = Global.quest[0] + 1
						Global.quest[1] = 0
					else:
						Global.debug_log("QuestHandler: All Quests Completed")
						if not Global.debug_mode:
							get_tree().change_scene_to_file("res://src/extras/credits.tscn")
							Global.quit_game("quest")
			else:
				Global.debug_log("QuestHandler: subquest vaild: " + subquest.name)
	elif str(subquest.type) == "hide" or str(subquest.type) == "other":
		if subquest.complete:
			Global.debug_log("QuestHandler: subquest complete: " + subquest.name)
			if Global.quest[1] + 1 != Global.quests[Global.quest[0]].segments.size():
					Global.quest[1] = Global.quest[1] + 1
			else:
				if Global.quest[0] + 1 != Global.quests.size():
					Global.quest[0] = Global.quest[0] + 1
					Global.quest[1] = 0
				else:
					Global.debug_log("QuestHandler: All Quests Completed")
					get_tree().change_scene("res://src/extras/credits.tscn")
					Global.quit_game("quest")
			#Global.debug_log("QuestHandler: Quest info: "+str(Global.current_quest()))
		else:
			Global.debug_log("QuestHandler: subquest vaild: " + subquest.name)
	update_quest_info()
	nurse_hide()

func update_quest_info():
	self.modulate = color[Global.quests[Global.quest[0]].segments[Global.quest[1]].color]
	if self.modulate == color.red:
		shaking = true
		#get_node("/root/World/Player/collision/neck/head/player_camera/cam_anim").play("shake")
	else:
		shaking = false
	text = Global.quests[Global.quest[0]].name
	$"../desc".text = Global.quests[Global.quest[0]].segments[Global.quest[1]].name

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
