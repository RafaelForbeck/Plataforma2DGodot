extends Node2D

@onready var platform = $AnimatableBody2D as AnimatableBody2D

@export var time = 1.0
@export var delta_x = 100
@export var delta_y = 100

func _ready() -> void:
	move_platform()
	
func move_platform():
	var target = global_position + Vector2(delta_x, delta_y)
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(platform, "global_position", target, time)
	tween.tween_property(platform, "global_position", global_position, time)
	
