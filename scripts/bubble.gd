extends Area2D

var speed = 150
var direction = 1

func _physics_process(delta: float) -> void:
	position.x += speed * delta * direction

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	area.take_damage()
	queue_free()
