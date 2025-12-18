/***WORK IN PROGRESS***/

function tiny_multiplayer() constructor {
	
	static server_id      = -1;
	static server_port	  = 27014;
	static server_ip	  = "127.0.0.1";
	static server_max	  = 4;
	static server_list	  = ds_list_create();
	
	static client_socket  = -1;
	static client_connect = -1;
	static client_name	  = "";
	static client_others  = objPlayers;
	
	static server_start = function() {
		server_id = network_create_server(network_socket_tcp, server_port, server_max);
		if server_id < 0 { return -1; }			
		return 0;
	}
	
	static server_end = function() {
		if !ds_exists(server_list, ds_type_list) { exit; }
		
		var _list_length = ds_list_size(server_list);
		for (var i = _list_length; i > 0 ; --i) {
		    network_destroy(i);
		}
		ds_list_destroy(server_list);
		server_list	  = -1;
	}
	
	static server_connect = function(_name, _start_x, _start_y) {
		
		client_name	   = _name;
		
		client_socket  = network_create_socket(network_socket_tcp);
		
		client_connect = network_connect(client_socket, server_ip, server_port);
		
		if client_connect < 0 { 
			network_destroy(client_socket);
			client_socket = -1;
			return -1;
		}
				
		var client_send = packet_send(_start_x, _start_y);
		
		if client_send < 0 { 
			network_destroy(client_socket); 
			client_socket = -1;
			return -2; 
		}
		
		return 0;
	}
	
	static server_disconnect = function() {
		network_destroy(client_socket);
	}	
	
	static client_connected = function(_async_load) {
		
		if (ds_list_size(server_list) >= server_max) or 
		   _async_load[? "type"] != network_type_connect {
			exit;
		}
		
		var _client_socket = _async_load[? "socket"];
		if _client_socket != (client_socket + 1) {
			instance_create_layer(0, 0, "Player", client_others, { socket : _client_socket });
		}
		
		packet_send_status("present");
		
		ds_list_add(server_list, _client_socket);
	}
	
	static client_disconnected = function(_async_load) {
		
		if !ds_exists(server_list, ds_type_list) or
		   _async_load[? "type"] != network_type_disconnect { 
			exit; 
		}
		var _socket		 = _async_load[? "socket"];
		var _list_index	 = ds_list_find_index(server_list, _socket);
		if  _list_index  < 0 { exit; }
		
		network_destroy(_socket);
		
		with (client_others) {
			if _async_load[? "socket"] == socket {
				instance_destroy();
			}
		}
		
		ds_list_delete(server_list, _list_index);
	}
				
	static packet_send = function(_x, _y) {
				
		var _struct = {
			"name"			: client_name,
			"x"				: _x,
			"y"				: _y
		}
		var _struct_json  = json_stringify(_struct);
		var _buffer		  = buffer_create(1, buffer_grow, 1);
		
		buffer_seek(_buffer, buffer_seek_start, 0);
		
		var _buffer_write = buffer_write(_buffer, buffer_string, _struct_json);
		var _buffer_size  = buffer_get_size(_buffer);
		var _packet_send  = network_send_packet(client_socket, _buffer, _buffer_size);
		
		buffer_delete(_buffer);
		delete _struct;
		
		if _packet_send   < 0 { return -1; }
		
		return 0;
	}
		
	static packet_send_status = function(_status) {
		
		var _struct = {
			"name"			: client_name,
			"status"		: _status
		}
		var _struct_json  = json_stringify(_struct);
		var _buffer		  = buffer_create(1, buffer_grow, 1);
		
		buffer_seek(_buffer, buffer_seek_start, 0);
		
		var _buffer_write = buffer_write(_buffer, buffer_string, _struct_json);
		var _buffer_size  = buffer_get_size(_buffer);
		var _packet_send  = network_send_packet(client_socket, _buffer, _buffer_size);
		
		buffer_delete(_buffer);
		delete _struct;
		
		if _packet_send   < 0 { return -1; }

		return 0;
	}
	
	static packet_receive = function(_async_load) {
		
		if _async_load[? "type"] != network_type_data or
		   !ds_map_exists(_async_load, "buffer") { 
		   	exit; 
		}
		var _client_socket = _async_load[? "id"];
	    var _buffer        = _async_load[? "buffer"];
	    
	    buffer_seek(_buffer, buffer_seek_start, 0);
	    
	    var _buffer_json   = buffer_read(_buffer, buffer_string);
	    var _buffer_struct = json_parse(_buffer_json);
	    var _struct_names  = struct_get_names(_buffer_struct);
	    var _struct_length = array_length(_struct_names);

		if _client_socket != (client_socket + 1) and
		   struct_exists(_buffer_struct, "status") and 
		   _buffer_struct.status == "present" {
			
			ds_list_add(server_list, _client_socket);
			if instance_number(client_others) < ds_list_size(server_list) {
				instance_create_layer(0, 0, "Player", client_others, { socket : _client_socket });	
			}
		}
		
		with (client_others) {
			
			if _async_load[? "id"] == socket {
				
				if is_undefined(name) { name = _buffer_struct.name; }

			    for (var i = 0; i < _struct_length; ++i) {
			        var _key = _struct_names[i];
			        if _key == "name" or _key == "status" { continue; }

			        variable_instance_set(id, _key, _buffer_struct[$ _key]);
			    }
			}
		}
	    buffer_delete(_buffer);
	}	

	/***********DEBUG FUNCTIONS*************/
	
	static log_async = function(_async_load) {
		var _load_keys = ds_map_keys_to_array(_async_load);
		var _load_len = array_length(_load_keys);
		var _log_file = file_text_open_append("network_async.log");
		var _struct  = {};
		for (var i = 0; i < _load_len; ++i) {
		     _struct[$ _load_keys[i]] = _async_load[? _load_keys[i]];
		}
		var _json = json_stringify(_struct, true);
		file_text_write_string(_log_file, _json + "\n");
		file_text_close(_log_file);	
	}

}
#macro TMP global.tmp