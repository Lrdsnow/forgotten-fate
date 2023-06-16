extends Node

var standard_save = {
	"player_name":"Jack Campbell",
	"difficulty":1,
	"health":100,
	"stamina":100,
	"power":100,
	"quest":[0,0]
}

func get_saves() -> Array:
	var saves = []
	var folder = Global.get_home() + "/Saves"
	print(folder)
	var files = []
	var dir = DirAccess.open(folder)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	for file in files:
		if ".save" in file or ".json" in file:
			var json = JSON.new()
			var config = folder + "/" + file
			
			if FileAccess.file_exists(config):
				var file_access = FileAccess.open(config, FileAccess.READ)
				@warning_ignore("unused_variable")
				var data = json.parse(file_access.get_as_text())
				var save_data = json.get_data()
				
				Global.debug_log(json.get_error_message())
				saves.append(save_data)
			else:
				Global.debug_log("SaveLoader: Corrupted Save")
	
	return saves

func get_global_save() -> Dictionary: return {"name":Global.player.name,"difficulty":Global.difficulty,"stats":{"health":Global.player.stats.health,"stamina":Global.player.stats.stamina,"power":Global.player.stats.power}, "quest":Global.quest}
func load_save(save):
	for i in save.keys():
		if i == "difficulty" or i == "quest": Global.set(i, save[i])
		elif i == "name": Global.player[i]=save[i]
		elif i == "stats": for x in save[i].keys(): Global.player.stats[x] = save[i][x]
func save_game(save:Dictionary):
	var save_file = Global.get_home() + "/Saves/" + Global.lower(save.name) + ".save"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(str(save))
