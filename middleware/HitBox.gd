class_name PlayerHitBox
extends Area2D

@export var hitbox_damage: int = 1

func get_character_parent(node: Node) -> CharacterBody2D:
	while not node is CharacterBody2D:
		node = node.get_parent()
	return node

var rng = RandomNumberGenerator.new()

func get_final_damage(character: BasicCharacterStats):
	return round(rng.randf_range(character.attack_damage_consistency, 1) * character.attack_damage * hitbox_damage) 

func do_damage(hurt_box: HurtBox) -> void:
	var character = get_character_parent(self)
	if character.has_method("toggle_air_attack_hit"):
		character.toggle_air_attack_hit(true)
	if character is BasicCharacterStats:
		hurt_box.do_damage(get_final_damage(character), global_position - hurt_box.global_position)

func _ready() -> void:
	connect("area_entered", do_damage)
	pass

