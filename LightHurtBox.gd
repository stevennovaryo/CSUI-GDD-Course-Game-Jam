class_name LightHurtBox
extends Area2D

func _init() -> void:
	monitoring = false
	monitorable = true
	collision_layer = 4
	collision_mask = 8

func get_light_source_parent(node: Node) -> LightSource:
	while not node is LightSource:
		node = node.get_parent()
	return node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
