extends Node

func get_saves() -> Array:
	var saves = []
	var folder = Global.saves_folder
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
				var data = json.parse(file_access.get_as_text())
				var save_data = json.get_data()
				
				Global.debug_log(json.get_error_message())
				saves.append(save_data)
			else:
				Global.debug_log("SaveLoader: Corrupted Save")
	
	return saves
