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
		print("Extras: add_item: Added Item")
	else:
		print("Extras: add_item: Cannot add item!, Not In Game!")

func add_save_menu_opt(value_name:String, type:String) -> Node: # (Requires full_game:true in mod config) (Enables Modded Save!, May Break Other Mods!) Adds a option to save. Supported types: bool
	if ! Global.ingame:
		Global.modded_save = true
		if type == "bool":
			var button = CheckBox.new()
			button.text = value_name
			var menu = self.get_node("/root/menu")
			menu = menu.get_node(menu.get_meta("mod_values"))
			menu.show()
			menu.add_child(button)
			print("Extras: add_save_menu_opt: Added New Checkbox To Save Menu")
			return button
		else:
			print("Extras: add_save_menu_opt: unsupported type: "+type)
			return null
	else:
		print("Extras: add_save_menu_opt: Cannot add Option to Save Menu!, In game!")
		return null

func add_save_dict_to_save(save_extras:Dictionary): # (full_game:true Recomended in mod config) (Enables Modded Save! May Break Other Mods!)
	Global.modded_save = true
	modded_save=save_extras
	print("Extras: add_save_dict_to_save: Added Extras To Save")

func add_quest(quest:Dictionary): # Adds a quest
	Global.quests.append(quest)
	print("Extras: add_quest: Added New Quest")

func replace_questline(questline:Array): # Replaces questline
	Global.quests = questline
	print("Extras: replace_questline: Set New Questline")

func set_env(enviorment:Environment, permanent:bool=true): # Replaces questline
	Global.mod_env_override = permanent
	Global.env = enviorment
	print("Extras: set_env: Set Custom Enviorment")

func set_efficency(enabled:bool): # Sets Efficency Mode
	Global.efficiency_mode = enabled
	print("Extras: set_efficency: Set Efficency Mode To "+str(enabled))

func set_held_item(item_name:String): # Sets Held Item
	Global.player.held_item.name = item_name
	print('Extras: set_held_item: Set Current Held Item To "'+str(item_name)+'"')

@warning_ignore("unused_parameter")
func add_object(object:Node, position:Vector3, rotation:Vector3): # Loads an item into the world
	if Global.ingame:
		get_node("/root/World").add_child(object)
		print("Extras: add_object: Loaded Object")
		#object.position = position
		#object.rotation = rotation
	else:
		print("Extras: add_object: Cannot load object!, Not In Game!")
