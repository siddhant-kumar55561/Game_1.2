extends CharacterBody2D

const SPEED = 100.0
const init_JUMP_VELOCITY = -210.0
const mid_JUMP_VELOCITY = -500
var GRAVITY = 900.0
const ROLL_VELOCITY = 900

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var walk_sound: AudioStreamPlayer2D = $walkSound
@onready var jumptimer: Timer = $jumpTimer
@onready var combotimer: Timer = $comboTimer


var is_rolling = false
var coyote_jump = false
var combo_queued: bool = false


func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# 2. Handle player input to change velocity
	_handle_movement()
	_handle_jump(delta)
	_handle_roll()
	
	# 3. Determine and play the correct animation based on state
	_update_animation()
	
	# 4. Apply final movement
	move_and_slide()

# Handles left and right movement
func _handle_movement():
	# Don't allow movement while some attacks in progress
	if (animated_sprite.animation == "heavyattack") and animated_sprite.is_playing():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		return
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# Handles jumping and jump cutting
func _handle_jump(delta):
	if (animated_sprite.animation == "heavyattack") and animated_sprite.is_playing():
		return
	# 1. Grant coyote time if we are on the floor
	if is_on_floor():
		coyote_jump = true
	# 2. If we are in the air AND we still have coyote time, start the timer.
	#    The timer will automatically call _on_timer_timeout() when it finishes,
	#    which will set coyote = false.
	elif not is_on_floor() and coyote_jump == true:
		# Only start the timer if it's not already running
		if jumptimer.is_stopped():
			jumptimer.start()

	
	if Input.is_action_just_pressed("jump") and coyote_jump == true: # initial boost
		coyote_jump = false
		velocity.y = init_JUMP_VELOCITY
		jump_sound.play()
	
	if Input.is_action_pressed("jump") and velocity.y < 0: # boost jump while going up
		velocity.y += mid_JUMP_VELOCITY * delta
	if abs(velocity.y) < 100:
		velocity.y += 100 * delta
		

# Handles rolling
func _handle_roll():
	if Input.is_action_just_pressed("roll"):
		pass

# Chooses the correct animation based on the character's current state
func _update_animation():
	# --- Animation Priority ---
	# 1. If any attack animation is playing, let it finish. This prevents
	#    other animations from cutting it off mid-swing.
	
	
	if animated_sprite.animation == "lightattack" and animated_sprite.is_playing():
		if Input.is_action_just_pressed("lightattack"):
			combo_queued = true
			combotimer.start()
			print("combo queued")
		return
	
	if combo_queued == true:
		# Do NOT await here!
		return
	
	if(animated_sprite.animation == "heavyattack") and animated_sprite.is_playing():
		return

	# 2. Check for player input to start a new animation.
	if Input.is_action_just_pressed("lightattack"):
		animated_sprite.play("lightattack")
		combo_queued = false
	elif Input.is_action_just_pressed("heavyattack") and is_on_floor():
		animated_sprite.play("heavyattack")
	# 3. Handle state-based animations if no attack was initiated.
	elif not is_on_floor():
		animated_sprite.play("airRoll")
		if velocity.x != 0:	# Flip the sprite based on movement direction
			animated_sprite.flip_h = velocity.x < 0
	else:
		# On the floor state
		if is_rolling:
			animated_sprite.play("roll")
		else:
			if velocity.x != 0:
				animated_sprite.play("run")
				# Flip the sprite based on movement direction
				animated_sprite.flip_h = velocity.x < 0
			else:
				animated_sprite.play("idle")

func _on_timer_1_timeout() -> void:
	coyote_jump = false


func _on_animated_sprite_2d_animation_finished() -> void:
	match animated_sprite.animation:
		"lightattack":
			if combo_queued:
				animated_sprite.play("lightattackplus")
				# don't await or call timeout here
			else:
				_on_combotimer_timeout()

		"lightattackplus":
			# when lightattackplus ends normally
			_on_combotimer_timeout()

func _on_combotimer_timeout() -> void:
	combo_queued = false
	print("combo = false")
