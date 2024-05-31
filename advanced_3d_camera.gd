extends Node3D

@onready var pivot = $Pivot

@onready var camera = $Pivot/Camera3D

## distance in meters from cursor to camera.
@export var zoom = 5.0

## allows the camera to move or not. Does NOT affect camera rotation.
@export var movement_allowed = true
## allows the camera to pause the scene.
@export var pausing_allowed = true
## allows the camera to reset the scene by pressing Ctrl+R.
@export var resetting_allowed = true
## allows the camera to zoom in and out.
@export var fixed_zoom = false

@export var zoom_near_limit = 1.0
@export var zoom_far_limit = 10.0

var mouseStart = Vector2.ZERO

var mouseSensitivity = -0.005

@export var speed = 5.0

var enabled = true

var resolution = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

var following = false

var follow_id = 0

var input_timer = 0.0

func _ready():
	camera.position.z = zoom

func _process(delta):
	if enabled:
		if !fixed_zoom:
			if Input.is_action_just_released("zoom_in"):
				zoom *= 0.990099 if Input.is_action_pressed("control") else 0.90909
			if Input.is_action_just_released("zoom_out"):
				zoom *= 1.01 if Input.is_action_pressed("control") else 1.1
			zoom = clamp(zoom, zoom_near_limit, zoom_far_limit)
		var k = 1.0 - pow(0.001, delta)
		camera.position.z = lerp(camera.position.z, zoom, k)
		camera.size = lerp(camera.size, zoom, k)
		
		mouseSensitivity = -0.0005 if Input.is_action_pressed("control") else -0.005
		
		if Input.is_action_just_pressed("pan") and !Input.is_action_pressed("shift"):
			mouseStart = get_viewport().get_mouse_position()
		
		if Input.is_action_pressed("pan") and !Input.is_action_pressed("shift"):
			var mousePos = get_viewport().get_mouse_position()
			
			pivot.rotate_x((mousePos - mouseStart).y * mouseSensitivity)
			rotate_y((mousePos - mouseStart).x * mouseSensitivity)
			
			pivot.rotation.x = clamp(pivot.rotation.x, -PI*0.5, PI*0.5)
			
			mouseStart = get_viewport().get_mouse_position()
		
		if movement_allowed:
			if Input.is_action_just_pressed("pan") and Input.is_action_pressed("shift"):
				mouseStart = get_viewport().get_mouse_position()
				following = false
			
			if Input.is_action_pressed("pan") and Input.is_action_pressed("shift"):
				var mousePos = get_viewport().get_mouse_position()
				var sensitivity = 0.001 * zoom * (0.25 if Input.is_action_pressed("control") else 1.0)
				
				position.x += cos(rotation.y + PI) * (mousePos - mouseStart).x * sensitivity
				position.z -= sin(rotation.y + PI) * (mousePos - mouseStart).x * sensitivity
				
				position.x -= cos(rotation.y + PI*0.5) * sin(pivot.rotation.x) * (mousePos - mouseStart).y * sensitivity
				position.y += cos(pivot.rotation.x) * (mousePos - mouseStart).y * sensitivity
				position.z += sin(rotation.y + PI*0.5) * sin(pivot.rotation.x) * (mousePos - mouseStart).y * sensitivity
				
				mouseStart = get_viewport().get_mouse_position()
			
			if Input.is_action_just_pressed("4d look") and Input.is_action_pressed("shift"):
				mouseStart = get_viewport().get_mouse_position()
				following = false
			
			if Input.is_action_pressed("4d look") and Input.is_action_pressed("shift"):
				var mousePos = get_viewport().get_mouse_position()
				var sensitivity = 0.001 * zoom * (0.25 if Input.is_action_pressed("control") else 1.0)
				
				position.x += cos(rotation.y+PI*0.5) * (mousePos - mouseStart).y * sensitivity
				position.z -= sin(rotation.y+PI*0.5) * (mousePos - mouseStart).y * sensitivity
				
				Globals.camera_w += (mousePos - mouseStart).x * -sensitivity
				
				mouseStart = get_viewport().get_mouse_position()
		
		if pausing_allowed:
			if Input.is_action_just_pressed("pause"):
				get_tree().paused = !get_tree().paused
		
		if resetting_allowed:
			if Input.is_action_just_pressed("reset"):
				get_tree().paused = false
				Globals.clear()
				get_tree().reload_current_scene()
		
		if Input.is_action_pressed("kata"):
			Globals.camera_w -= speed * delta
			following = false
		if Input.is_action_pressed("ana"):
			Globals.camera_w += speed * delta
			following = false
		
		if Input.is_action_just_pressed("4d look") and !Input.is_action_pressed("shift"):
			mouseStart = get_viewport().get_mouse_position()
		
		if Input.is_action_pressed("4d look") and !Input.is_action_pressed("shift"):
			var mousePos = get_viewport().get_mouse_position()
			
			Globals.xw_angle += cos(rotation.y + PI) * ((mousePos - mouseStart).x * mouseSensitivity)
			Globals.zw_angle -= sin(rotation.y + PI) * ((mousePos - mouseStart).x * mouseSensitivity)
			
			Globals.xw_angle += cos(rotation.y + PI * 0.5) * ((mousePos - mouseStart).y * mouseSensitivity)
			Globals.zw_angle -= sin(rotation.y + PI * 0.5) * ((mousePos - mouseStart).y * mouseSensitivity)
			
			mouseStart = get_viewport().get_mouse_position()
		
		if Input.is_action_just_pressed("follow"):
			following = !following
			if following:
				global_position = Globals.physics_objects[follow_id].global_position
				Globals.camera_w = Globals.physics_objects[follow_id].world_pos.w
		
		if Input.is_action_pressed("cycle_backward"):
			input_timer -= delta
			if input_timer <= 0.0:
				follow_id -= 1
				input_timer = 0.1
				if following:
					global_position = Globals.physics_objects[follow_id].global_position
					Globals.camera_w = Globals.physics_objects[follow_id].world_pos.w
		
		if Input.is_action_pressed("cycle_forward"):
			input_timer -= delta
			if input_timer <= 0.0:
				follow_id += 1
				input_timer = 0.1
				if following:
					global_position = Globals.physics_objects[follow_id].global_position
					Globals.camera_w = Globals.physics_objects[follow_id].world_pos.w
		
		if following:
			var particle_count = Globals.physics_objects.size()
			if follow_id < 0:
				follow_id += particle_count
			if follow_id >= particle_count:
				follow_id -= particle_count
			
			global_position = lerp(global_position, Globals.physics_objects[follow_id].global_position, 1 - pow(2.0, -delta / 0.1))
			Globals.camera_w = lerp(Globals.camera_w, Globals.physics_objects[follow_id].world_pos.w, 1 - pow(2.0, -delta / 0.1))
