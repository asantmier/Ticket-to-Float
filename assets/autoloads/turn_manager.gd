## INFO Autoload script
extends Node

signal turn_started
signal draw_started
signal pirates_started
signal first_select_goals_started
signal first_draw_started
signal game_over_started


enum State { TURN, DRAW, PIRATES, FIRST_SELECT_GOALS, FIRST_DRAW, GAME_OVER }
var state : State


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	reset()


func reset():
	state = State.FIRST_SELECT_GOALS
	await get_tree().create_timer(0.5).timeout
	_goto_first_select_goals()


# Called when connecting, overdrawing, or combining
func finish_turn():
	await get_tree().create_timer(0.5).timeout
	PlayerData.check_goals()
	#_goto_pirates()


# Called after drawing
func finish_draw():
	if state == State.DRAW:
		_goto_turn()
	elif state == State.TURN:
		await get_tree().create_timer(0.5).timeout
		_goto_pirates()
	elif state == State.FIRST_DRAW:
		_goto_draw()


# Called after the pirates do their thing
func finish_pirates():
	if IslandGraph.has_no_routes():
		end_game()
		return
	await get_tree().create_timer(0.5).timeout
	PlayerData.check_goals()
	#_goto_draw()


# Called after the first goals are selected
func finish_picking_goals():
	if state == State.FIRST_SELECT_GOALS:
		_goto_first_draw()
	elif state == State.TURN:
		_goto_pirates()
	elif state == State.PIRATES:
		_goto_draw()


# Called whenever game end conditions are met
func end_game():
	_goto_game_over()


func _goto_turn():
	state = State.TURN
	turn_started.emit()


func _goto_draw():
	PlayerData.turn += 1
	state = State.DRAW
	draw_started.emit()


func _goto_pirates():
	state = State.PIRATES
	pirates_started.emit()
	await get_tree().create_timer(0.5).timeout
	IslandGraph.do_pirates()


func _goto_first_select_goals():
	state = State.FIRST_SELECT_GOALS
	first_select_goals_started.emit()
	PlayerData.reset_goals()


func _goto_first_draw():
	state = State.FIRST_DRAW
	first_draw_started.emit()


func _goto_game_over():
	state = State.GAME_OVER
	game_over_started.emit()


func can_draw() -> bool:
	if not (state == State.DRAW or state == State.TURN or state == State.FIRST_DRAW):
		printerr("Tried drawing when cannot!")
	return state == State.DRAW or state == State.TURN or state == State.FIRST_DRAW

