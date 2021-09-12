extends Node2D
var spell = preload("res://Scenes/Projectiles/Semilla.tscn")
var mover = false	
var pos_actual = self.position
var anim_free = true

var type
var enemy_array = []
var built = false
var enemy
var ready = true


#var nombre = ""
onready var animated_sprite : AnimatedSprite = get_node("Torre")
#Comenté connect porque daba errores rodo (junto con todo el ready)
#func _ready():
#	connect("", self, "signal")

func _ready():
	if built:
		self.get_node("Rango/CollisionShape2D").get_shape().extents = 8*Vector2(Data.tower_data[type]["range"],Data.tower_data[type]["range"])
		animated_sprite.speed_scale = Data.tower_data[type]["rof"]


##
## Rotación de sprites
#Si se usa delta quitar undescore
func _physics_process(_delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if ready:
			#bullet()
			fire()
	else:
		enemy = null

func turn():
	get_node("Torre").look_at(enemy.position)
	
	
func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		enemy_progress_array.append(i.offset)
	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]

func fire():

	ready = false
	enemy.on_hit(Data.tower_data[type]["damage"])
	yield(get_tree().create_timer(Data.tower_data[type]["rof"]), "timeout")
	ready = true

"""func bullet():
	var spell_instance = spell.instance()
	spell_instance.position = get_global_position()
	spell_instance.rotation = get_angle_to(enemy.position)
	add_child(spell_instance)
"""

# si body se usa quitar el underscore
func _on_Rango_body_entered(body):
	enemy_array.append(body.get_parent())
	mover = true
	#print(enemy_array)
func _on_Rango_body_exited(body):
	enemy_array.erase(body.get_parent())
	mover = false
	#print("idle")
	if anim_free == true:
		anim_free = false
		animated_sprite.play("idle")

func _on_Derecha_body_entered(_body):
	#print("Sprite_Derecha")
	if anim_free == true:
		anim_free = false
		animated_sprite.flip_h = false
		animated_sprite.play("attack_right")
func _on_Abajo_body_entered(_body):
	#print("Sprite_Abajo")
	if anim_free == true:
		anim_free = false
		animated_sprite.play("attack_down")
func _on_Izquierda_body_entered(_body):
	#print("Sprite_Izquierda")
	if anim_free == true:
		anim_free = false
		animated_sprite.flip_h = true
		animated_sprite.play("attack_right")
func _on_Arriba_body_entered(_body):
	#print("Sprite_Arriba")
	if anim_free == true:
		anim_free = false
		animated_sprite.play("attack_up")

func _on_Torre_animation_finished():
	anim_free = true
