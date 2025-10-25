extends CharacterBody2D

const SPEED = 100.0
const init_JUMP_VELOCITY = -210.0
const mid_JUMP_VELOCITY = -500
const GRAVITY = 900.0
const ROLL_VELOCITY = 900

# --- Node References ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")
@onready var sprite: Sprite2D = $Sprite

@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var walk_sound: AudioStreamPlayer2D = $walkSound

@onready var jump_timer: Timer = $jumpTimer
@onready var combo_timer: Timer = $comboTimer

var is_rolling = false
var coyote_jump = false
var combo_queued = false

func _ready():
	anim_tree.active = true

func _physics_process(delta: float) -> void:
	
	if not anim_tree.active:
		anim_tree.active = true
	
	# 1. Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# 2. Handle inputs and state changes
	_handle_movement()
	_handle_jump(delta)
	_handle_roll()
	_handle_attacks()
	
	# 4. Apply final movement
	move_and_slide()
	
	# 5. Update animations based on the *result* of our physics
	_update_animation()


# Handles left and right movement
func _handle_movement():
	# Don't allow movement while in a heavy attack
	if state_machine.get_current_node() == "heavyattack":
		velocity.x = move_toward(velocity.x, 0, SPEED)
		return
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = (direction < 0) # Flip the sprite here
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


# Handles jumping and jump cutting
func _handle_jump(delta):
	# Don't allow jumping during a heavy attack
	if state_machine.get_current_node() == "heavyattack":
		return
		
	# 1. Grant coyote time if we are on the floor
	if is_on_floor():
		coyote_jump = true
		
	# 2. If we are in the air AND we still have coyote time, start the timer
	elif not is_on_floor() and coyote_jump == true:
		if jump_timer.is_stopped():
			jump_timer.start()

	# 3. Handle the jump action
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_jump == true):
		coyote_jump = false
		velocity.y = init_JUMP_VELOCITY
		jump_sound.play()
		jump_timer.stop() # Stop the timer since we jumped
	
	# 4. Variable jump height (boost)
	if Input.is_action_pressed("jump") and velocity.y < 0:
		velocity.y += mid_JUMP_VELOCITY * delta
	
	# 5. Apex/Fall control
	if abs(velocity.y) < 100:
		velocity.y += 100 * delta
		

# Handles rolling
func _handle_roll():
	if Input.is_action_just_pressed("roll"):
		pass # TODO: state_machine.travel("roll")


# Handles all attack inputs and combo buffering
func _handle_attacks():
	var current_state = state_machine.get_current_node()
	var is_attacking = (current_state == "lightattack" or current_state == "heavyattack" or current_state == "lightattackplus")
	
	# --- 1. Handle Attack Buffering ---
	# If we are *already* attacking, check if the player wants to queue a combo
	if is_attacking and animation_player.is_playing():
		if Input.is_action_just_pressed("lightattack"):
			combo_queued = true
			combo_timer.start()
		return # Stop here, don't start a new attack
	
	# --- 2. Handle New Attacks ---
	# If we are *not* attacking, check for a new attack input
	if Input.is_action_just_pressed("lightattack"):
		state_machine.travel("lightattack")
		combo_queued = false # Clear any old combo
	elif Input.is_action_just_pressed("heavyattack") and is_on_floor():
		state_machine.travel("heavyattack")
		combo_queued = false # Clear any old combo


# Chooses the correct *movement* animation based on the character's state
func _update_animation():
	# --- 1. Let Attacks Play Out ---
	# If we are in an attack state, don't let movement animations override it.
	# The state machine will handle returning to "idle" when the attack finishes.
	var current_state = state_machine.get_current_node()
	if (current_state == "lightattack" or current_state == "heavyattack" or current_state == "lightattackplus"):
		return

	# --- 2. Handle Movement Animations ---
	if not is_on_floor():
		if velocity.y < 0:
			state_machine.travel("jumpUp")
		else:
			state_machine.travel("jumpDown")
	else:
		# On the floor
#		if is_rolling:
#			state_machine.travel("roll")
#		else:
		if velocity.x != 0:
			state_machine.travel("run")
		else:
			state_machine.travel("idle")

# --- Signal Callbacks ---

func _on_jump_timer_timeout() -> void:
	coyote_jump = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# This function now handles all combo logic
	match anim_name:
		"lightattack":
			if combo_queued:
				state_machine.travel("lightattackplus")
				combo_queued = false # Consume the queued combo
			# If no combo, the AnimationTree will automatically go back to "idle"
			# (assuming you connected the "lightattack" state back to "idle")

		"lightattackplus":
			_on_combo_timer_timeout() # Reset combo
			
#		"heavyattack": # TODO heavyattackplus
#			if combo_queued:
#				state_machine.travel("lightattack")
#				combo_queued = false # Consume the queued combo


func _on_combo_timer_timeout() -> void:
	combo_queued = false
