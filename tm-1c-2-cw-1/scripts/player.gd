extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 900.0
const ROLL_VELOCITY = 900

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var walk_sound: AudioStreamPlayer2D = $walkSound

var is_rolling = false

func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# 2. Handle player input to change velocity
	_handle_movement()
	_handle_jump()
	_handle_roll()
	# 3. Determine and play the correct animation based on state
	_update_animation()
	
	# 4. Apply final movement
	move_and_slide()

# Handles left and right movement
func _handle_movement():
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# Handles jumping and jump cutting
func _handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	if Input.is_action_just_released("jump") and velocity.y < 0: # jump cutting
		velocity.y *= 0.5

# Handles rolling
func _handle_roll():
	if Input.is_action_just_pressed("roll"):
		pass

# Chooses the correct animation based on the character's current state
func _update_animation():
	if not is_on_floor():
		# Priority 1: If in the air, always play "roll"
		animated_sprite.play("airRoll")
		# animated_sprite.play("roll")
		# animated_sprite.play("jump")
		pass
	else:
		# If on the floor, check for movement
		if is_rolling:
			animated_sprite.play("roll")
		else:
			if velocity.x != 0:
				animated_sprite.play("run")
				# Flip the sprite based on movement direction
				animated_sprite.flip_h = velocity.x < 0
			else:
				animated_sprite.play("idle")
