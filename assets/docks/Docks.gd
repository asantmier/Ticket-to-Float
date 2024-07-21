extends Node3D


@onready var boats : Node3D = $"Boats Selection"
@export var anim : AnimationPlayer
@export var sfx : AudioStreamPlayer

var draws_left : int = 2
var docked : bool

## TODO
# Will we have to create events for each state transition and let each
# listener subscribe itself, then fire them when needed?

# Called when the node enters the scene tree for the first time.
func _ready():
	TurnManager.turn_started.connect(_on_start_turn)
	TurnManager.draw_started.connect(_on_start_draw)
	TurnManager.pirates_started.connect(_on_start_pirates)
	TurnManager.first_draw_started.connect(_on_start_first_draw)
	
	docked = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func scramble():
	for boat in boats.get_children():
		boat.roll()


func _on_dock_boat_selected(type):
	draws_left -= 1
	if draws_left < 1:
		#for boat in boats.get_children():
			#boat.activate(false)
		_undock()


func _on_start_turn():
	draws_left = 1
	scramble()
	_dock()


func _on_start_draw():
	sfx.play()
	draws_left = 2
	scramble()
	_dock()


func _on_start_first_draw():
	draws_left = 3
	scramble()
	_dock()


func _on_start_pirates():
	draws_left = 0
	#for boat in boats.get_children():
		#boat.activate(false)
	_undock()


func _on_animation_player_animation_finished(anim_name):
	if draws_left < 1:
		print("Anim complete; finishing draw.")
		TurnManager.finish_draw()
	elif draws_left > 0:
		print("Anim complete; enabling clicks.")
		for boat in boats.get_children():
			boat.activate(true)
			print(boat.input_ray_pickable)


func _dock():
	if not docked:
		anim.play_backwards("leave_dock")
		for boat in boats.get_children():
			boat.activate(false)
		docked = true
	else:
		print("Dock called at inappropriate time!")


func _undock():
	if docked:
		anim.play("leave_dock")
		for boat in boats.get_children():
			boat.activate(false)
		docked = false
	else:
		print("Undock called at inappropriate time!")
