extends Node3D

var chunks = {}
var unready_chunks = {}
var thread

var base_noise
@export var chunk_size = 128
@export var chunk_height = 32
@export var chunk_amount = 16
@export var base_noise_seed = 88
@export var base_noise_frequency = 0.005
@export var base_noise_fractal_octaves = 5
@export var base_noise_fractal_lacunarity = 2.5
@export var base_noise_fractal_gain = 0.6
@export var base_noise_fractal_weighted_strength = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	base_noise = FastNoiseLite.new()
	base_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	base_noise.seed = base_noise_seed
	base_noise.frequency = base_noise_frequency
	base_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	base_noise.fractal_octaves = base_noise_fractal_octaves
	base_noise.fractal_lacunarity = base_noise_fractal_lacunarity
	base_noise.fractal_gain = base_noise_fractal_gain
	base_noise.fractal_weighted_strength = base_noise_fractal_weighted_strength
	
	thread = Thread.new()

func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_started():
		var callable = Callable(self, "load_chunk")
		thread.start(callable)
		callable.call([thread, x, z])
		unready_chunks[key] = 1

func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]
	
	var chunk = Chunk.new(base_noise, x * chunk_size, z * chunk_size, chunk_size, chunk_height)
	chunk.position = Vector3(x * chunk_size, 0, z * chunk_size)
	
	call_deferred("load_done", chunk, thread)

func load_done(chunk, thread):
	add_child(chunk)
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()

func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
		
	return null

func _process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func update_chunks():
	var player_position = $Player.position
	var p_x = int(player_position.x) / chunk_size
	var p_z = int(player_position.z) / chunk_size
	
	for x in range(p_x - chunk_amount * 0.5, p_x + chunk_amount * 0.5):
		for z in range(p_z - chunk_amount * 0.5, p_z + chunk_amount * 0.5):
			add_chunk(x, z)
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false

func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true
