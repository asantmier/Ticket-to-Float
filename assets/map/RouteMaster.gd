@icon("res://boat-speed-c.png")
class_name RouteMaster
extends Node3D

@export var island_A : String
@export var island_B : String
@export var length : int
@export var type : PlayerData.BoatEnum

@onready var slots_holder : Node3D = $"../Slots"
@onready var click_zone : Area3D = $"../Click Zone"

var splash_sfx := preload("res://assets/map/splash.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	if not slots_holder:
		printerr("Please set slots holder!")
	if not island_A or not island_B:
		printerr("Please set islands A B")
	
	TurnManager.turn_started.connect(_on_turn_start)
	TurnManager.draw_started.connect(_on_not_turn)
	TurnManager.pirates_started.connect(_on_not_turn)
	
	IslandGraph.register_route(self)
	
	_on_not_turn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_pirate():
	IslandGraph.unregister_route(self)
	for slot in slots_holder.get_children():
		if slot.has_method("show_pirate_ship"):
			slot.show_pirate_ship()
		else:
			printerr("Please set up slots on this route and double check method names!")


func _on_click_zone_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and IslandGraph.is_registered(self):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Click!")
			if PlayerData.can_afford(length, type):
				IslandGraph.connect_islands(island_A, island_B)
				IslandGraph.unregister_route(self)
				PlayerData.buy_route(length, type)
				TurnManager.finish_turn()
				for slot in slots_holder.get_children():
					if slot.has_method("show_ship"):
						slot.show_ship()
					else:
						printerr("Please set up slots on this route!")
				var sound := splash_sfx.instantiate()
				add_child(sound)


func _on_turn_start():
	click_zone.input_ray_pickable = true


func _on_not_turn():
	click_zone.input_ray_pickable = false
