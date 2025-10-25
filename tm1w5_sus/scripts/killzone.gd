extends Area2D

@onready var timer: Timer = $Timer
@onready var hurt_sound: AudioStreamPlayer2D = $hurtSound
@onready var player: Area2D = $"."

func _on_body_entered(body):
	hurt_sound.play()
	body.get_node("CollisionShape2D").queue_free()
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
