extends Camera3D
# Simple script for a flying first-person player

@export var look_sens : float = 0.1
@export var speed : float = 60.0
var _look_buffer = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var direction = (
			Input.get_axis("down", "up") * Vector3.FORWARD + 
			Input.get_axis("left", "right") * Vector3.RIGHT +
			Input.get_axis("sprint", "jump") * Vector3.UP
	)
	
	direction = direction.normalized().rotated(Vector3.UP, rotation.y)
	position += direction * delta * speed
	
	if not _look_buffer == Vector2.ZERO:
		rotation.y -= _look_buffer.x * delta * look_sens
		rotation.x -= _look_buffer.y * delta * look_sens
		rotation.x = clamp(rotation.x, - PI/2, PI/2)
		_look_buffer = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		_look_buffer += event.relative

func _process(_delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		Window.mode = Window.MODE_FULLSCREEN
