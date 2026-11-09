extends Node2D
# variables
var speed = 300
var direction = Vector2(randf_range(0,1), randf_range(0,1))
var screen_size= Vector2()
var window_size= Vector2(400, 400)
var idle_timer=0.0
var is_idling = false
var is_dragging = false
var drag_offset = Vector2()
# this only will affect if incredibly lucky or unlucky. ill just set this every frame while sleeping.
var sleepy_time = 20.0
# oh yeah this is the first time i started annotating im so smert :)
var rand_wander = 5

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var label = $Label
@onready var sprite_2d = $Label/Sprite2D


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk right")
	area.input_event.connect(_on_area_input)
	area.input_event.connect(_on_menu_input)
	$AnimatedSprite2D/PopupMenu.add_item("Need help?", 0)
	$AnimatedSprite2D/PopupMenu.id_pressed.connect(_on_menu_pressed)

func _on_menu_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			$AnimatedSprite2D/PopupMenu.popup_on_parent(Rect2i(Vector2i(event.position), Vector2i.ZERO))
			$AnimatedSprite2D/PopupMenu.id_pressed.connect(_on_menu_pressed)

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false

func _on_menu_pressed(id):
	if id == 0:
		print("They get more upset the more you do not interact with them. They will be VERY mad if you don't")
		$Label.visible = true
		await get_tree().create_timer(10.0).timeout
		$Label.visible = false

func maybe_idle():
	if randf() < 0.05 or sleepy_time <= 0:
		is_idling=true
		idle_timer = randf_range(20.0, 60.0)
		var r = 0
		if r == 0:
			animated_sprite.play("zzzz")
			speed=0
			sleepy_time = randf_range(15, 30) 
			print("this is what the sleep time is ", sleepy_time)

func _physics_process(delta: float) -> void:
	if is_dragging:
		idle_timer = 0
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = randf_range(300, 350)
			animated_sprite.play("walk right")
		return
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction*speed*delta
	print(window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	if sleepy_time >= 0:
		sleepy_time -= delta
		print("subtracted sleepy time = ", sleepy_time)
	if rand_wander >= 0:
		rand_wander -= delta
		print("wandering ", rand_wander)
	print("awawke sleepy timer ", sleepy_time)
	if rand_wander <= 0:
		_alrthisisfunmovementtime()
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		direction.y = randf_range(-2, 2)
		print("x wall hit!")
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= randf_range(-1, 1)
		maybe_idle()

# rand_wander is a random wandering thing if they spend too long existing
func _alrthisisfunmovementtime():
	if rand_wander == 0:
		direction.x *= randf_range(-1, 1)
		direction.y *= randf_range(-1, 1)
		rand_wander = randf_range(3, 10)
		print("new x is ", position.x, "and y is ", position.y)

func _justmakesureitdoesntexplode():
	if direction.x == 0: 
		direction.x = randf_range(-1, 1)
	if direction.y == 0:
		direction.y = randf_range(-1, 1)
