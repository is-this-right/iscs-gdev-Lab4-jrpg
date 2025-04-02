extends Node2D

var enemies: Array = []
var queue: Array = []
var index: int = 0
var is_battling: bool = false

signal next_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].position = Vector2(0, i*32)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		if index > 0:
			index -= 1
			switch_focus(index, index+1)
	if Input.is_action_just_pressed("ui_down"):
		if index < enemies.size() - 1:
			index += 1
			switch_focus(index, index-1)
	if Input.is_action_just_pressed("ui_accept"):
		queue.push_back(index)
		emit_signal("next_player")
	if queue.size() == enemies.size() and not is_battling:
		is_battling = true

func switch_focus(focus, unfocus):
	enemies[focus].focus()
	enemies[unfocus].unfocus()
