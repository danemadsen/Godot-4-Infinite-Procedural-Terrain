extends Node
class_name NoiseHelper

var base
var climate_map
var biome_map
var mountains
var taiga
var planes
var mesa
var desert

var climate_cold
var climate_cool
var climate_warm
var climate_hot

func _init(seed):
	randomize()
	self.base = FastNoiseLite.new()
	self.base.noise_type = FastNoiseLite.TYPE_SIMPLEX
	self.base.seed = seed
	self.base.frequency = 0.005
	self.base.fractal_type = FastNoiseLite.FRACTAL_FBM
	self.base.fractal_octaves = 5
	self.base.fractal_lacunarity = 2.5
	self.base.fractal_gain = 0.6
	self.base.fractal_weighted_strength = 1
	
	self.climate_map = FastNoiseLite.new()
	self.climate_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	self.climate_map.seed = seed + 1
	self.climate_map.frequency = 0.001
	
	self.biome_map = FastNoiseLite.new()
	self.biome_map.noise_type = FastNoiseLite.TYPE_CELLULAR
	self.biome_map.seed = seed + 2
	self.biome_map.frequency = 0.005
	self.biome_map.cellular_distance_function = FastNoiseLite.DISTANCE_HYBRID
	self.biome_map.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	self.biome_map.cellular_jitter = 1
	self.biome_map.domain_warp_enabled = true
	self.biome_map.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	self.biome_map.domain_warp_amplitude = 15
	self.biome_map.domain_warp_frequency = 0.015
	self.biome_map.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT
	self.biome_map.domain_warp_fractal_octaves = 5
	self.biome_map.domain_warp_fractal_lacunarity = 2.5
	self.biome_map.domain_warp_fractal_gain = 0.5
	
	self.mountains = FastNoiseLite.new()
	self.mountains.noise_type = FastNoiseLite.TYPE_PERLIN
	self.mountains.seed = seed + 3
	self.mountains.frequency = 0.01
	self.mountains.fractal_type = FastNoiseLite.FRACTAL_FBM
	self.mountains.fractal_octaves = 5
	self.mountains.fractal_lacunarity = 2.5
	self.mountains.fractal_gain = 0.5
	self.mountains.fractal_weighted_strength = 0.9
	self.mountains.domain_warp_enabled = true
	self.mountains.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	self.mountains.domain_warp_amplitude = 20
	self.mountains.domain_warp_frequency = 0.005
	
	self.climate_hot = Climate.new(1, base, base, base, base)
	self.climate_warm = Climate.new(0.35, base, base, base, base)
	self.climate_cool = Climate.new(-0.35, base, base, base, base)
	self.climate_cold = Climate.new(-1, mountains, mountains, mountains, mountains)
