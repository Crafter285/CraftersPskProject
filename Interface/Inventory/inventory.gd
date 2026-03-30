extends Node

var items_VHS: Array = []
var items_Keys: Array = []
var items_Notes: Array = []
var items_Equipment: Array = []

var notes_data: Array = []

func scan_list(list_name: String, item_name: String):
	var list: Array = get(list_name)
	
	if list == null:
		return false
	var found_item = false
	for i in list.size():
		if list[i][0] == item_name:
			found_item = true
	return found_item

func remove_item(list_name: String, item_name: String):
	var list: Array = get(list_name)
	
	var removed: bool = false
	for i in list.size():
		if not removed:
			if list[i][0] == item_name:
				if list == items_Notes:
					notes_data.remove_at(i)
				list.remove_at(i)
				removed = true
