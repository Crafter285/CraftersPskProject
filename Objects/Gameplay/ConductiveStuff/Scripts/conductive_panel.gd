@tool
extends Node3D

enum conductivetype {
	Electricity,
	Fire,
	Ice
}

@export var ConductiveType: conductivetype = conductivetype.Electricity:
	set(value):
		ConductiveType = value
		_update_visibility()

var _electricity_node: Node3D
var _fire_node: Node3D
var _ice_node: Node3D

signal electric_grabbed
signal fire_grabbed
signal ice_grabbed

func _ready() -> void:
	_electricity_node = get_node_or_null("Electricity")
	_fire_node = get_node_or_null("Fire")
	_ice_node = get_node_or_null("Ice")

	if not Engine.is_editor_hint():
		$Electricity/ConductiveMachanic.show()
		$Fire/ConductiveMachanic2.show()
		$Ice/ConductiveMachanic3.show()

	_update_visibility()

func _update_visibility() -> void:
	if _electricity_node == null or _fire_node == null or _ice_node == null:
		return
	match ConductiveType:
		conductivetype.Electricity:
			_electricity_node.show()
			_fire_node.hide()
			_ice_node.hide()
			$Electricity/ConductiveMachanic.enabled = true
			$Fire/ConductiveMachanic2.enabled = false
			$Ice/ConductiveMachanic3.enabled = false
		conductivetype.Fire:
			_electricity_node.hide()
			_fire_node.show()
			_ice_node.hide()
			$Electricity/ConductiveMachanic.enabled = false
			$Fire/ConductiveMachanic2.enabled = true
			$Ice/ConductiveMachanic3.enabled = false
		conductivetype.Ice:
			_electricity_node.hide()
			_fire_node.hide()
			_ice_node.show()
			$Electricity/ConductiveMachanic.enabled = false
			$Fire/ConductiveMachanic2.enabled = false
			$Ice/ConductiveMachanic3.enabled = true

func _on_conductive_machanic_electric_grabbed() -> void:
	electric_grabbed.emit()

func _on_conductive_machanic_2_fire_grabbed() -> void:
	fire_grabbed.emit()

func _on_conductive_machanic_3_ice_grabbed() -> void:
	ice_grabbed.emit()
