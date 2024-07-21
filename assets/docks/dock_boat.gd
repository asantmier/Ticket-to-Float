extends Area3D

signal boat_selected(type: PlayerData.BoatEnum)

@export var type : PlayerData.BoatEnum

@onready var cruise : Node3D = $"Holder/Cruise Ship Small"
@onready var cargo : Node3D = $"Holder/Container Ship"
@onready var ferry : Node3D = $"Holder/Ferry Boat"
@onready var fishing : Node3D = $"Holder/Fishing Boat"


# Called when the node enters the scene tree for the first time.
func _ready():
	cruise.find_child("AnimationPlayer").play("RESET")
	cargo.find_child("AnimationPlayer").play("RESET")
	ferry.find_child("AnimationPlayer").play("RESET")
	fishing.find_child("AnimationPlayer").play("RESET")
	roll()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and TurnManager.can_draw():
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Draw!")
			hide()
			boat_selected.emit(type)
			PlayerData.add_subtract_boat(1, type)


func roll():
	type = PlayerData.BoatEnum[PlayerData.BoatEnum.keys().pick_random()]
	cruise.visible = type == PlayerData.BoatEnum.CRUISE
	cargo.visible = type == PlayerData.BoatEnum.CARGO
	ferry.visible = type == PlayerData.BoatEnum.FERRY
	fishing.visible = type == PlayerData.BoatEnum.FISH
	show()


func activate(toggle):
	input_ray_pickable = toggle
