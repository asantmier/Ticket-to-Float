## INFO Autoload script
extends Node

signal goal_requested


var boats_cargo : int
var boats_cruise : int
var boats_ferry : int
var boats_fish : int

var turn : int
var points : int
var goals : Array[Goal]

class Goal:
	var A
	var B
	var score
	
	func _init(A, B, score):
		self.A = A
		self.B = B
		self.score = score
	
	func equals(other: Goal):
		return (A == other.A and B == other.B) or (A == other.B and B == other.A)

enum BoatEnum { CARGO, CRUISE, FERRY, FISH }


# Called when the node enters the scene tree for the first time.
func _ready():
	reset()


func reset():
	boats_cargo = 0
	boats_cruise = 0
	boats_ferry = 0
	boats_fish = 0
	turn = 0
	points = 0
	goals.clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func can_afford(cost, type):
	match type:
		BoatEnum.CARGO:
			return boats_cargo >= cost
		BoatEnum.CRUISE:
			return boats_cruise >= cost
		BoatEnum.FERRY:
			return boats_ferry >= cost
		BoatEnum.FISH:
			return boats_fish >= cost


func buy_route(cost, type):
	match type:
		BoatEnum.CARGO:
			boats_cargo -= cost
		BoatEnum.CRUISE:
			boats_cruise -= cost
		BoatEnum.FERRY:
			boats_ferry -= cost
		BoatEnum.FISH:
			boats_fish -= cost
	points += cost


func add_subtract_boat(num, type):
	match type:
		BoatEnum.CARGO:
			boats_cargo += num
		BoatEnum.CRUISE:
			boats_cruise += num
		BoatEnum.FERRY:
			boats_ferry += num
		BoatEnum.FISH:
			boats_fish += num


func reset_goals():
	goals.clear()
	goal_requested.emit()


func check_goals():
	if IslandGraph.is_fully_connected():
		points += 10 # Bonus for this ending
		for goal in goals:
			points += goal.score
		TurnManager.end_game()
		return
	
	var completed : Array
	for goal in goals:
		if IslandGraph.is_islands_connected(goal.A, goal.B):
			points += goal.score
			completed.append(goal)
		# TEST UNTESTED 
		if not IslandGraph.is_possible(goal.A, goal.B):
			completed.append(goal)
	for goal in completed:
		goals.erase(goal)
	
	if goals.size() < 2:
		goal_requested.emit()
	else:
		TurnManager.finish_picking_goals()


func set_goal(A, B, points):
	var goal := Goal.new(A, B, points)
	goals.append(goal)
	if goals.size() < 2:
		goal_requested.emit()
	else:
		TurnManager.finish_picking_goals()


func is_goal(dict):
	for goal in goals:
		if goal.equals(dict):
			return true
	return false
