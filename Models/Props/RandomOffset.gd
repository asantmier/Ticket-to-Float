extends AnimationPlayer


## Called when the node enters the scene tree for the first time.
func _ready():
	animation_started.connect(_on_animation_started)


func _on_animation_started(anim_name):
	print(anim_name)
	seek(randf_range(0, current_animation_length))
