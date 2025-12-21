/***WORK IN PROGRESS***/
/*
Main key takeaway, message, data, and timestamp are keys Tabby would use.
message   - describes what kind of message this is
data      - describes the contents that is included.
timestamp - is when the packet itself was formed
*/

function tiny_multiplayer() constructor {
	
	//**Server**//
	static server_id      = -1;
	static server_port	  = 27014;
	static server_ip	  = "localhost";
	static server_max	  = 4;
	static server_list	  = ds_list_create();
	static server_names   = ds_list_create();
	
	static server_packet_resolve = {
		"ping"		 : function(_client_socket, _buffer) {
			
			var _buffer_size   = buffer_get_size(_buffer);
			var _packet_status = network_send_packet(_client_socket, _buffer, _buffer_size);
		},
		"player_pos" : function(_client_socket, _buffer) {
						
			var _buffer_size  = buffer_get_size(_buffer);
			
			var _client_size  = ds_list_size(other.server_list);
			var _packet_loss  = 0;
						
			for (var _i = 0; _i < _client_size; ++_i;) {
				
		    	var _client_target = other.server_list[| _i];
				
		    	if  _client_target = _client_socket { continue; }
	    	
		    	var _packet_status = network_send_packet(_client_target, _buffer, _buffer_size);
	    	
		    	if  _packet_status < 0 {
		    		_packet_loss++;
		    	}
			}
	    
		    if _packet_loss > 0 {
		    	return _packet_loss;
			}
		
			return 0;
		},
		"link"		 : function(_client_socket, _type) {
			
			var _list_index	    = ds_list_find_index(other.server_list, _client_socket);
			var _list_value     = _list_index > -1 ? ds_list_find_value(other.server_names, _list_index) : undefined;
			
			var _struct = {
				"type"   : _type,
				"socket" : _client_socket,
				"time"   : date_current_datetime(),
				"name"   : _list_value,
				"data"	 : {}
			}
			var _struct_json  = json_stringify(_struct);	
			var _buffer       = buffer_create(1, buffer_grow, 1);
			var _buffer_seek  = buffer_seek(_buffer, buffer_seek_start, 0);
			var _buffer_write = buffer_write(_buffer, buffer_string, _struct_json);
			var _buffer_size  = buffer_get_size(_buffer);	
			var _client_size  = ds_list_size(other.server_list);
			var _packet_loss  = 0;
		
			for (var _i = 0; _i < _client_size; ++_i;) {
		    	var _client_target = other.server_list[| _i];
		    	if  _client_target = _client_socket { continue; }
	    	
		    	var _packet_status = network_send_packet(_client_target, _buffer, _buffer_size);
	    	
		    	if  _packet_status < 0 {
		    		_packet_loss++;
		    	}
		    }
	    
		    buffer_delete(_buffer);
			delete _struct;
	    
		    if _packet_loss > 0 {
		    	return _packet_loss;
			}
		
			return 0;
			
		}
	}
	
	static server_start = function() {
		server_id = network_create_server(network_socket_tcp, server_port, server_max);
		if server_id < 0 { return -1; }			
		return 0;
	}

	static server_end = function() {
		
		var _list_length = ds_list_size(server_list);
		
		for (var i = 0; i < _list_length ; ++i) {
		    network_destroy(server_list[| i]);
		}
		ds_list_destroy(server_list);
		ds_list_destroy(server_names);
		server_list	 = -1;
		server_names = -1;
	}

	static server_send_packet = function(_client_socket, _type, _data = {}) {

		var _struct = {
			"type"   : _type,
			"socket" : _client_socket,
			"time"   : date_current_datetime(),
			"data"	 : _data
		}
		var _struct_json  = json_stringify(_struct);	
		var _buffer = buffer_create(1, buffer_grow, 1);
			
		buffer_seek(_buffer, buffer_seek_start, 0);
		buffer_write(_buffer, buffer_string, _struct_json);
			
		var _buffer_size  = buffer_get_size(_buffer);
			
		delete _struct;
		
		var _client_size   = ds_list_size(server_list);
		var _packet_loss   = 0;
		
		for (var _i = 0; _i < _client_size; ++_i;) {
	    	var _client_target = server_list[| _i];
	    	if  _client_target = _client_socket { continue; }
	    	
	    	var _packet_status = network_send_packet(_client_target, _buffer, _buffer_size);
	    	
	    	if  _packet_status < 0 {
	    		_packet_loss++;
	    	}
	    }
	    
	    buffer_delete(_buffer);
	    
	    if _packet_loss > 0 {
	    	return _packet_loss;
		}
		
		return 0;
		
	}

	static server_receive_packet = function(_async_load) {
		
		var _packet_type   = _async_load[? "type"];
		var _client_sender = _packet_type != network_type_data ? _async_load[? "socket"] : _async_load[? "id"];
			
		switch (_packet_type) {
		
			case network_type_connect :		
			
				var _list_size = ds_list_size(server_list);
				if _list_size >= server_max { network_destroy(_client_sender); }
				
				ds_list_add(server_list, _client_sender);
				ds_list_add(server_names, undefined);
				
				var _packet_resolve = server_packet_resolve[$ "link"];
			    _packet_resolve(_client_sender, _packet_type);
				
			break;
			
			case network_type_disconnect :
								
				var _packet_resolve = server_packet_resolve[$ "link"];
			    _packet_resolve(_client_sender, _packet_type);
				
				var _list_index	   = ds_list_find_index(server_list, _client_sender);
				
				network_destroy(server_list[| _list_index]);
				ds_list_delete(server_list, _list_index);
				ds_list_delete(server_names, _list_index);
				
			break;
			
			case network_type_data :
				
				var _buffer		    = _async_load[? "buffer"];
				var _buffer_seek    = buffer_seek(_buffer, buffer_seek_start, 0);
			    var _buffer_string  = buffer_read(_buffer, buffer_string);
			    var _buffer_struct  = json_parse(_buffer_string);
				var _packet_type	= _buffer_struct.type;
				var _packet_resolve = server_packet_resolve[$ _packet_type];
				
				if struct_exists(_buffer_struct, "name") {
					var _list_index	    = ds_list_find_index(server_list, _client_sender);
					var _list_value     = ds_list_find_value(server_names, _list_index);
					if _list_index > -1 and is_undefined(_list_value) {
						ds_list_set(server_names, _list_index, _buffer_struct.name);				
					}
				}
				
			    _packet_resolve(_client_sender, _buffer);
				
				buffer_delete(_buffer);
				delete _buffer_struct;
				
			break;
		}
	}

	//**Client**//
	static client_socket  = -1;
	static client_connect = -1;
	static client_name	  = "";
	static client_object  = undefined; //Change to player object.
	static client_others  = undefined; //Change to remote player object.
	static client_list	  = ds_list_create();
	
	static client_packet_resolve = {
		"ping"		 : function(_buffer_struct) {
			show_debug_message($"{((get_timer() - _buffer_struct.time)) / 1_000} ms");
		},
		"player_pos" : function(_buffer_struct) {
			
			var _struct_names  = struct_get_names(_buffer_struct.data);
			var _struct_length = array_length(_struct_names);
			var _list_check = ds_list_find_index(other.client_list, _buffer_struct.name);		

			if (_list_check < 0) {
				
				ds_list_add(other.client_list, _buffer_struct.name);
				instance_create_layer(0, 0, "Player", other.client_others);
				var _instance_count = instance_number(other.client_others);
				var _instance_id = instance_find(other.client_others, _instance_count - 1)
				_instance_id.name = _buffer_struct.name;
					
			}
			
			with (other.client_others) {
			
					
				if name != _buffer_struct.name { continue; }
	
				for (var i = 0; i < _struct_length; ++i) {
				    var _key = _struct_names[i];
				    variable_instance_set(id, _key, _buffer_struct.data[$ _key]);
				}
			}
			
		},
		"1"			 : function(_buffer_struct) {
												
			other.client_packet_request[$ "player_pos"]();
		
		},
		"2"			 : function(_buffer_struct) {
			with (other.client_others) {
					
				if _buffer_struct.name != name { continue; }
				instance_destroy();	
				
			}
				
			var _list_index = ds_list_find_index(other.client_list, _buffer_struct.name);
			ds_list_delete(other.client_list, _list_index);
		
		}
	}
	static client_packet_request = {
		"ping"		 : function() {
			
			static _socket = other.client_socket;
			
			var _struct = {
				"type"	 : "ping",
				"time"   : get_timer()
			}
			var _struct_json  = json_stringify(_struct);
			var _buffer		  = buffer_create(1, buffer_grow, 1);
			buffer_seek(_buffer, buffer_seek_start, 0);
			var _buffer_write = buffer_write(_buffer, buffer_string, _struct_json);
			var _buffer_size  = buffer_get_size(_buffer);
			var _packet_send  = network_send_packet(_socket, _buffer, _buffer_size);
			
		},
		"player_pos" : function() {
			
			static _player = other.client_object;
			static _name   = other.client_name;
			static _socket = other.client_socket;
			
			var _struct = {
				"type"	 : "player_pos",
				"time"   : date_current_datetime(),
				"name"	 : _name,
				"data"   : {
					"x"	: _player.x,
					"y"	: _player.y
				}
			}
			var _struct_json  = json_stringify(_struct);
			var _buffer		  = buffer_create(1, buffer_grow, 1);
		
			buffer_seek(_buffer, buffer_seek_start, 0);
		
			var _buffer_write = buffer_write(_buffer, buffer_string, _struct_json);
			var _buffer_size  = buffer_get_size(_buffer);
			var _packet_send  = network_send_packet(_socket, _buffer, _buffer_size);
		
			buffer_delete(_buffer);
			delete _struct;
			
		}
	}
	
	static client_connect_server = function(_name, _start_x, _start_y) {
		
		client_name	   = _name;
		
		client_socket  = network_create_socket(network_socket_tcp);
		
		client_connect = network_connect(client_socket, server_ip, server_port);
		
		if client_connect < 0 { 
			network_destroy(client_socket);
			client_socket = -1;
			return -1;
		}
		
		client_packet_request[$ "ping"]();
		var client_send = client_packet_request[$ "player_pos"]();
		
		if client_send < 0 { 
			network_destroy(client_socket); 
			client_socket = -1;
			return -2; 
		}
		
		return 0;
	}

	static client_disconnect_server = function() {
		network_destroy(client_socket);
	}	

	static client_send_packet = function(_type) {
		
		var _call = client_packet_request[$ _type];
		_call();
		
	}

	static client_receive_packet = function(_async_load) {

	    var _buffer        = _async_load[? "buffer"];
				
	    buffer_seek(_buffer, buffer_seek_start, 0);
	    
	    var _buffer_json   = buffer_read(_buffer, buffer_string);
	    var _buffer_struct = json_parse(_buffer_json);  
		
	    var _packet_type   = _buffer_struct.type;
		
		var _packet_resolve = client_packet_resolve[$ _packet_type];
		_packet_resolve(_buffer_struct);
		
	    buffer_delete(_buffer);
	}			
	
	/**Logs**/
	static server_log_async = function(_async_load) {
		var _load_keys = ds_map_keys_to_array(_async_load);
		var _load_len = array_length(_load_keys);
		var _log_file = file_text_open_append("server_async.log");
		var _struct  = {};
		for (var i = 0; i < _load_len; ++i) {
		     _struct[$ _load_keys[i]] = _async_load[? _load_keys[i]];
		}
		var _json = json_stringify(_struct, true);
		file_text_write_string(_log_file, _json + "\n");
		file_text_close(_log_file);	
	}

	static client_log_async = function(_async_load) {
		var _load_keys = ds_map_keys_to_array(_async_load);
		var _load_len = array_length(_load_keys);
		var _log_file = file_text_open_append("client_async.log");
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
TMP = new tiny_multiplayer();