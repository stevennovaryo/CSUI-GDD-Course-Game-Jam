extends Node2D
class_name GameOverOverlay

@onready var player_node: PlayerNode = $"../CanvasModulate/Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_node:
		global_position = player_node.get_child(0).global_position

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "on_appear":
		get_tree().reload_current_scene()


signal player_died

func _on_player_player_died() -> void:
	player_died.emit()


func _on_area_2d_area_entered(area: HurtBox) -> void:
	get_tree().change_scene_to_file("res://assets/Slime/finishScreen.tscn")
