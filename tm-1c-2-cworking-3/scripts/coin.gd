extends Area2D


@onready var game_manager: Node = %"Game Manager"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	animation_player.play("pickup")
	
"""extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var GRAVITY = 900.0  # ✅ Add a gravity constant(lol) (adjust as needed)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var walk_sound: AudioStreamPlayer2D = $walkSound

var is_rolling = false

	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("roll"):
		pass
	else:
		_moving()
		_jumping()
		# Apply gravity
		if not is_on_floor():
			velocity.y += GRAVITY * delta
	
	move_and_slide()

# Handle Movement
func _moving():
	if is_rolling == false:
		var direction := Input.get_axis("move_left", "move_right")
		if direction and is_on_floor():
			velocity.x = direction * SPEED
			animated_sprite.flip_h = direction < 0
			animated_sprite.play("run")
		elif direction and not is_on_floor():
			velocity.x = direction * SPEED
			animated_sprite.flip_h = direction < 0
		elif velocity.x == 0 and velocity.y == 0:
			animated_sprite.play("idle")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	else:
		pass

# Handle jump
func _jumping():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		animated_sprite.play("roll")
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	if Input.is_action_just_released("jump") and velocity.y < 0: # jump cutting
		velocity.y *= 0.5  # reduces upward speed smoothly
		
	if not is_on_floor():
		pass
			
#func _rolling():
#	is_rolling = true
#	GRAVITY = 0
#	animated_sprite.play("roll")
#	is_rolling = false
"""
