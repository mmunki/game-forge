extends MeshInstance3D

## Camera-facing orbit so the demo scene shows PBR highlights from every side.
@export var spin_speed: float = 0.55
@export var bob_height: float = 0.18
@export var bob_speed: float = 1.4

var _base_y: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	_base_y = position.y

func _process(delta: float) -> void:
	_time += delta
	rotate_y(spin_speed * delta)
	position.y = _base_y + sin(_time * bob_speed) * bob_height
