@tool
extends Node3D

@export var title : String:
	set(value):
		title = value
		$Label3D.text = title


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
