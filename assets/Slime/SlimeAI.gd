extends PlatformerController2D

@export var is_active = false
@export var minimum_follow_distance = 200 #using manhattan distance

func apply_friction(delta):
	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))

func get_distance() -> float:
	if not PlayerMovement.player_movement_node:
		return INF
	var distance_vec = abs(PlayerMovement.player_movement_node.global_position - global_position)
	return distance_vec.x + distance_vec.y

func check_player_distance() -> void:
	if get_distance() <= minimum_follow_distance && !is_active:
		slime_animation_player.play("Slime/appear")

func follow_player(_delta: float) -> void:
	if !is_active:
		return
	acc.x = 0
	if get_distance() <= minimum_follow_distance:
		if PlayerMovement.player_movement_node.global_position.x < global_position.x:
			acc.x = -max_acceleration	
		if PlayerMovement.player_movement_node.global_position.x > global_position.x:
			acc.x = max_acceleration

func process_physics(delta):
	follow_player(delta)
	if is_coyote_timer_running() or current_jump_type == JumpType.NONE:
		jumps_left = max_jump_amount
	if is_feet_on_ground() and current_jump_type == JumpType.NONE:
		start_coyote_timer()
		
	# Check if we just hit the ground this frame
	if not _was_on_ground and is_feet_on_ground():
		current_jump_type = JumpType.NONE
		if is_jump_buffer_timer_running() and not can_hold_jump: 
			jump()
		
		hit_ground.emit()
	
	if is_on_wall() && acc.x != 0:
		start_jump_buffer_timer()
	
	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity
	
	apply_friction(delta)
	velocity += acc * delta
	
	_was_on_ground = is_feet_on_ground()
	move_and_slide()

@onready var slime_state_chart: StateChart = $"../StateChart"
@onready var slime_animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var slime_animation_player: AnimationPlayer = $AnimationPlayer

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	slime_state_chart.send_event("AnimationFinished")

func _on_idle_state_entered() -> void:
	slime_animation_player.play("Slime/appear")
	slime_animation_player.stop()
	if is_active:
		slime_state_chart.send_event("SlimeRun")

func _on_idle_state_physics_processing(delta: float) -> void:
	process_physics(delta)
	check_player_distance()

func _on_idle_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		is_active = true
		slime_state_chart.send_event("SlimeRun")

func _on_ground_attack_state_entered() -> void:
	slime_animation_player.play("Slime/appear")

func _on_ground_attack_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		slime_state_chart.send_event("SlimeRun")

func _on_run_state_entered() -> void:
	is_active = true
	slime_animation_player.play("Slime/run")

func _on_run_state_physics_processing(delta: float) -> void:
	process_physics(delta)
	if get_distance() <= minimum_follow_distance:
		slime_animation_player.play("Slime/run")
	else:
		slime_animation_player.play("Slime/idle")


func _on_hurt_state_entered() -> void:
	slime_animation_player.play("Slime/hurt")

func _on_hurt_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		slime_state_chart.send_event("SlimeRun")
	if event == "SlimeHurt":
		slime_animation_player.seek(0)

func _on_death_state_entered() -> void:
	slime_animation_player.play("Slime/death")

func _on_death_event_received(event: StringName) -> void:
	if event == "AnimationFinished":
		queue_free()


func _on_hit_point_depleted() -> void:
	slime_state_chart.send_event("SlimeDeath")

func _on_on_hit(damage: int, direction_vector: Vector2) -> void:
	slime_state_chart.send_event("SlimeHurt")


func _on_face_left_state_entered() -> void:
	slime_animated_sprite.scale.x = -1
	$CollisionShape2D.position.x = abs($CollisionShape2D.position.x)

func _on_face_left_state_processing(delta: float) -> void:
	if acc.x > 0:
		slime_state_chart.send_event("SlimeRight")

func _on_face_right_state_entered() -> void:
	slime_animated_sprite.scale.x = 1
	$CollisionShape2D.position.x = -abs($CollisionShape2D.position.x)

func _on_face_right_state_processing(delta: float) -> void:
	if acc.x < 0:
		slime_state_chart.send_event("SlimeLeft")

