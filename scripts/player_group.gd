extends Node2D

var players: Array = []
@onready var enemy_group = $EnemyGroup
var index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(i, i*32)
		enemy_group.next_player.connect(_on_enemy_group_next_player)

func _on_enemy_group_next_player():
	if index < players.size() - 1:
		index += 1
		switch_focus(index, index - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func switch_focus(focus, unfocus):
	players[focus].focus()
	players[unfocus].unfocus()

func _process(delta: float) -> void:
	pass
