extends Node

var modded_save = {}

signal on_game_started # Emited When Game Is Started

func add_item(item_name:String, item_type:String, item_obj:Node): # Adds an item to the game
	if Global.ingame:
		Global.all_items.append(item_name)
		if Global.get(item_type) != null:
			Global.get(item_type).append(item_name)
		var item_container = get_node("/root/World/Player").get_node(get_node("/root/World/Player").get_meta("item_container"))
		item_container.call_deferred("add_child", item_obj)
	else:
		print("Cannot add item!, Not In Game!")

func add_save_menu_opt(value_name:String, type:String) -> Node: # (Requires full_game:true in mod config) (Enables Modded Save!, May Break Other Mods!) Adds a option to save. Supported types: bool
	if ! Global.ingame:
		Global.modded_save = true
		if type == "bool":
			var button = CheckBox.new()
			button.text = value_name
			var menu = self.get_node("/root/menu")
			print(menu.get_meta("mod_values"))
			menu = menu.get_node(menu.get_meta("mod_values"))
			menu.show()
			menu.add_child(button)
			return button
		else:
			print("unsupported type: "+type)
			return null
	else:
		print("Cannot add Option to Save Menu!, In game!")
		return null

func add_save_dict_to_save(save_extras:Dictionary): # (full_game:true Recomended in mod config) (Enables Modded Save! May Break Other Mods!)
	Global.modded_save = true
	modded_save=save_extras

func add_quest(quest:Dictionary): # Adds a quest
	Global.quests.append(quest)

func replace_questline(questline:Array): # Replaces questline
	Global.quests = questline

func set_env(enviorment:Environment, permanent:bool=true): # Replaces questline
	Global.mod_env_override = permanent
	Global.env = enviorment

func set_efficency(enabled:bool): # Sets Efficency Mode
	Global.efficiency_mode = enabled

func set_held_item(item_name:String): # Sets Held Item
	Global.player_held_item = item_name
