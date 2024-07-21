extends Node3D

@onready var ship_model : Node3D = $Ship
@onready var pirate_ship_model : Node3D = $"Pirate Ship"

# Called when the node enters the scene tree for the first time.
func _ready():
	if not ship_model or not pirate_ship_model:
		printerr("Set up model names correctly in slot!")
	ship_model.hide()
	pirate_ship_model.hide()


func show_ship():
	ship_model.show()


func show_pirate_ship():
	pirate_ship_model.show()
