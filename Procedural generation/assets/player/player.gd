extends KinematicBody

var speed
var sensitivity = 0.3
var camera_angle_x = 0
var walking = true

var velocity = Vector3()

#fly
const FLY_SPEED = 20
const FLY_ACCEL = 4

#walk
var gravity = 9.8 * 1
const MAX_SPEED = 20
const MAX_RUNNING_SPEED = 30
const ACCEL = 4
const DEACCEL = 8

#jump
const JUMP_HEIGHT = 5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	print(translation.y)
	if walking:
		walk()
	else:
		fly()
	move_and_slide(velocity, Vector3.UP)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$head.rotate_y(deg2rad(event.relative.x * sensitivity * -1))
		
		var x_angle_change = event.relative.y * sensitivity * -1
		if camera_angle_x + x_angle_change < 90 && camera_angle_x + x_angle_change > -90:
			$head/Camera.rotate_x(deg2rad(x_angle_change))
			camera_angle_x += x_angle_change

func fly():
	#reset direction of the player
	var direction = Vector3()
	
	#get camera rotation
	var aim = $head/Camera.get_global_transform().basis
	
	#get input and change direction
	if Input.is_action_pressed("left"):
		direction -= aim.x
	elif Input.is_action_pressed("right"):
		direction += aim.x
	if Input.is_action_pressed("forward"):
		direction -= aim.z
	elif Input.is_action_pressed("backward"):
		direction += aim.z
	
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * FLY_SPEED, FLY_ACCEL * get_physics_process_delta_time())
	
func walk():
	#reset direction of the player
	var direction = Vector3()
	
	#get camera rotation
	var aim = $head/Camera.get_global_transform().basis
	
	#get input and change direction
	if Input.is_action_pressed("left"):
		direction -= aim.x
	elif Input.is_action_pressed("right"):
		direction += aim.x
	if Input.is_action_pressed("forward"):
		direction -= aim.z
	elif Input.is_action_pressed("backward"):
		direction += aim.z
	
	direction = direction.normalized()
	
	if Input.is_action_pressed("run"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	#apply gravity
	velocity.y += gravity * get_physics_process_delta_time() * -1
	
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * get_physics_process_delta_time())
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	#jumping
	
	if Input.is_action_just_pressed("up") && is_on_floor():
		velocity.y = JUMP_HEIGHT
	