extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var focus: Sprite2D = $focus
@onready var health_bar: ProgressBar = $HealthBar
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var MAX_HEALTH: float = 100

var health: float = 100:
	set(value):
		_update_progress_bar()
		_play_animation()

func _update_progress_bar():
	health_bar.value = (health/MAX_HEALTH) * 100

func _play_animation():
	animated_sprite_2d.play("hurt")
	
func _focus():
	focus.show()
	
func _unfocus():
	focus.hide()

func take_damage(value):
	health -= value
