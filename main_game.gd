extends Node2D

class character: #each c
	var health
	var defense
	var speed
	var defense_debuff = 0
	var defense_buff = 0
	var charName = ""
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		speed = sp
		charName = c_name
		
	func takeDamage(dmg:int):
		health-=(dmg-(defense+defense_buff-defense_debuff))
	
	func end_turn():
		defense_buff=0

class wizard extends character:
	var mana = 100
	var atk
	var actions = ['arcane_blast','arcane_piercer','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		atk=atk
		speed = sp
		charName = c_name
	
	func spell_all():
		mana-=20
		return atk*0.5
	
	func spell_one():
		mana-=15
		return atk*1.5
	
	func defend():
		defense_buff=10
		mana+=30

class tank extends character:
	var atk
	var actions = ['attack','defend']
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		atk=atk
		speed = sp
		charName = c_name
	
	func defend():
		defense_buff=30
	
	func attack():
		return atk
		
	func defendAlly():
		defense_buff=20

class fighter extends character:
	var atk
	var combo = 0
	var actions = ['strike','combo_strike','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		atk=atk
		speed = sp
		charName = c_name
		
	func attack1():
		combo+=1
		return atk
	
	func attack2():
		var combo_multiplier = combo
		combo=0
		return atk*combo_multiplier
		
	func defend():
		defense_buff=15
	
class assassin extends character:
	var atk
	var actions = ['attack','mark']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		atk=atk
		speed = sp
		charName = c_name
	
	func attack():
		return atk

class enemy_healer extends character:
	var mark = 0
	var atk
	var actions = ['heal','defend']
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		speed = sp
		charName = c_name
		
	func heal():
		return -atk
	
	func defend():
		defense_buff = 25
		
class enemy_fighter extends character:
	var mark = 0
	var atk
	var actions = ['attack','defend']
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		speed = sp
		atk=atk
		charName = c_name
		
	func attack():
		return atk
		
class enemy_wizard extends character:
	var mana = 100
	var mark = 0
	var atk
	var actions = ['spell','defend']
	
	func _init(hp: int, atk:int, def:int, sp:int, c_name:String):
		health = hp
		defense = def
		atk=atk
		speed = sp
		charName = c_name
		
	func spell_all():
		mana-=20
		return atk*0.5
	
	func defend():
		defense_buff=10
		mana+=30
	

var player_wizard
var player_tank
var player_assassin
var player_fighter
var e_wizard
var e_fighter
var e_healer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_wizard = enemy_wizard.new(80,40,15,2,'wizard')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func action(attacker, target, action):
	if(attacker.charName == 'assassin'):
		# mark enemy
		if(action=='mark'):
			target.mark+=1
		# check for target marks
		elif(action=='attack'):
			var damageDealt = pow(attacker.attack(),target.mark)
			target.takeDamage(damageDealt)
	elif(attacker.charName == 'fighter'):
		if(action == 'strike'):
			var damageDealt = attacker.attack_1()
			target.takeDamage(damageDealt)
		elif(action == 'combo_strike'):
			var damageDealt = attacker.attack_2()
			target.takeDamage(damageDealt)
	elif(attacker.charName == 'tank'):
		if(action == 'attack'):
			var damageDealt = attacker.attack()
			target.takeDamage(damageDealt)
	elif(attacker.charName == 'wizard'):
		if(action == 'arcane_blast'):
			#damage all enemies
			pass
		elif(action == 'arcane_piercer'):
			var damageDealt = attacker.spell_one()
			target.takeDamage(damageDealt)
	elif(attacker.charName == 'enemy_healer'):
		if(action=='heal'):
			var damageDealt = attacker.heal()
			target.takeDamage(damageDealt)
	elif(attacker.charName == 'enemy_wizard'):
		if(action=='spell'):
			var damageDealt = attacker.spell_all()
			target.takeDamage(damageDealt)
	elif(attacker.charName == 'enemy_fighter'):
		if(action=='attack'):
			var damageDealt = attacker.attack()
			target.takeDamage(damageDealt)
	
	pass
