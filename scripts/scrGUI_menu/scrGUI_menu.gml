global.font_gui = font_add("Arial", 32, false, false, 32, 128);

if os_browser == browser_not_a_browser {
	font_enable_sdf(global.font_gui, true);
	font_enable_effects(global.font_gui, true, {
		dropShadowEnable: true,
		dropShadowSoftness: 10,
		dropShadowOffsetX: 4,
		dropShadowOffsetY: 4,
		dropShadowAlpha: 1,
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: c_black
	});
}

global.GUI_menu = {
    menu_current : undefined,
    prop    : { //xx and yy are determined in % of GUI width and height.
        width  : 200,
        height : font_get_size(global.font_gui) * 2,
		xx : 0.5,
        yy : 0.5
    }
}

function tiny_menu_add(_name, _menu_name_array) {
	
	var _gui = global.GUI_menu;
	
	if struct_exists(_gui, _name) { return -1; }
	
	if is_undefined(_gui.menu_current) { _gui.menu_current = _name; }
	
	struct_set(_gui, _name, {
		menus : _menu_name_array,
		buttons : {}
	});

	var _array_length = array_length(_menu_name_array);
	
	for (var i = 0; i < _array_length; ++i) {
		var _struct_name = struct_get(_gui, _name);
		struct_set(_struct_name.buttons, _menu_name_array[i], {
			text : "",
			call : undefined
		});
	}
	return 0;
}

function tiny_menu_set(_name, _menu_name, _string, _function_or_menu_name) {
	var _gui = global.GUI_menu;
	var _gui_name = struct_get(_gui, _name);

	if is_undefined(_gui_name) { return -1; }
	
	var _gui_menu_button = struct_get(_gui_name.buttons, _menu_name);
	
	if is_undefined(_gui_menu_button) { return -2; }
	
	_gui_menu_button.text = _string;
	_gui_menu_button.call = _function_or_menu_name;

	return 0;
}

function tiny_menu_draw() {
	
    static _gui_width   = display_get_gui_width();
    static _gui_height  = display_get_gui_height();
    var _gui_mouse_x = device_mouse_x_to_gui(0);
    var _gui_mouse_y = device_mouse_y_to_gui(0);
    var _gui_struct  = global.GUI_menu;
    var _gui         = _gui_struct[$ _gui_struct.menu_current];
    if is_undefined(_gui_struct.menu_current) { return -1; }
    var _count       = array_length(_gui.menus); 
    draw_set_valign(fa_middle);
	if draw_get_font() != global.font_gui { draw_set_font(global.font_gui); }
    for (var i = 0; i < _count; ++i) {
        if draw_get_halign() != fa_center { draw_set_halign(fa_center); }
        var _menu = struct_get(_gui.buttons, _gui.menus[i]); 
        
        var _box_width = _gui_struct.prop.width * 0.5;
        var _box_height = _gui_struct.prop.height * 0.5;
        
        var _draw_x = _gui_width  * _gui_struct.prop.xx;
        var _draw_y = _gui_height * _gui_struct.prop.yy;
        
        draw_text(_draw_x, 
                  _draw_y + _gui_struct.prop.height * i, 
                  _gui.menus[i]);
        
        var _left   = _draw_x - _box_width;
        var _top    = _draw_y - _box_height + _gui_struct.prop.height * i;
        var _right  = _draw_x + _box_width;
        var _bottom = _draw_y - _box_height + _gui_struct.prop.height * i + _gui_struct.prop.height;
        
        var _on_hover = point_in_rectangle(_gui_mouse_x,
                                           _gui_mouse_y,
                                           _left, 
                                           _top, 
                                           _right, 
                                           _bottom - 1);
		
        if _on_hover {
            var _mouse_check = mouse_check_button_pressed(mb_left);
			
			var _call_check  = struct_exists(_menu, "call");
			
            if _mouse_check and _call_check { 
                switch (typeof(_menu.call)) {
                    case "string" :
                        _gui_struct.menu_current = _menu.call;
                    break;
                    case "method" :
                        _menu.call();
                    break;
                }
            }
            
            draw_set_halign(fa_left);
            draw_rectangle(_left,
                           _top, 
                           _right, 
                           _bottom, 
                           true);
            
            draw_text(_draw_x + _gui_struct.prop.width, 
                      _draw_y + _gui_struct.prop.height * i, 
                      _menu.text);
        }
    }
}

///**Example**///
//tiny_menu_add("main", ["Play", "Quit"]);
//tiny_menu_set("main", "Play", "~Pressing this takes you to the next room.", function() { room_goto_next() })
//tiny_menu_set("main", "Quit", "~Pressing this closes the game.", function() { game_end() })