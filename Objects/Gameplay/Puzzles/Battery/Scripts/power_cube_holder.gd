extends StaticBody3D

@onready var insert: AudioStreamPlayer3D = $Insert

var cubes_current: Array[bool] = [false, false, false, false]
var cubes_target: Array[bool] = [true, true, true, true]

signal completed

func check_cubes():
	if cubes_current == cubes_target:
		completed.emit()

func _process(delta: float) -> void:
	if $Cube1.visible:
		if $Cube1.position.y > 1.055:
			$Cube1.position.y = move_toward($Cube1.position.y, 1.055, 0.2*delta)
	if $Cube2.visible:
		if $Cube2.position.y > 1.055:
			$Cube2.position.y = move_toward($Cube2.position.y, 1.055, 0.2*delta)
	if $Cube3.visible:
		if $Cube3.position.y > 1.055:
			$Cube3.position.y = move_toward($Cube3.position.y, 1.055, 0.2*delta)
	if $Cube4.visible:
		if $Cube4.position.y > 1.055:
			$Cube4.position.y = move_toward($Cube4.position.y, 1.055, 0.2*delta)
func cube_inserted1() -> void:
	if cubes_current[0] == cubes_target[0]: return
	if Inventory.scan_list("items_Keys", "Red Power Cube"):
		$Cube1.visible = true
		insert.play()
		cubes_current[0] = true
		check_cubes()
func cube_inserted2() -> void:
	if cubes_current[1] == cubes_target[1]: return
	if Inventory.scan_list("items_Keys", "Blue Power Cube"):
		$Cube2.visible = true
		insert.play()
		cubes_current[1] = true
		check_cubes()
func cube_inserted3() -> void:
	if cubes_current[2] == cubes_target[2]: return
	if Inventory.scan_list("items_Keys", "Yellow Power Cube"):
		$Cube3.visible = true
		insert.play()
		cubes_current[2] = true
		check_cubes()
func cube_inserted4() -> void:
	if cubes_current[3] == cubes_target[3]: return
	if Inventory.scan_list("items_Keys", "Green Power Cube"):
		$Cube4.visible = true
		insert.play()
		cubes_current[3] = true
		check_cubes()
