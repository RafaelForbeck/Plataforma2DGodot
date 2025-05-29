extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump
}

const PONG = preload("res://entities/pong.tscn")
const BUBBLE = preload("res://entities/bubble.tscn")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var last_direction = 1

@export var max_jump_count = 2

var jump_count = 0

var status: PlayerState

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("shot"):
		var new_bubble = BUBBLE.instantiate()
		new_bubble.position = position
		new_bubble.direction = last_direction
		add_sibling(new_bubble)
		
	if Input.is_action_just_pressed("pong"):
		var new_pong = PONG.instantiate()
		new_pong.position = position
		var pong_rig: RigidBody2D = new_pong
		pong_rig.apply_impulse(Vector2(last_direction * 150, -150))
		add_sibling(new_pong)

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
			
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")
	
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	
func idle_state():
	move()
	# Se andou
	if velocity.x != 0:
		go_to_walk_state()
		return
	
	# Se pulou
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
	
func move():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	

	if velocity.x > 0:
		anim.flip_h = false
	elif velocity.x < 0:
		anim.flip_h = true
		
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("DeathZone"):
		call_deferred("reload_scene")
	elif area.is_in_group("LevelEnd"):
		var next_level = area.next_level
		if next_level:
			call_deferred("load_scene", next_level)
		else:
			push_error("Próxima fase não definida em EndLevel")
	elif area.is_in_group("Enemies"):
		if velocity.y > 0: # o player matou o inimigo
			area.take_damage() # deleta o inimigo
			go_to_jump_state()
		else:
			reload_scene()
			

func reload_scene():
	get_tree().reload_current_scene()
	
func load_scene(scene_name: String):
	get_tree().change_scene_to_file("res://scenes/" + scene_name + ".tscn")
