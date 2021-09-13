extends Node2D

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0

func _ready():
	map_node = get_node("Map1")
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed",self,"initiate_build_mode",[i.get_name()])
	#start_next_wave()
		
	#si delta se usa quitar el underscore
func _process(_delta):
	if build_mode:
		update_tower_preview()
	if(get_node("Map1/Path").get_child_count() == 0 and current_wave != 1):
		print(current_wave)
		#start_next_wave()
	
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()

##
### Funciones de oleadas ###
##

func start_next_wave():
	var wave_data = retrieve_wave_data()
	yield(get_tree().create_timer(0.2),"timeout") ##Tiempo entre oleadas para que no comiencen instantaneamente
	spawn_enemies(wave_data)

func retrieve_wave_data():
	current_wave += 1
	var wave_data = Data.wave["Wave"+str(current_wave)]["wave"]	
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemigos/" + i[0] + ".tscn").instance() 
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(i[1]),"timeout")


##
### Funciones de construcción ###
##
func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type #+ T1, T2, etc
	if Data.player["Player"]["leche"] >= Data.tower_data[tower_type]["price"]:
		build_valid = false
		build_mode = true
		get_node("UI").set_tower_preview(build_type,get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("AllowedTorres").world_to_map(mouse_position)
	var tile_position = map_node.get_node("AllowedTorres").map_to_world(current_tile)
	
	if map_node.get_node("AllowedTorres").get_cellv(current_tile)!=-1 and build_type !="Vaca":
		get_node("UI").update_tower_preview(tile_position,"ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	elif map_node.get_node("AllowedVaca").get_cellv(current_tile)!=-1 and build_type =="Vaca":
		get_node("UI").update_tower_preview(tile_position,"ad54ff3c")
		build_valid = true
		build_location = tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position,"adff4545")
		build_valid = false
		
		
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()

func verify_and_build():
	if build_valid:
		Data.player["Player"]["leche"] -= Data.tower_data[build_type]["price"]
		var new_tower = load("res://Scenes/Torres/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		map_node.get_node("Torres").add_child(new_tower,true)
		map_node.get_node("AllowedTorres").set_cellv(build_tile, 7)
