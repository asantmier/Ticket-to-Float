extends Control


@export var counter_cargo : Label
@export var counter_cruise : Label
@export var counter_ferry : Label
@export var counter_fish : Label

@export var turn_counter : Label
@export var score_counter : Label

@export var title_turn : Label
@export var title_draw : Label
@export var title_pirates : Label

@export var info_turn : Label
@export var info_draw : Label
@export var info_pirates : Label
@export var info_first_selection : Label
@export var info_first_draw : Label

@export var goal_titles : Array[Label]
@export var goal_points : Array[Label]
@export var select_goal_titles : Array[Label]
@export var select_goal_points : Array[Label]
@export var select_goal_invalids : Array[Control]
@export var goal1_button : Button
@export var goal2_button : Button
@export var select_goal_container : Control

@export var game_over_panel : Control
@export var game_over_score : Label

@export var menu_panel : Control
@export var rules_panel : Control
@export var welcome_panel : Control

var select_goal1
var select_goal2

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerData.goal_requested.connect(_begin_goal_selection)
	TurnManager.game_over_started.connect(_show_end_screen)
	
	if goal_titles.size() != goal_points.size():
		printerr("Invalid goal configuration!")
	if select_goal_titles.size() != select_goal_points.size():
		printerr("Invalid select goal configuration!")
	
	select_goal_container.hide()
	game_over_panel.hide()
	menu_panel.hide()
	rules_panel.hide()
	welcome_panel.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	update()


func update():
	counter_cargo.text = "x %02d " % PlayerData.boats_cargo
	counter_cruise.text = "x %02d " % PlayerData.boats_cruise
	counter_ferry.text = "x %02d " % PlayerData.boats_ferry
	counter_fish.text = "x %02d " % PlayerData.boats_fish
	
	turn_counter.text = "Turn %02d" % PlayerData.turn
	score_counter.text = "%03d points" % PlayerData.points
	
	title_turn.visible = TurnManager.state == TurnManager.State.TURN
	title_draw.visible = TurnManager.state == TurnManager.State.DRAW
	title_pirates.visible = TurnManager.state == TurnManager.State.PIRATES
	
	info_turn.visible = TurnManager.state == TurnManager.State.TURN
	info_draw.visible = TurnManager.state == TurnManager.State.DRAW
	info_pirates.visible = TurnManager.state == TurnManager.State.PIRATES
	info_first_selection.visible = TurnManager.state == TurnManager.State.FIRST_SELECT_GOALS
	info_first_draw.visible = TurnManager.state == TurnManager.State.FIRST_DRAW
	
	_update_goals()


func _update_goals():
	for goal_idx in range(goal_titles.size()):
		goal_titles[goal_idx].text = ""
		goal_points[goal_idx].text = ""
		if goal_idx < PlayerData.goals.size():
			goal_titles[goal_idx].text = "%s -> %s" % [PlayerData.goals[goal_idx].A, PlayerData.goals[goal_idx].B]
			goal_points[goal_idx].text = "%d points" % PlayerData.goals[goal_idx].score


func _begin_goal_selection():
	# these results have keys, A, B, score
	var goal1 = IslandGraph.generate_goal()
	if goal1 == null: # Game ended
		return
	while PlayerData.is_goal(goal1):
		goal1 = IslandGraph.generate_goal()
	var goal2 = IslandGraph.generate_goal()
	if goal2 == null: # Game ended
		return
	while PlayerData.is_goal(goal2) or goal1.equals(goal2):
		goal2 = IslandGraph.generate_goal()
	select_goal_titles[0].text = "%s -> %s" % [goal1.A, goal1.B]
	select_goal_points[0].text = "%d points" % goal1.score
	select_goal_titles[1].text = "%s -> %s" % [goal2.A, goal2.B]
	select_goal_points[1].text = "%d points" % goal2.score
	select_goal_invalids[0].visible = not IslandGraph.is_possible(goal1.A, goal1.B)
	select_goal_invalids[1].visible = not IslandGraph.is_possible(goal2.A, goal2.B)
	select_goal1 = goal1
	select_goal2 = goal2
	# Use await on the button's signals to contain this all to this method
	# Then return the selected goal to PlayerData with set_goal
	select_goal_container.show()
	if not IslandGraph.is_possible(goal1.A, goal1.B) and not IslandGraph.is_possible(goal2.A, goal2.B):
		TurnManager.end_game()


func _show_end_screen():
	game_over_panel.show()
	game_over_score.text = "Final score: %d points" % PlayerData.points


func _on_end_turn_button_button_down():
	TurnManager.finish_turn()


func _on_goal1_button_down():
	print("pass1")
	if IslandGraph.is_possible(select_goal1.A, select_goal1.B):
		select_goal_container.hide()
		PlayerData.set_goal(select_goal1.A, select_goal1.B, select_goal1.score)


func _on_goal2_button_down():
	print("pass2")
	if IslandGraph.is_possible(select_goal2.A, select_goal2.B):
		select_goal_container.hide()
		PlayerData.set_goal(select_goal2.A, select_goal2.B, select_goal2.score)


func _on_help_button_button_down():
	rules_panel.show()


func _on_menu_button_button_down():
	menu_panel.show()


func _on_menu_close_button_down():
	menu_panel.hide()


func _on_rules_close_button_down():
	rules_panel.hide()


func _on_restart_pressed():
	PlayerData.reset()
	IslandGraph.reset()
	TurnManager.reset()
	get_tree().reload_current_scene()


func _on_quit_game_pressed():
	get_tree().quit()


func _on_start_pressed():
	welcome_panel.hide()
