class_name HurtBox
extends Area2D

func get_character_parent(node: Node) -> CharacterBody2D:
	while node.get_class() != "CharacterBody2D":
		node = node.get_parent()
	return node

func do_damage(damage: int, direction_vector: Vector2) -> void:
	var character: CharacterBody2D = get_character_parent(self)
	if character is BasicCharacterStats:
		character.take_damage(damage, direction_vector)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
