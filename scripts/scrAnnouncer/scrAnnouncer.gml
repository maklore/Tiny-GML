function tiny_announcer() constructor {
    
    //Initialize the values.
	static font	   = font_add("Arial", 34, false, false, 32, 128);
	font_enable_sdf(font, true);
	font_enable_effects(font, true, {
		dropShadowEnable: true,
	    dropShadowSoftness: 20,
	    dropShadowOffsetX: 4,
	    dropShadowOffsetY: 4,
		dropShadowAlpha: 1,
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: c_black
	});
    static maximum = 5;
    static size    = 0;
    static length  = 40;									//Maximum character length before new line.
    static scale   = 1;										//Scale of the drawn string.
    static prompt  = -1;
    static time    = 5;										//Seconds
    static alpha   = 1;
    static time_pf = 1 / game_get_speed(gamespeed_fps);		
    static color   = [ #64c864, #c89600, #c83232]			//Green, Amber,  Red
    static type    = [0, 1, 2];								//news, warning, error
    static val     = {
        text  : 0,
        type  : 1,
        time  : 2,
        alpha : 3
    }

    /**
     * @desc With this function you can send a stringed alert to the broadcasting system. The types and colored text of systems are as follows: 0 (News - green), 1 (Warning - yellow), and 2 (Error - red).
     * @param {string} _string  The string message you wish to add broadcasting system.
     * @param {string} _type    The type of message you wish to broadcast.
     */
    alert = function(_string, _type) {
        
        //If the type is not correct send a stringed alert to the broadcasting system and exit the function.
        if !array_contains(type, _type) { alert($"{_type} is invalid type!", 1); exit; }
        
        if !ds_exists(prompt, ds_type_list) { prompt = ds_list_create(); }
        
        //Insert array into the first entry of the list: string (wrapped), type, timer to the broadcasting prompter.
        var _string_length = string_length(_string);
        var _new_string = string_upper(_string);
	    if _string_length > length {
		    var _pos = length;
		    var _split_amount = round(_string_length / length);
		    for (var i = 0; i < _split_amount; ++i) {
		        _pos = string_last_pos_ext(" ", _new_string, _pos);
		        _new_string = string_insert("\n", _new_string, _pos);
		        _pos += length;
		    }
	    }
	    
        ds_list_insert(prompt, 0, variable_clone([_new_string, _type, time, alpha]));
		
		//Get the size of the DS list with a max of maximum size.
        size = clamp(ds_list_size(prompt), 0, maximum);
        
        //If the size is greater (should not happen) or equal to the maximum size, delete the last entry.
        if size >= maximum { ds_list_delete(prompt, size); }
        
    }
   
    /**
    * @desc With this function messages will be broadcasted to the upper center of the screen. Add this to the Draw_GUI event.
    */
    broadcast = function() {
        
        //Initialize the draw position.
        static gui_x = display_get_gui_width() * 0.5;   //Center of the GUI width.
        static gui_y = display_get_gui_height() * 0.1;  //Upper part of the GUI height.
        
        //If there is no DS list exit the function.
        if !ds_exists(prompt, ds_type_list) { exit; }
        
        //If the font is not broadcasting font, set it. **WIP**
        if draw_get_font() != font { draw_set_font(font); }
		
		//Set the text alignment if it isn't centered.
        if draw_get_halign() != fa_center { draw_set_halign(fa_center); };
        if draw_get_valign() != fa_middle { draw_set_valign(fa_middle); };
		
        var _string_y = 0;
		
        for (var i = 0; i < size; ++i) {
			
			//If there is an undefined entry exit the loop.
			if prompt[| i] == undefined { exit }
			
            //Adds the first entries string height to the current entry if there are more than one entry.
            _string_y = i > 0 ? _string_y + string_height(prompt[| 0][val.text]) * scale : 0;
						
            draw_text_transformed_color(gui_x, 
                                        gui_y + _string_y, 
                                        prompt[| i][val.text],
                                        scale,
                                        scale,
                                        0,
                                        color[prompt[| i][val.type]],
                                        color[prompt[| i][val.type]],
                                        color[prompt[| i][val.type]],
                                        color[prompt[| i][val.type]],
                                        prompt[| i][val.alpha]);
										
        }
		//Reduce timer by time per frame.
        prompt[| size - 1][val.time] -= time_pf;
            
        //Reduce alpha to zero during the last second.
        if prompt[| size - 1][val.time] <= 1 { prompt[| size - 1][val.alpha] -= time_pf; }
            
        //Delete the entry that has had it's timer reached zero.
        if prompt[| size - 1][val.time] <= 0 { 
			ds_list_delete(prompt, size - 1); 
			size = clamp(ds_list_size(prompt), 0, maximum) 
		}
        
        //If the list is empty, destroy it, and reset values.
        if ds_list_empty(prompt) { ds_list_destroy(prompt); prompt = -1; size = 0; }
    }
}

//INITIALIZE THE BROADCASTING SYSTEM
#macro MSG global.msg
MSG = new tiny_announcer();