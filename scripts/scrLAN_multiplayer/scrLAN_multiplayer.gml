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
	static server_ip	  = "127.0.0.1";
	static server_max	  = 4;
	static server_list	  = ds_list_create();
	static server_names   = ds_list_create();
	
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

	static server_send_packet = function(_client_socket, _type, _buffer_load = undefined, _buffer_load_size = 0) {
		
		var _buffer = _buffer_load;
		var _buffer_size = _buffer_load_size;
		
		if is_undefined(_buffer) {
			
			_struct = {
				"type"   : _type,
				"socket" : _client_socket,
				"time"   : date_current_datetime(),
			}
			
			var _struct_json  = json_stringify(_struct);
			
			_buffer = buffer_create(1, buffer_grow, 1);
			
			buffer_seek(_buffer, buffer_seek_start, 0);
			buffer_write(_buffer, buffer_string, _struct_json);
			
			_buffer_size  = buffer_get_size(_buffer);
			
			delete _struct;
		}
		
		var _client_size   = ds_list_size(server_list);
		var _packet_loss   = 0;
		
		
		for (var _i = 0; _i < _client_size; ++_i;) {
	    	var _client_target = server_list[| i];
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
		
		var _packet_type = _async_load[? "type"];
		
		switch (_packet_type) {
		
			case network_type_connect :
			
				var _client_socket = _async_load[? "socket"];
				
				var _list_size = ds_list_size(server_list);
				if _list_size >= server_max { network_destroy(_client_socket); }
				
				ds_list_add(server_list, _client_socket);
				ds_list_add(server_names, undefined);
				
				server_send_packet(_client_socket, _packet_type);
				
			break;
			
			case network_type_disconnect :
			
				var _client_socket = _async_load[? "socket"];
				var _list_index	   = ds_list_find_index(server_list, _client_socket);

				server_send_packet(_client_socket, _packet_type);
				
				network_destroy(server_list[| _list_index]);
				ds_list_delete(server_list, _list_index);
				ds_list_delete(server_names, _list_index);
				
			break;
			
			case network_type_data :
			
				var _client_socket = _async_load[? "id"];
			    var _buffer        = _async_load[? "buffer"];
			    var _buffer_size   = _async_load[? "size"];
			    var _client_size   = ds_list_size(server_list);
			    var _list_index	   = ds_list_find_index(server_list, _socket);
			    
			    if server_names[| _list_index] == undefined {
				    buffer_seek(_buffer, buffer_seek_start, 0);
				    var _buffer_json   = buffer_read(_buffer, buffer_string);
				    var _buffer_struct = json_parse(_buffer_json);
				    
				    server_names[| _list_index] = _buffer_struct.name;
			    }
			    
			    server_send_packet(_client_socket, _packet_type, _buffer, _buffer_size);
			    
				buffer_delete(_buffer);
			break;
		}
	}

	//**Client**//
	static client_socket  = -1;
	static client_connect = -1;
	static client_name	  = "";
	static client_others  = objPlayers;
	static client_list	  = ds_list_create();
	static client_names	  = ds_list_create();
	
	static client_connect_server = function(_name, _start_x, _start_y) {
		
		client_name	   = _name;
		
		client_socket  = network_create_socket(network_socket_tcp);
		
		client_connect = network_connect(client_socket, server_ip, server_port);
		
		if client_connect < 0 { 
			network_destroy(client_socket);
			client_socket = -1;
			return -1;
		}
				
		var client_send = client_send_packet(_start_x, _start_y);
		
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

	static client_send_packet = function(_x, _y) {
				
		var _struct = {
			"type"	 : network_type_data,
			"socket" : (client_socket + 1), //Server gets socket index one above client socket.
			"time"   : date_current_datetime(),
			"name"	 : client_name,
			"data"   : {
				"x"	: _x,
				"y"	: _y
			}
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

	static client_receive_packet = function(_async_load) {
		
	    var _buffer        = _async_load[? "buffer"];
	    
	    buffer_seek(_buffer, buffer_seek_start, 0);
	    
	    var _buffer_json   = buffer_read(_buffer, buffer_string);
	    var _buffer_struct = json_parse(_buffer_json);
		
		var _struct_names  = struct_get_names(_buffer_struct.data);
	    var _struct_length = array_length(_struct_names);
	    
	    var _packet_type   = _buffer_struct.type;
	    var _client_socket = _buffer_struct.socket;
		
		switch (_packet_type) {
			
			case network_type_connect :
			
				ds_list_add(client_list, _client_socket);
				ds_list_add(client_names, undefined);
				
				var _instance_init = {
					name   : undefined,
					socket : _client_socket
				}
				
				instance_create_layer(0, 0, "Player", client_others, _instance_init);
				
				delete _instance_init;
				
			break;
			
			case network_type_disconnect :
			
				with (client_others) {
			
					if _client_socket != socket { continue; }
					
					instance_destroy();	
					
				}
				
				var _list_index = ds_list_find_index(client_list, _client_socket);
				ds_list_delete(client_list, _list_index);
				ds_list_delete(client_names, _list_index);
				
			break;
			
			case network_type_data :
				var _client_name = _buffer_struct.name;
				
				with (client_others) {
			
					if _client_socket != socket { continue; }
						
					if is_undefined(name) { 
						var _list_index = ds_list_find_index(client_list, _client_socket);
						client_names[| _list_index] = _buffer_struct.name;
						name = _buffer_struct.name; 
						
					}
	
				    for (var i = 0; i < _struct_length; ++i) {
				        var _key = _struct_names[i];
				        variable_instance_set(id, _key, _buffer_struct.data[$ _key]);
				    }
				}
			break;
		}
		

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