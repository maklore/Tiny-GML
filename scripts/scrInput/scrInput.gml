function tiny_input() constructor {
	//Credit for key_press etc idea: germ3x
	/*
	
	This struct has/contains the input variables and their set values.
	*/
	key = {
		left		: [ord("A"),	vk_left],
		right		: [ord("D"),	vk_right],
		up			: [ord("W"),	vk_up],
		down		: [ord("S"),	vk_down],
	}
	
	
	mouse = {
		primary		: [mb_left,		-4],
		secondary	: [mb_right,	-4]
	}
	
	/*
	These variables are used to keep track of the input variable names, and values.
	*/
	key_names = struct_get_names(key);
	key_names_length = struct_names_count(key);
	mouse_names = struct_get_names(mouse);
	mouse_names_length = struct_names_count(mouse);
	
	/**
	 * @desc With this function you save the current state of keybinds to a file.
	 */
	save_keybinds = function() {
		var _save_name = "keybinds.json";
		var _open_save = file_text_open_write(_save_name);
		var _bindings  = { _key : key, _mouse : mouse }
		var _json_keybinds = json_stringify(_bindings, true);
		file_text_write_string(_open_save, _json_keybinds);
		file_text_close(_open_save);
		return "Keybinds saved!"
	}
	
	/**
	 * @desc With this function you load keybinds from save file if it exists.
	 */
	load_keybinds = function() {
		var _save_name = "keybinds.json";
		if !file_exists(_save_name) return "No keybinds file found!";
		var _open_save = file_text_open_read(_save_name);
		var _save_string = "";
		while (!file_text_eof(_open_save)) {
			_save_string += file_text_readln(_open_save);	
		}
		var _load_save = json_parse(_save_string);
		struct_set(self, key, _load_save._key);
		struct_set(self, mouse, _load_save._mouse);
		file_text_close(_open_save);
		return "Keybinds loaded!"
	}
	
	//Initiate loading of keys;
	load_keybinds();
	
	/**
	 * @desc With this function you can check if any of the set keys are held down or not.
	 * @param {string} _name Name of the input variable.
	 */
	key_press = function(_name) {
		if !struct_exists(key, _name) { show_debug_message($"{_name} is invalid!") return 0 }
		return keyboard_check(key[$ _name][0]) or keyboard_check(key[$ _name][1]);
	}
	
	/**
	 * @desc With this function you can check if any of the set keys have been pressed or not.
	 * @param {string} _name Name of the input variable.
	 */
	key_pressed = function(_name) {
		if !struct_exists(key, _name) { show_debug_message($"{_name} is invalid!") return 0 }
		return keyboard_check_pressed(key[$ _name][0]) or keyboard_check_pressed(key[$ _name][1]);
	}
	
	/**
	 * @desc With this function you can check if any of the set keys have been released or not.
	 * @param {string} _name Name of the input variable.
	 */
	key_released = function(_name) {
		if !struct_exists(key, _name) { show_debug_message($"{_name} is invalid!") return 0 }
		return keyboard_check_released(key[$ _name][0]) or keyboard_check_released(key[$ _name][1]);
	}
	
	/**
	 * @desc With this function you can check if any of the set mouse buttons are held down or not.
	 * @param {string} _name Name of the input variable.
	 */
	mouse_press = function(_name) {
		if !struct_exists(mouse, _name) { show_debug_message($"{_name} is invalid!") return 0 }
		return mouse_check_button(mouse[$ _name][0]) or mouse_check_button(mouse[$ _name][1]);
	}
	
	/**
	 * @desc With this function you can check if any of the set mouse buttons have been pressed or not.
	 * @param {string} _name Name of the input variable.
	 */
	mouse_pressed = function(_name) {
		if !struct_exists(mouse, _name) { show_debug_message($"{_name} is invalid!") return 0 }
		return mouse_check_button_pressed(mouse[$ _name][0]) or mouse_check_button_pressed(mouse[$ _name][1]);
	}
	
	/**
	 * @desc With this function you can check if any of the set mouse buttons have been released or not.
	 * @param {string} _name Name of the input variable.
	 */
	mouse_released = function(_name) {
		if !struct_exists(mouse, _name) { show_debug_message($"{_name} is invalid!") return 0 }
		return mouse_check_button_released(mouse[$ _name][0]) or mouse_check_button_released(mouse[$ _name][1]);
	}
	
	/**
	 * @desc With this function you can check if a key is assigned.
	 * @param {any} _key Key to be checked.
	 */
	free = function(_key) {
		var _check_use = false
		for (var i = 0; i < names_length; ++i) {
			if array_contains(key[$ names[i]], _key) {
				_check_use = true;
				break
			}
		}
		if _check_use return false
		return true
	}

	/**
	 * @desc With this function you can add an input variable, and key(s) to be assigned.
	 * @param {string} _name Name of the input variable.
	 * @param {real} _primary Primary key to be set.
	 * @param {real} _secondary Default is -4.
	 */
	add = function(_name, _primary, _secondary = -4) {
		if string_letters(_name) != _name 
			return "Name can only contain letters!"
		if struct_exists(key, _name) 
			return "Name exists!"
		if (_primary < 0 and _primary > 254) or (_secondary != -4 or (_secondary < 0 and _secondary > 254)) 
			return "Invalid key(s)!"
		if !free(_primary) or (_secondary != -4 and !free(_secondary)) 
			return "Key(s) in use!"
			
		var _name_lowercase = string_lower(_name);
		struct_set(key, _name_lowercase, [_primary, _secondary]);
		key_names = struct_get_names(key);
		key_names_length = struct_names_count(key);
		return $"Input name : {_name_lowercase}\nPrimary key : {_primary}\nSecondary key : {_secondary}\nHave been added!"
	}
	
	/**
	 * @desc With this function you can remove an input variable.
	 * @param {string} _name Name of the input variable.
	 */
	remove = function(_name) {
		if _name == "" return "Name cannot be empty!"
		//For chaos >:)//////////
		if _name == "remove" {
			struct_remove(self, _name)
			show_message_async("Function 'remove' removed!... Not the greatest idea...");
			exit
		}
		//////////////////////////////
		if !struct_exists(key, _name) return "Input does not exist!"
		struct_remove(key, _name);
		return "Input has been removed!"
	}
	/**
	 * @desc With this function you can assign either the primary or the secondary key from the input variable.
	 * @param {string} _name Name of the input variable.
	 * @param {bool} _secondary Default is false.
	 */
	assign = function(_name, _secondary = false) {
		if !free(keyboard_lastkey) return "Key taken!"
		var get_key = keyboard_lastkey;
		keyboard_clear(keyboard_lastkey)
		key[$ _name][_secondary] = get_key;
		return "Key assigned!";
	}
	
	/**
	 * @desc With this function you can unassign either the primary or the secondary key from the input variable.
	 * @param {string} _name Name of the input variable.
	 * @param {bool} _secondary Default is false.
	 */
	unassign = function(_name, _secondary = false) {
		var _index_name = _secondary == false ? "Primary" : "Secondary";
		if key[$ _name][_secondary] == -4 return $"{_index_name} input for '{_name}' is already unassigned!"
		key[$ _name][_secondary] = -4;
		return $"{_index_name} input for '{_name}' has been unassigned!"
	}
}

//INITIALIZE THE INPUT CONSTRUCTOR
#macro INPUT global.input
INPUT = new tiny_input();
