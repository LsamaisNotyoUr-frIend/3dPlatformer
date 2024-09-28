extends CharacterBody3D


const SPEED = 150.0
const JUMP_VELOCITY = 30
var facing_angle: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animation_player = $Mixamo/AnimationPlayer
@onready var dash_timer = $DashTimer
@onready var idle_timer = $IdleTimer
@onready var character_placholder = $"."
@onready var mixamo = $Mixamo
@onready var collision_shape_3d = $"../Area3D/CollisionShape3D"

var isIdle = false
var isDashing = true
var isRunning = false
var input_duration = 0.0
var anim_speed_walk = 1.0
var anim_speed_run = 2.0


func _ready():
	animation_player.play("Landing")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * 100
		

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		idle_timer.stop
		isIdle = false
		animation_player.play("Jump")
		velocity.y = JUMP_VELOCITY * 100 * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("lookUp", "LookDown", "Left", "Right")
	var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if (Input.is_action_just_pressed("Right") and isRunning) or (Input.is_action_just_pressed("Right") and isRunning):
		idle_timer.stop()
		animation_player.stop()
		input_duration += delta
		isIdle = false
		isRunning = true  # Now we are in running state
		animation_player.play("Running")
		animation_player.seek(input_duration * anim_speed_run, true)

	# Handle walking
	elif (Input.is_action_just_pressed("Left") and !isRunning):
		idle_timer.stop()
		animation_player.stop()
		input_duration += delta
		isIdle = false
		isRunning = false  # Now we are in walking state
		animation_player.play("Walking")
		animation_player.seek(input_duration * anim_speed_walk, true)
	
	elif (Input.is_action_just_pressed("Right") and !isRunning):
		idle_timer.stop()
		animation_player.stop()
		input_duration += delta
		isIdle = false
		isRunning = false
		animation_player.play("Walking")
		animation_player.seek(input_duration * anim_speed_walk, true)

	# Handle stopping animation when key is released
	if Input.is_action_just_released("Right") or Input.is_action_just_released("Left"):
		input_duration = 0.0
		animation_player.stop()
		isIdle = true
		idle_timer.start()
		isRunning = false
		
	if Input.is_action_just_pressed("Dash"):
		idle_timer.stop()
		isIdle = false
		dash_timer.start() 
		
	if isIdle:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
	else:
		if animation_player.current_animation == "Idle":
			animation_player.stop()
		

	move_and_slide()
	
	facing_angle = Vector2(input_dir.y, input_dir.x).angle()
	
	
	if input_dir.length() > 0:
		mixamo.rotation.y = lerp_angle(mixamo.rotation.y, facing_angle, 0.3)
		
	idle_timer.start()


func _on_dash_timer_timeout():
	isRunning = true


func _on_idle_timer_timeout():
	isIdle = true

func _on_dash_reset_timeout():
	isDashing = false
	
func reset_idle_state():
	if isIdle:
		isIdle = false
	if !idle_timer.is_stopped():
		idle_timer.stop()  # Stop the idle timer when the player starts moving again

func _on_area_3d_body_entered(body):
	character_placholder.queue_free()
	get_tree().reload_current_scene()
