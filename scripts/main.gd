extends Node2D


var grid: Array = []
var tmp_grid: Array = []
var cell_size:Vector2 = Vector2(10, 10)
var mouse_grid:Vector2 = Vector2(0, 0)
onready var x_len = get_viewport_rect().size.x / cell_size.x
onready var y_len = get_viewport_rect().size.y / cell_size.y
var rng = RandomNumberGenerator.new()
var is_playing = false
onready var gui = $interface
# Called when the node enters the scene tree for the first time.
func _ready():
	init_grid()

func _draw():
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x]:
				draw_rect(Rect2(Vector2(x * cell_size.x ,y * cell_size.y), cell_size), Color.green)
			else:
				draw_rect(Rect2(Vector2(x * cell_size.x ,y * cell_size.y), cell_size), Color.whitesmoke)
	if(!is_playing):
		draw_pointer()

func init_grid():
	grid.clear()
	var y = 0
	while y < y_len:
		var row = []
		var x = 0
		while x < x_len:
			row.append(false)
			x += 1
		grid.append(row)
		y += 1

func get_pointer():
	var mouse_position = get_local_mouse_position()
	var x_pos = floor(mouse_position.x / cell_size.x) * cell_size.x
	var y_pos = floor(mouse_position.y / cell_size.y) * cell_size.y
	mouse_grid = Vector2(x_pos, y_pos)

func draw_pointer():
	draw_rect(Rect2(mouse_grid, cell_size), Color.green)

func fix_pointer():
	var i_x = mouse_grid.x / cell_size.x
	var i_y = mouse_grid.y / cell_size.y
	grid[i_y][i_x] = !grid[i_y][i_x]

func random_grid():
	rng.randomize()
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if rng.randi() % 2:
				grid[y][x] = true
			else:
				grid[y][x] = false

func get_neighbour_alive(x:int, y:int):
	var nb_neighbour = 0
	var neighbour_x = [x - 1, x, x + 1]
	var neighbour_y = [y - 1, y, y + 1]
	for n_y in neighbour_y:
		if n_y >= 0 and n_y < y_len:
			for n_x in neighbour_x:
				if n_x >= 0 and n_x < x_len:
					if n_x != x or n_y != y:
						if tmp_grid[n_y][n_x]:
							nb_neighbour += 1
	return nb_neighbour

func grid_to_tmp():
	tmp_grid.clear()
	for y in range(grid.size()):
		var row = []
		for x in range(grid[y].size()):
			row.append(grid[y][x])
		tmp_grid.append(row)

func update_grid():
	grid_to_tmp()
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var neighbour_aive = get_neighbour_alive(x, y)
			if neighbour_aive == 3 or (neighbour_aive == 2 and grid[y][x]):
				grid[y][x] = true
			else:
				grid[y][x] = false

func _process(delta):
	gui.visible = !is_playing
	if Input.is_action_just_pressed("play"):
		is_playing = !is_playing

	if is_playing:
		update_grid()
	else :
		get_pointer()
		if Input.is_action_just_pressed("random_gen"):
			random_grid()
		if Input.is_action_just_pressed("fix_pointer"):
			fix_pointer()
		if Input.is_action_just_pressed("clear"):
			init_grid()
	update()
