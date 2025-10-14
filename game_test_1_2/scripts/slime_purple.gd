extends Node2D

const SPEED = 40

var direction = 1

@onready var ray_left: RayCast2D = $RayCast2D_left
@onready var ray_right: RayCast2D = $RayCast2D_right
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_left.is_colliding(): # if collide on left, direction changes to right
		direction = 1
		animated_sprite.flip_h = direction < 0
		
	if ray_right.is_colliding(): # if collide on right, direction changes to left
		direction = -1
		animated_sprite.flip_h = direction < 0
		
	position.x += direction * SPEED * delta * 1.5
	
