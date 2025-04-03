extends Node2D

@onready var attack: Button = $CanvasLayer/action/Attack
@onready var defend: Button = $CanvasLayer/action/Defend
@onready var spell1: Button = $CanvasLayer/action/Arcane_Piercer
@onready var spell2: Button = $CanvasLayer/action/Arcane_Blast
@onready var mark: Button = $CanvasLayer/action/Mark
@onready var strike1: Button = $CanvasLayer/action/Strike
@onready var strike2: Button = $CanvasLayer/action/Combo_Strike

@onready var actionPanel = $CanvasLayer/action
@onready var enemyPanel = $CanvasLayer/enemy

@onready var e_wiz_target = $character/EnemyGroup/enemy_wizard/Container/Button
@onready var e_fight_target = $character/EnemyGroup/enemy_fighter/Container/Button
@onready var e_heal_target = $character/EnemyGroup/enemy_healer/Container/Button

@onready var nextPress = $CanvasLayer/MarginContainer/nextPress

@onready var announcementText = $CanvasLayer/MarginContainer/GamePhaseAnnouncer

var playerCast = ['wizard', 'fighter', 'assassin', 'tank']
var enemyCast = ['enemy_wizard','enemy_fighter','enemy_healer']

# healthbars
@onready var wizard_hp = $character/player_group/wizard/ProgressBar
@onready var assassin_hp = $character/player_group/assassin/ProgressBar
@onready var fighter_hp = $character/player_group/fighter/ProgressBar
@onready var tank_hp = $character/player_group/tank/ProgressBar
@onready var e_wizard_hp = $character/EnemyGroup/enemy_wizard/healthbar
@onready var e_fighter_hp = $character/EnemyGroup/enemy_fighter/healthbar
@onready var e_healer_hp = $character/EnemyGroup/enemy_healer/healthBar

class character:
	var charName
	var isAlive = true
	var stats = {
		"health" : 100,
		"max_health" : 100,
		"defense" :30,
		"attack" : 20,
		"speed" : 10
	}
	
	var effects = {
		"weakened" : {"strength" : -10, "duration": 0},
		"shattered" : {"strength" : -30, "duration": 0},
		"mark" : {"strength" : 0, "duration": 0},
		"defend" : {"strength" : 20, "duration": 0}
	}
	
	func takeDamage(incoming_dmg:int):
		# incoming damage is calculated by the system
		# computation how much damage is received given the effects
		var apparentDamage = incoming_dmg-(stats['defense']+(effects["defend"]["strength"]*int(effects["defend"]["duration"]>0))-(effects['shattered']['strength']*int(effects['shattered']['duration']>0)))
		if apparentDamage <= 0:
			apparentDamage = 0
		stats['health']-= apparentDamage			
		return apparentDamage
		
	func takeHealing(incomingHeal:int):
		# no reduction or any hacky way.
		stats['health']+=incomingHeal
		
		if stats['health'] > stats['max_health']:
			stats['health'] = stats['max_health']
	
	func consumeDurationEffect(): # done at the end of a round
		for key in effects.keys():
			if effects[key]['duration'] > 0:
				effects[key]['duration'] -= 1
	
	func endlife():
		isAlive = false

class wizard extends character:
	var mana = 100
	var actions = ['arcane_blast','arcane_piercer','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
		
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'arcane_blast':
				mana-=20
				return stats['attack']*0.5
			elif spell == 'arcane_piercer':
				mana-=15
				return stats['attack']*1.5
			elif spell =='defend':
				# apply an effect to yourself
				effects['defend']['duration'] = 1
				mana+=30

class tank extends character:
	var protect_chance = 0.5
	var actions = ['attack','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
		
	func roll_protect():
		var rng = RandomNumberGenerator.new()
		var a = rng.randf()
		if a < protect_chance:
			return true
		else:
			return false 
	
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'attack':
				return stats['attack']
			elif spell == 'defend':
				effects['defend']['duration']=1

class fighter extends character:
	var combo = 0
	var actions = ['strike','combo_strike','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
	
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'strike':
				combo+=1
				return stats['attack']
			elif spell == 'combo_strike':
				var outDMG = (stats['attack']*0.2)+(combo*20)
				combo=0
				return outDMG
			elif spell == 'defend':
				effects['defend']['duration']=1
	
class assassin extends character:
	var actions = ['attack','mark']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
	
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'attack':
				return stats['attack']
			elif spell == 'mark':
				return 1

class enemy_healer extends character:
	var actions = ['heal','defend']
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
	
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'heal':
				return stats['attack']
			elif spell == 'defend':
				effects['defend']['duration']=1
		
class enemy_fighter extends character:
	var actions = ['attack','defend']
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
	
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'attack':
				return stats['attack']
			elif spell == 'defend':
				effects['defend']['duration']=1
		
class enemy_wizard extends character:
	var mana = 100
	var actions = ['arcane_blast','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		stats['health'] = hp
		stats['max_health'] = hp
		stats['defense'] = def
		stats['attack'] = atk
		stats['speed'] = sp
		charName = c_name
	
	func action(spell:String):
		if spell not in actions:
			print("how did this happen")
		else:
			if spell == 'arcane_blast':
				mana -= 20
				return stats['attack']
			elif spell == 'defend':
				mana += 30
				effects['defend']['duration']=1
	
var player_wizard
var player_tank
var player_assassin
var player_fighter
var e_wizard
var e_fighter
var e_healer
var cast


# game variables
var player_selecting = true
var select_phase = 0 # 0: select ability, 1: select target, 2: wind up, 3: results
var select_phase_ai = 0 # 0: ability-target-windup, 1: results 
var turn_queue = []
var turn_pointer

var current_character_turn
var selected_target = null
var current_char_action
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_wizard = wizard.new(80,40,15,2,'wizard')
	player_tank = tank.new(120,20,30,1,'tank')
	player_assassin = assassin.new(60,2,8,3,'assassin')
	player_fighter = fighter.new(100,30,20,2,'fighter')
	e_wizard = enemy_wizard.new(80,40,15,2,'enemy_wizard')
	e_fighter = enemy_fighter.new(100,30,20,2,'enemy_fighter')
	e_healer = enemy_healer.new(75,50,10,2,'enemy_healer')
	cast = {
		'wizard' : player_wizard,
		'assassin' : player_assassin,
		'tank' : player_tank,
		'fighter' : player_fighter,
		'enemy_fighter' : e_fighter,
		'enemy_healer' : e_healer,
		'enemy_wizard' : e_wizard,
	}
	populate_queue()
	turn_pointer = 0
	current_character_turn = turn_queue[turn_pointer]
	
	# character actions
	set_clickable_action()
	attack.pressed.connect(
		func attack_pressed():
		print("Attack pressed")
		current_char_action = "attack"
		select_phase = 1
		gameUpdate()
		)
	defend.pressed.connect(
		func defend_pressed():
		print("defend pressed")
		current_char_action = "defend"
		selected_target = null
		select_phase = 2
		gameUpdate()
		)
	mark.pressed.connect(
		func mark_pressed():
		print("mark pressed")
		current_char_action = "mark"
		select_phase = 1
		gameUpdate()
		)
	spell1.pressed.connect(
		func spell1_pressed():
		print("spell1 pressed")
		current_char_action = "arcane_piercer"
		select_phase = 1
		gameUpdate()
		)
	spell2.pressed.connect(
		func spell2_pressed():
		print("spell2 pressed")
		current_char_action = "arcane_blast"
		select_phase = 1
		gameUpdate()
		)
	strike1.pressed.connect(
		func strike1_pressed():
		print("strike1 pressed")
		current_char_action = "strike"
		select_phase = 1
		gameUpdate()
		)
	strike2.pressed.connect(
		func strike2_pressed():
		print("strike2 pressed")
		current_char_action = "combo_strike"
		select_phase = 1
		gameUpdate()
		)
	
	e_wiz_target.pressed.connect(
		func e_wiz_target_pressed():
		print("e_wiz_target pressed")
		selected_target = "enemy_wizard"
		select_phase = 2
		gameUpdate()
	)
	e_heal_target.pressed.connect(
		func e_heal_target_pressed():
		print("e_heal_target pressed")
		selected_target = "enemy_healer"
		select_phase = 2
		gameUpdate()
	)
	e_fight_target.pressed.connect(
		func e_fight_target_pressed():
		print("e_fight_target pressed")
		selected_target = "enemy_fighter"
		select_phase = 2
		gameUpdate()
	)
	nextPress.pressed.connect(
		func nextP():
		print("next pressed ", select_phase, turn_queue[turn_pointer])
		if select_phase == 1:
			setAction()
			select_phase += 1
		elif select_phase == 2 and current_character_turn in playerCast:
			# this is where the action is calculated
			setAction()
			select_phase += 1
		elif select_phase == 2 and current_character_turn in enemyCast:
			nextTurn()
			gameUpdate()
		elif select_phase == 3:
			nextTurn()
			gameUpdate()
		
	)
	
	# attach heroes to their respective healthbars
	wizard_hp.max_value = cast['wizard'].stats['max_health']
	e_wizard_hp.max_value = cast['enemy_wizard'].stats['max_health']
	fighter_hp.max_value = cast['fighter'].stats['max_health']
	e_fighter_hp.max_value = cast['enemy_fighter'].stats['max_health']
	e_healer_hp.max_value = cast['enemy_healer'].stats['max_health']
	tank_hp.max_value = cast['tank'].stats['max_health']
	assassin_hp.max_value = cast['assassin'].stats['max_health']
	
	gameUpdate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in cast.keys():
		if cast[key].stats['health'] <= 0 and cast[key].isAlive:
			cast[key].endlife()
			announcementText.text += '\n' + key + " has perished."
	if !cast[current_character_turn].isAlive:
		nextTurn()
		gameUpdate()
		
	# attach heroes to their respective healthbars
	wizard_hp.value = cast['wizard'].stats['health']
	e_wizard_hp.value = cast['enemy_wizard'].stats['health']
	fighter_hp.value = cast['fighter'].stats['health']
	e_fighter_hp.value = cast['enemy_fighter'].stats['health']
	e_healer_hp.value = cast['enemy_healer'].stats['health']
	tank_hp.value = cast['tank'].stats['health']
	assassin_hp.value = cast['assassin'].stats['health']
	
	checkLife()
	
func action(attacker, target, action: String):
	if(attacker.charName == 'assassin'):
		# mark enemy
		if(action=='mark'):
			target.effects['mark']['strength'] += attacker.action('mark')
			target.effects['mark']['duration'] = 99
			announcementText.text += '\n' + target.charName + " marked" 
		# check for target marks
		elif(action=='attack'):
			var damageDealt = pow(attacker.action('attack'),target.effects['mark']['strength'])
			var actual_damage = target.takeDamage(damageDealt)
			announcementText.text += "\ndealt " + str(actual_damage) + " damage to " + (target.charName)
	elif(attacker.charName == 'fighter'):
		if(action == 'strike'):
			var damageDealt = attacker.action('strike')
			target.takeDamage(damageDealt)
			announcementText.text += "\ndealt " + str(damageDealt) + " damage to " + (target.charName)
		elif(action == 'combo_strike'):
			var damageDealt = attacker.action('combo_strike')
			target.takeDamage(damageDealt)
			announcementText.text += "\ndealt " + str(damageDealt) + " damage to " + (target.charName)
		elif(action == 'defend'):
			attacker.action('defend') # just to get the def up for this round
			announcementText.text += '\n' + (attacker.charName) + "'s defense rose"
	elif(attacker.charName == 'tank'):
		if(action == 'attack'):
			var damageDealt = attacker.action('attack')
			target.takeDamage(damageDealt)
			announcementText.text += "\ndealt " + str(damageDealt) + " damage to " + (target.charName)
		elif(action == 'defend'):
			attacker.action('defend')
			announcementText.text += '\n' + (attacker.charName) + "'s defense rose"
	elif(attacker.charName == 'wizard'):
		if(action == 'arcane_blast'):
			var incoming = attacker.action('arcane_blast')
			e_wizard.takeDamage(incoming)
			e_fighter.takeDamage(incoming)
			e_healer.takeDamage(incoming)
			announcementText.text = "dealt " + str(incoming) + " damage to " + (e_wizard.charName) + "\ndealt " + str(incoming) + " damage to " + (e_healer.charName) + "\ndealt " + str(incoming) + " damage to " + (e_fighter.charName)
		elif(action == 'arcane_piercer'):
			var damageDealt = attacker.action("arcane_piercer")
			target.takeDamage(damageDealt)
			announcementText.text += "\ndealt " + str(damageDealt) + " damage to " + (target.charName)
		elif(action == 'defend'):
			attacker.action('defend')
			announcementText.text += '\n' + (attacker.charName) + "'s defense rose"
	elif(attacker.charName == 'enemy_healer'):
		if(action=='heal'):
			var damageDealt = attacker.action("heal")
			target.takeHealing(damageDealt)
			announcementText.text += '\n' + (attacker.charName) + " healed " + (target.charName)
		elif(action == 'defend'):
			attacker.action('defend')
			announcementText.text += '\n' + (attacker.charName) + "'s defense rose"
	elif(attacker.charName == 'enemy_wizard'):
		if(action=='arcane_blast'):
			var damageDealt = attacker.action("arcane_blast")
			player_wizard.takeDamage(damageDealt)
			player_fighter.takeDamage(damageDealt)
			player_tank.takeDamage(damageDealt)
			player_assassin.takeDamage(damageDealt)
			announcementText.text = "dealt " + str(damageDealt) + " damage to " + (player_wizard.charName) + "\ndealt " + str(damageDealt) + " damage to " + (player_fighter.charName) + "\ndealt " + str(damageDealt) + " damage to " + (player_tank.charName) + "\ndealt " + str(damageDealt) + " damage to " + (player_assassin.charName)

		elif(action == 'defend'):
			attacker.action('defend')
			announcementText.text += '\n' + (attacker.charName) + "'s defense rose"
			
	elif(attacker.charName == 'enemy_fighter'):
		if(action=='attack'):
			var damageDealt = attacker.action('attack')
			target.takeDamage(damageDealt)
			announcementText.text += "\ndealt " + str(damageDealt) + " damage to " + (target.charName)
			
		elif(action == 'defend'):
			attacker.action('defend')
			announcementText.text += '\n' + (attacker.charName) + "'s defense rose"

func populate_queue():
	var returnQ = []
	# sort everyone by speed
	var cast_speed = {}
	for key in cast.keys():
		cast_speed[key] = cast[key].stats['speed']
		
	var a = cast_speed.keys()
	var all_zero = false
	while not all_zero:
		all_zero=true
		for key in a: #keeps iterating through the list until all are zero
			if cast_speed[key] > 0:
				all_zero = false
				returnQ.append(key)
				cast_speed[key]-=1
	turn_queue = returnQ
	
func set_clickable_action():
	var enemyButtons = [e_fight_target, e_wiz_target, e_heal_target]
	# disable everything first
	for i in actionPanel.get_children():
		i.visible = false
	
	for i in enemyButtons:
		i.visible = false
		
	nextPress.disabled = true
		
	
	if select_phase == 0  and (current_character_turn in ['wizard','fighter','assassin','tank']):
		# set the clickable actions depending on who is moving
		if current_character_turn == 'wizard':
			defend.visible = true
			# mana restrictions
			if player_wizard.mana > 20:
				spell2.visible = true
			if player_wizard.mana > 15:
				spell1.visible = true
		elif current_character_turn == 'tank':
			defend.visible = true
			attack.visible = true
		elif current_character_turn == 'fighter':
			defend.visible = true
			strike1.visible = true
			strike2.visible = true
		elif current_character_turn == 'assassin': 
			attack.visible = true
			mark.visible = true
	elif select_phase == 1 and (current_character_turn in ['wizard','fighter','assassin','tank']):
		if e_fighter.isAlive:
			e_fight_target.visible = true
		if e_wizard.isAlive:
			e_wiz_target.visible = true
		if e_healer.isAlive:
			e_heal_target.visible = true
	elif select_phase >= 2 or (current_character_turn not in ['wizard','fighter','assassin','tank']):
		nextPress.disabled = false
	pass

func ai_select_target(ai_name:String):
	if ai_name == 'enemy_fighter':
		pass
	elif ai_name == 'enemy_wizard':
		pass
	elif ai_name == 'enemy_healer':
		pass 

func gameUpdate():
	# starting a turn
	print(current_character_turn, select_phase)
	if current_character_turn in ['wizard', 'tank', 'fighter', 'assassin']:
		if select_phase == 0:
			#print(current_character_turn," is currently selecting an action")
			announcementText.text = (current_character_turn) + " is currently selecting an action"
		elif select_phase == 1:
			announcementText.text = (current_character_turn) + " is using " + (current_char_action)
		elif select_phase == 2 and selected_target != null:
			announcementText.text = (current_character_turn) + " is using " + (current_char_action) + " on " + String(selected_target)
		elif select_phase == 2 and selected_target == null:
			announcementText.text = (current_character_turn) + " is using " + (current_char_action)
		
	else: #random ai
		var rng
		var charAI
		var action
		var target
		if select_phase == 0:
			rng = RandomNumberGenerator.new()
			charAI = cast[current_character_turn]
			print(charAI.actions)
			action = charAI.actions[rng.randi_range(0,len(charAI.actions)-1)]
			if action == 'defend':
				target = null
				announcementText.text = (current_character_turn) + " is using " + (action)
			elif action == 'heal':
				rng = RandomNumberGenerator.new()
				target = enemyCast[rng.randi_range(0,len(enemyCast)-1)]
				announcementText.text = (current_character_turn) + " is using " + (action) + " on " + (target)
			else:
				rng = RandomNumberGenerator.new()
				target = playerCast[rng.randi_range(0,len(playerCast)-1)]
				announcementText.text = (current_character_turn) + " is using " + (action) + " on " + (target)
			current_char_action = action
			selected_target = target
			select_phase = 1
		elif select_phase == 1:
			setAction()
	set_clickable_action()

func nextTurn():
	select_phase = 0
	if turn_pointer == len(turn_queue) - 1:
		print("ROUND HAS ENDED")
		print(turn_queue)
		roundEnd();
		turn_pointer = 0
		current_character_turn = turn_queue[turn_pointer]
	else:
		turn_pointer += 1
		current_character_turn = turn_queue[turn_pointer]

func roundEnd():
	player_assassin.consumeDurationEffect()
	player_wizard.consumeDurationEffect()
	player_tank.consumeDurationEffect()
	player_fighter.consumeDurationEffect()
	e_wizard.consumeDurationEffect()
	e_fighter.consumeDurationEffect()
	e_healer.consumeDurationEffect()

func setAction():
	# checks if the tank can defend the incoming attack
	print(current_char_action, selected_target)
	if ((player_tank.isAlive and (current_character_turn in ['enemy_fighter','enemy_healer','enemy_wizard'])) and (current_char_action not in ['heal','arcane_blast','defend'])):
		if player_tank.roll_protect():
			print("tank protects ", selected_target)
			announcementText.text += "\ntank protects " + (selected_target)
			selected_target = player_tank.charName
	if selected_target in cast.keys():
		print("in key")
		action(cast[current_character_turn], cast[selected_target], current_char_action)
	else: 
		print("not in key")
		action(cast[current_character_turn], null, current_char_action)
		
func checkLife():
	for key in cast.keys():
		if !cast[key].isAlive:
			playerCast.erase(key)
			enemyCast.erase(key)
	if len(playerCast) == 0:
		announcementText.text = "YOU LOSE!"
	elif len(enemyCast) == 0:
		announcementText.text = "YOU WIN!"
		
