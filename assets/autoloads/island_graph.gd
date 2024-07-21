## INFO Autoload script
extends Node

# Each key in the graph is an island.
# Each value is a dictionary of islands it connects to. Used as a set with .keys()
var graph : Dictionary
var complete_graph : Dictionary
var open_routes : Array[RouteMaster]

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()


func reset():
	graph.clear()
	complete_graph.clear()
	open_routes.clear()

func _input(event):
	if event.is_action_pressed("debug"):
		print(open_routes)
		print(complete_graph.keys())


## Breadth first search for a path between two islands
func _bfs(graph_set, from, find) -> bool:
	if graph_set.keys().size() < 2:
		return false
	if from not in graph_set.keys() or find not in graph_set.keys():
		return false
	var visited := Array()
	var queue := Array()
	queue.push_front(from)
	visited.append(from)
	while not queue.is_empty():
		var curr = queue.pop_front()
		if curr == find:
			return true
		for neighbor in graph_set[curr].keys():
			if neighbor not in visited:
				visited.append(neighbor)
				queue.push_back(neighbor)
	return false


func connect_islands(A, B):
	_add_connection_to_set(graph, A, B)
	_add_connection_to_set(graph, B, A)
	#print(_bfs(graph, "A", "D"))


func register_route(route: RouteMaster):
	var A = route.island_A
	var B = route.island_B
	open_routes.append(route)
	_add_connection_to_set(complete_graph, A, B)
	_add_connection_to_set(complete_graph, B, A)


func unregister_route(route: RouteMaster):
	open_routes.erase(route)


func is_registered(route: RouteMaster) -> bool:
	return route in open_routes


# Returns a dictionary with goal data
func generate_goal() -> PlayerData.Goal:
	var A
	var B
	var valid_starts = complete_graph.keys().duplicate()
	while not B and not valid_starts.is_empty():
		A = valid_starts.pick_random()
		var candidates = []
		for candidate in complete_graph.keys():
			if candidate != A and not _bfs(graph, A, candidate):
				candidates.append(candidate)
		if candidates.size() > 0:
			B = candidates.pick_random()
		else:
			valid_starts.erase(A)
	if not B or valid_starts.is_empty():
		print("No remaining new goals!") # TODO game over
		TurnManager.end_game()
		return null
	var goal := PlayerData.Goal.new(A, B, 5)
	return goal


func is_islands_connected(A, B):
	return _bfs(graph, A, B)


func is_fully_connected():
	var A = complete_graph.keys()[0]
	for B in complete_graph.keys():
		if not _bfs(graph, A, B):
			return false
	return true


func has_no_routes():
	return open_routes.is_empty()


func is_possible(A, B) -> bool:
	# Combine graph with open routes graph
	# do bfs on that graph
	var newgraph = graph.duplicate(true)
	for route in open_routes:
		_add_connection_to_set(newgraph, route.island_A, route.island_B)
		_add_connection_to_set(newgraph, route.island_B, route.island_A)
	return _bfs(newgraph, A, B)


# Does pirate connection blocking
func do_pirates():
	var target = open_routes.pick_random()
	if not target:
		printerr("Pirating method failed to pick random!")
	target.set_pirate()
	TurnManager.finish_pirates()


func _add_connection_to_set(graph_set, key, value):
	if graph_set.has(key):
		var old = graph_set[key]
		old[value] = true # Dummy data, we just need to add the key
		graph_set[key] = old
	else:
		graph_set[key] = { value: true }
