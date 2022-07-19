extends Node3D
class_name Root_Node

var chunks = {}
var unready_chunks = {}
var thread
var player_position
var debug_text

var noise
@export var chunk_size = 128
@export var chunk_height = 32
@export var chunk_amount = 16
@export var seed = 148

func _init():
	noise = NoiseHelper.new(seed)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	thread = Thread.new()

func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_started():
		var callable = Callable(self, "load_chunk")
		callable.call([thread, x, z])
		thread.start(callable)
		unready_chunks[key] = 1

func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]
	
	var chunk = Chunk.new(noise, x * chunk_size, z * chunk_size, chunk_size, chunk_height)
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
	player_position = $Player.position
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	debug()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func update_chunks():
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

func debug():
	var current_climate = noise.get_player_climate(player_position.x, player_position.z)
	debug_text = "Position:" + str(player_position)
	debug_text += "\nClimate Noise:" + str(noise.climate_map.get_noise_3d(player_position.x, 0, player_position.z))
	debug_text += "\nClimate:" + current_climate.climate_name
	debug_text += "\nCold Weight:" + str(noise.get_weight(noise.biome_map.get_noise_3d(player_position.x, 0, player_position.z), noise.climate_cold.offset))
	debug_text += "\nBiome Noise:" + str(noise.biome_map.get_noise_3d(player_position.x, 0, player_position.z))
	debug_text += "\nBiome:" + current_climate.get_biome(noise.biome_map.get_noise_3d(player_position.x, 0, player_position.z)).biome_name
	
	$Player/DebugLabel.set_text(debug_text)

